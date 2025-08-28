import 'dart:async';
import 'package:bevert/core/di/locator.dart';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/core/services/helper/format_duration.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_state.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_bloc.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_event.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_state.dart';
import 'package:bevert/presentation/record/widgets/completed_recording_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart' show Uuid;
import 'widgets/exit_recording_dialog.dart';
import 'widgets/meeting_info_bottom_sheet.dart';
import 'widgets/recoding_loading_overlay.dart';
import 'widgets/recording_control_bar.dart';

class RecordScreen extends StatelessWidget {
  final String folderName;

  const RecordScreen({super.key, this.folderName = '기타'});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<RecordingBloc>(), // DI 활용
      child: _RecordScreenView(folderName: folderName),
    );
  }
}

class _RecordScreenView extends StatefulWidget {
  final String folderName;

  const _RecordScreenView({required this.folderName});

  @override
  State<_RecordScreenView> createState() => _RecordScreenViewState();
}

class _RecordScreenViewState extends State<_RecordScreenView>    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _hasShownMeetingInfo = false;
  late final AnimationController _animationController;
  late final Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.4),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      debugPrint("앱이 백그라운드로 갔지만 녹음은 유지합니다.");
    } else if (state == AppLifecycleState.resumed) {
      debugPrint("앱이 다시 포그라운드로 돌아왔습니다.");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.read<RecordingBloc>().state;

    if (!_hasShownMeetingInfo && state.status == RecordingStatus.idle) {
      _hasShownMeetingInfo = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMeetingInfoDialog(context);
      });
    }
  }

  void _showMeetingInfoDialog(BuildContext context) {
    final bloc = context.read<RecordingBloc>();
    final state = bloc.state;

    showModalBottomSheet(
      enableDrag: true,
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) {
        return MeetingInfoBottomSheet(
          initialTitle: state.title,
          initialContext: state.meetingContext,
          onSave: (title, contextText) {
            bloc.add(UpdateMeetingInfo(title, contextText));
          },
        );
      },
    );
  }

  /// 스크립트 저장 로직
  Future<void> _onFinishAndSave(BuildContext context, RecordingState state) async {
    context.read<RecordingBloc>().add(StopRecording());

    final fullTranscript = state.segments.join(' ').trim();
    if (fullTranscript.isEmpty) {
      context.pop();
      return;
    }

    final now = DateTime.now().toLocal();
    final fallbackTitle = '제목없음_${now.toString().substring(0, 16)}';

    final newRecord = TranscriptRecord(
      id: const Uuid().v4(),
      title: state.title.isEmpty ? fallbackTitle : state.title,
      folderName: widget.folderName,
      transcript: fullTranscript,
      summary: "", // 요약 전이므로 비워둡니다.
      createdAt: DateTime.now().toUtc(),
      status: SummaryStatus.none, // '요약 전(none)' 상태로 설정
      meetingContext: state.meetingContext, // meetingContext 추가
    );

    context.read<TranscriptBloc>().add(SaveTranscriptEvent(newRecord));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final status = context.watch<RecordingBloc>().state.status;
    final bool showLoadingIndicator =
        status == RecordingStatus.initializing || status == RecordingStatus.resuming;

    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        final displayTranscript = state.segments.join('\n');

        return BlocListener<TranscriptBloc, TranscriptState>(

          // 번역 완료 시, Listener를 통해 요약 화면으로 이동
          listenWhen: (previous, current) => current is TranscriptSaved,
          listener: (context, state) {
            final saved = state as TranscriptSaved;

            showDialog(
              context: context,
              barrierDismissible: false, // 배경 터치로 닫힘 방지
              builder: (dialogContext) =>
                  CompletedRecordingDialog(
                    folderName: saved.transcript.folderName,
                    onConfirm: () {
                      print("종료");
                      context.pop();
                    },
                  ),
            );
          },
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;

              if (displayTranscript.isEmpty) {
                context.pop();
              } else {
                final bloc = context.read<RecordingBloc>();
                bloc.add(PauseRecording());
                showDialog(
                  context: context,
                  builder: (dialogContext) =>
                      ExitRecordingDialog(
                        onConfirm: () {
                          bloc.add(StopRecording());
                          context.pop();
                        },
                      ),
                );
              }
            },
            child: Scaffold(
              appBar: AppBar(
                title: Column(
                  children: [
                    Text( (state.title == "") ? "노트 생성" : state.title, style: theme.textTheme.bodyLarge), // Corrected: "" instead of ""
                    Text(formatDuration(state.duration), style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
              body: Stack(
                alignment: Alignment.center,
                children: [
                  // 녹음 내용 표시
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150),
                    child: ListView.builder(
                            padding: const EdgeInsets.all(16.0),
                            itemCount: state.segments.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4.0),
                                child: Text(
                                  state.segments[index],
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                  ),

                  // "녹음을 시작해주세요" 애니메이션
                  if (state.status == RecordingStatus.idle ||
                      state.status == RecordingStatus.paused)
                    Positioned(
                      bottom: 150, // 컨트롤 바 위에 위치
                      child: SlideTransition(
                        position: _animation,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '녹음버튼을 눌러 시작해주세요',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: theme.primaryColor),
                            ),
                            Icon(Icons.arrow_downward,
                                size: 20, color: theme.primaryColor),
                          ],
                        ),
                      ),
                    ),

                  // 녹음 컨트롤 바
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(16.0),
                      color: theme.scaffoldBackgroundColor,
                      child: RecordingControlBar(
                        onMicTap: () {
                          final bloc = context.read<RecordingBloc>();
                          switch (state.status) {
                            case RecordingStatus.idle:
                            case RecordingStatus.stopped:
                              bloc.add(StartRecording());
                              break;
                            case RecordingStatus.recording:
                              bloc.add(PauseRecording());
                              break;
                            case RecordingStatus.paused:
                              bloc.add(ResumeRecording());
                              break;
                            default:
                              break;
                          }
                        },
                        onFinish: () {
                          _onFinishAndSave(context, state);
                        },
                        segments: state.segments,
                      ),
                    ),
                  ),

                  if (showLoadingIndicator)

                    // 중앙 오버레이
                    const Center(
                      child: LoadingOverlay(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}