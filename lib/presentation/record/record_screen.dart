import 'dart:async';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/core/services/summary_service.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:uuid/uuid.dart' show Uuid;
import 'widgets/meeting_info_bottom_sheet.dart';
import 'widgets/recording_control_bar.dart';

class RecordScreen extends StatefulWidget {
  final String folderName;

  const RecordScreen({super.key, this.folderName = '기타'});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late SpeechToText _speechToText;
  bool _isRecording = false;
  bool _isPaused = false;

  Timer? _timer;
  Timer? _silenceTimer;
  int _recordDuration = 0;
  late final RecorderController _recorderController;

  // 입력창 내 할당
  String _currentWords = '';
  final List<String> _translatedSegments = [];

  // Services (요약 및 번역)
  late SummaryService _summaryService;

  // 타이틀 및 맥락
  String _title = '';
  String _meetingContext = '';

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _summaryService = SummaryService();
    _recorderController = RecorderController();
    _initSpeech();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showMeetingInfoDialog(context); // 자동 모달 표시
    });
  }

  /// 녹음 준비
  void _initSpeech() async {
    await _speechToText.initialize(
      onStatus: (status) async {
        debugPrint('🟡 Speech status: $status');
        if (status == 'notListening' && _isRecording && !_isPaused) {
          _stopTimer();
          setState(() {
            _isRecording = false;
          });
        }
      },
      onError: (error) {
        debugPrint('Speech recognition error: $error');
      },
    );

  }

  /// 녹음시작 버튼 분기처리
  void _onMicButtonPressed() {
    if (!_isRecording) {
      _startListening();
    } else if (_isRecording && !_isPaused) {
      _pauseListening();
    } else if (_isRecording && _isPaused) {
      _resumeListening();
    }
  }

  /// 녹음 시작
  void _startListening() {
    _translatedSegments.clear(); // 기록 초기화
    _currentWords = '';
    _recordDuration = 0;

    _speechToText.listen(
      onResult: _onSpeechResult, // 인식결과
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
      localeId: 'ko_KR', // 한국어 설정
    );

    _startTimer(); // 타이머 시작

    setState(() {
      _isRecording = true;
      _isPaused = false;
    });
  }

  // 일시정지
  void _pauseListening() {
    _speechToText.stop();
    _recorderController.pause();
    _stopTimer();
    setState(() {
      _isPaused = true;
    });
  }

  // 재 시작
  void _resumeListening() {
    _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        listenMode: ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
      localeId: 'ko_KR',
    );
    _recorderController.record();
    _startTimer();
    setState(() {
      _isPaused = false;
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    debugPrint('🎯 Final result? ${result.finalResult}');
    debugPrint('🎧 Recognized: "${result.recognizedWords}"');

    setState(() {
      if (result.finalResult) {
        // 최종 결과면 저장
        _translatedSegments.add(result.recognizedWords.trim() + '\n\n');
        _currentWords = '';
        _silenceTimer?.cancel();
      } else {
        // partial 결과는 그냥 보여주기만, 저장은 안 함
        _currentWords = result.recognizedWords;

        // 무음 감지용 타이머 (2초 무음 시 listen 강제 중지)
        _silenceTimer?.cancel();
        _silenceTimer = Timer(const Duration(seconds: 2), () async {
          await _speechToText.stop();
          // 잠시 딜레이 후 자동 재시작
          await Future.delayed(const Duration(milliseconds: 200));
          if (_isRecording && !_isPaused) {
            await _speechToText.listen(
              onResult: _onSpeechResult,
              listenOptions: SpeechListenOptions(
                listenMode: ListenMode.dictation,
                partialResults: true,
                cancelOnError: false,
              ),
              localeId: 'ko_KR',
            );
          }
        });
      }
    });
  }

  /// 녹음 타이머 시작
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordDuration++;
      });
    });
  }

  /// 녹음 타이머 종료
  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _speechToText.stop();
    _timer?.cancel();
    _silenceTimer?.cancel();
    _recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final displayTranscript = (_translatedSegments + [_currentWords]).join();

    return BlocListener<TranscriptBloc, TranscriptState>(
      listenWhen: (previous, current) => current is TranscriptSaved,
      listener: (context, state) {
        final saved = state as TranscriptSaved;
        context.go(AppRouter.summary.path, extra: (saved.transcript, true));
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(_title.isNotEmpty ? _title : '회의 녹음'),
      ),
      body: Stack(
        children: [
          // 스크롤 가능한 텍스트 영역
          Padding(
            padding: const EdgeInsets.only(bottom: 150), // 하단 제어바 공간 확보
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverToBoxAdapter(
                    child: Container(
                      width: double.infinity,
                      // 화면 높이에서 하단 컨트롤바 높이를 뺀 만큼 확보
                      height: MediaQuery.of(context).size.height - 150 - 32,
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
                        child: displayTranscript.isEmpty
                            ? Center(
                          child: Text(
                            "녹음버튼을 눌러 시작하세요",
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            displayTranscript,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                            softWrap: true,
                            textAlign: TextAlign.start,
                          )
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 하단 고정 제어바
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 150,
              padding: const EdgeInsets.all(16.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: RecordingControlBar(
                isPaused: _isPaused,
                isRecording: _isRecording,
                recordDuration: _recordDuration,
                controller: _recorderController,
                onMicTap: _onMicButtonPressed,
                onFinish: _onFinishAndTranslate,
                translatedSegments: _translatedSegments,
                onTranslate: () {  },
              ),
            ),
          ),
        ],
      ),
    ),
);
  }

  // 회의정보 다이어로그
  void _showMeetingInfoDialog(BuildContext context) {
    showModalBottomSheet(
      enableDrag: true,
      showDragHandle: true,
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext modalContext) {
        return MeetingInfoBottomSheet(
          initialTitle: _title,
          initialContext: _meetingContext,
          onSave: (title, contextText) {
            setState(() {
              _title = title;
              _meetingContext = contextText;
            });
          },
        );
      },
    );
  }

  void _showLoadingDialog() {
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

  Future<void> _onFinishAndTranslate() async {
    _pauseListening();
    final fullTranscript = (_translatedSegments + [_currentWords]).join(' ').trim();
    if (fullTranscript.isEmpty) return;
    _showLoadingDialog();
    final summary = await _summaryService.summarize(fullTranscript, context: _meetingContext);

    Navigator.of(context).pop();

    final now = DateTime.now().toLocal();
    final fallbackTitle = '제목없음_${now.toString().substring(0, 16)}';

    final newRecord = TranscriptRecord(
      id: const Uuid().v4(),
      title: _title.isEmpty ? fallbackTitle : _title,
      folderName: widget.folderName,  // 여기에 widget.folderName 사용
      transcript: fullTranscript,
      summary: summary,
      createdAt: DateTime.now().toUtc(),
    );

    context.read<TranscriptBloc>().add(SaveTranscriptEvent(newRecord));
  }
}