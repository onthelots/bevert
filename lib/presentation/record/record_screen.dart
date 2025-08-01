import 'dart:async';
import 'package:bevert/core/di/locator.dart';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/core/services/summary_service.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_state.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_bloc.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_event.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_state.dart';
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

class _RecordScreenViewState extends State<_RecordScreenView> with WidgetsBindingObserver {
  bool _hasShownMeetingInfo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // 옵저버 등록
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 옵저버 제거
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bloc = context.read<RecordingBloc>();
    final status = bloc.state.status;

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
      backgroundColor: Theme
          .of(context)
          .scaffoldBackgroundColor,
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

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("회의록을 요약하는 중..."),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onFinishAndTranslate(BuildContext context, RecordingState state,
      SummaryService summaryService, String title,
      String meetingContext) async {
    context.read<RecordingBloc>().add(StopRecording());

    final fullTranscript = (state.segments + [state.currentWords])
        .join(' ')
        .trim();
    if (fullTranscript.isEmpty) return;

    _showLoadingDialog(context);

    final summary = await summaryService.summarize(
        fullTranscript, context: meetingContext);
    Navigator.of(context).pop();

    final now = DateTime.now().toLocal();
    final fallbackTitle = '제목없음_${now.toString().substring(0, 16)}';

    final newRecord = TranscriptRecord(
      id: const Uuid().v4(),
      title: title.isEmpty ? fallbackTitle : title,
      folderName: widget.folderName,
      transcript: fullTranscript,
      summary: summary,
      createdAt: DateTime.now().toUtc(),
    );

    context.read<TranscriptBloc>().add(
        SaveTranscriptEvent(newRecord)); // 새로운 노트 저징
  }

  @override
  Widget build(BuildContext context) {
    final summaryService = SummaryService();
    final theme = Theme.of(context);

    final status = context.watch<RecordingBloc>().state.status;
    final bool showLoadingIndicator =
        status == RecordingStatus.initializing ||
            status == RecordingStatus.pausing ||
            status == RecordingStatus.resuming;

    return BlocBuilder<RecordingBloc, RecordingState>(
      builder: (context, state) {
        final displayTranscript = (state.segments + [state.currentWords])
            .join();

        return BlocListener<TranscriptBloc, TranscriptState>(
          listenWhen: (previous, current) => current is TranscriptSaved,
          listener: (context, state) {
            final saved = state as TranscriptSaved;
            context.go(AppRouter.summary.path, extra: (saved.transcript, true));
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
                title: Text( (state.title == "") ? "노트 생성" : state.title, style: theme.textTheme.bodyLarge),
              ),
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 150),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16.0),
                          sliver: SliverToBoxAdapter(
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height - 150 - 32,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: displayTranscript.isEmpty
                                  ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    "녹음버튼을 눌러 시작하세요",
                                    style: TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                                  : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  displayTranscript,
                                  style: theme.textTheme.bodySmall,
                                  softWrap: true,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 150,
                      padding: const EdgeInsets.all(16.0),
                      color: theme.scaffoldBackgroundColor,
                      child: RecordingControlBar(
                        recordDuration: state.duration,
                        controller: context
                            .read<RecordingBloc>()
                            .recorderController,
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
                          _onFinishAndTranslate(
                              context, state, summaryService, state.title,
                              state.meetingContext);
                        },
                        onTranslate: () {
                          // 번역 버튼 액션
                        },
                        translatedSegments: state.segments,
                      ),
                    ),
                  ),

                  if (showLoadingIndicator)
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
