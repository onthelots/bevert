import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_event.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final SpeechToText speechToText;
  final RecorderController recorderController;

  Timer? _timer;
  Timer? _silenceTimer;

  RecordingBloc({
    required this.speechToText,
    required this.recorderController,
  }) : super(RecordingState(status: RecordingStatus.idle)) {
    on<UpdateMeetingInfo>(_onUpdateMeetingInfo);
    on<StartRecording>(_onStartRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<StopRecording>(_onStopRecording);
    on<SpeechResultReceived>(_onSpeechResultReceived);
    on<Tick>(_onTick);
  }

  /// 노트 정보 업데이트
  void _onUpdateMeetingInfo(UpdateMeetingInfo event, Emitter<RecordingState> emit) {
    emit(state.copyWith(
      title: event.title,
      meetingContext: event.meetingContext,
    ));
  }

  /// 첫 녹음 시작
  Future<void> _onStartRecording(StartRecording event, Emitter<RecordingState> emit) async {
    emit(state.copyWith(
      status: RecordingStatus.initializing,
      duration: 0,
      segments: [],
      currentWords: '',
    ));

    try {
      // 로딩 인디케이터를 보여줄 최소 시간(0.3초)을 확보합니다.
      final start = DateTime.now();
      await speechToText.listen(
        onResult: (result) => add(SpeechResultReceived(result)),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
        ),
        localeId: 'ko_KR',
      );

      final end = DateTime.now();
      final elapsed = end.difference(start);
      if (elapsed.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
      }

      recorderController.record();
      _startTimer();
      emit(state.copyWith(status: RecordingStatus.recording));
    } catch (e) {
      print("Error starting recording: $e");
      emit(state.copyWith(status: RecordingStatus.idle));
    }
  }

  /// 녹음 일시정지
  Future<void> _onPauseRecording(PauseRecording event, Emitter<RecordingState> emit) async {
    emit(state.copyWith(status: RecordingStatus.pausing));

    try {
      final start = DateTime.now();
      await speechToText.stop();

      final end = DateTime.now();
      final elapsed = end.difference(start);
      if (elapsed.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
      }

      recorderController.pause();
      _stopTimer();
      emit(state.copyWith(status: RecordingStatus.paused));

    } catch (e) {
      print("Error pausing recording: $e");
      emit(state.copyWith(status: RecordingStatus.recording));
    }
  }

  /// 녹음 재개
  Future<void> _onResumeRecording(ResumeRecording event, Emitter<RecordingState> emit) async {
    emit(state.copyWith(status: RecordingStatus.resuming));
    try {
      final start = DateTime.now();
      await speechToText.listen(
        onResult: (result) => add(SpeechResultReceived(result)),
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
        ),
        localeId: 'ko_KR',
      );

      final end = DateTime.now();
      final elapsed = end.difference(start);
      if (elapsed.inMilliseconds < 1000) {
        await Future.delayed(Duration(milliseconds: 1000 - elapsed.inMilliseconds));
      }

      recorderController.record();
      _startTimer();
      emit(state.copyWith(status: RecordingStatus.recording));

    } catch (e) {
      print("Error resuming recording: $e");
      emit(state.copyWith(status: RecordingStatus.paused));
    }
  }

  /// 녹음 종료
  Future<void> _onStopRecording(StopRecording event, Emitter<RecordingState> emit) async {
    try {
      await speechToText.stop();
      recorderController.pause();
      _stopTimer();
      emit(state.copyWith(status: RecordingStatus.stopped));

    } catch (e) {
      print("Error stopping recording: $e");
      emit(state.copyWith(status: RecordingStatus.stopped));
    }
  }

  /// 녹음 결과 전달
  void _onSpeechResultReceived(SpeechResultReceived event, Emitter<RecordingState> emit) {
    final result = event.result;
    final segments = List<String>.from(state.segments);
    String currentWords = state.currentWords;

    if (result.finalResult) {
      segments.add(result.recognizedWords.trim() + '\n\n');
      currentWords = '';
      _silenceTimer?.cancel();
    } else {
      currentWords = result.recognizedWords;

      _silenceTimer?.cancel();
      _silenceTimer = Timer(const Duration(seconds: 2), () async {
        await speechToText.stop();
        await Future.delayed(const Duration(milliseconds: 100));
        if (state.status == RecordingStatus.recording) {
          await speechToText.listen(
            onResult: (result) => add(SpeechResultReceived(result)),
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

    emit(state.copyWith(segments: segments, currentWords: currentWords));
  }

  void _onTick(Tick event, Emitter<RecordingState> emit) {
    if (state.status == RecordingStatus.recording) {
      emit(state.copyWith(duration: state.duration + 1));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(Tick());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _silenceTimer?.cancel();
    speechToText.stop();
    recorderController.dispose();
    print("Recording Bloc 해제");
    return super.close();
  }
}
