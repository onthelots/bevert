import 'dart:async';
import 'dart:typed_data';
import 'package:bevert/domain/usecases/stt_remote/transcribe_audio_usecase.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_event.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vad/vad.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {
  final TranscribeAudioUseCase transcribeAudioUseCase;

  Timer? _timer;
  Timer? _chunkTimer;
  final List<int> _chunkBuffer = [];
  VadHandlerBase? _vadHandler;
  final double _speechThreshold = 0.5; // 잡음 제거 위해 높임
  final Duration _chunkInterval = const Duration(seconds: 10); // 청크 간격 조정

  RecordingBloc({required this.transcribeAudioUseCase}) : super(RecordingState()) {
    on<UpdateMeetingInfo>(_onUpdateMeetingInfo);
    on<StartRecording>(_onStartRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<StopRecording>(_onStopRecording);
    on<Tick>(_onTick);
    on<AudioChunkReceived>(_onAudioChunkReceived);
    on<UpdateAmplitude>((event, emit) {
      emit(state.copyWith(amplitude: event.amplitude));
    });
    on<SpeechError>((event, emit) {
      debugPrint("VAD Error: ${event.message}");
    });
  }

  /// 회의 사전정보 입력 (optional)
  void _onUpdateMeetingInfo(UpdateMeetingInfo event, Emitter<RecordingState> emit) {
    emit(state.copyWith(title: event.title, meetingContext: event.meetingContext));
  }

  /// VAD Setup (listen을 통해 _chunkBuffer에 음성을 할당함)
  void _setupVadHandler(Emitter<RecordingState> emit) {
    _vadHandler!.onFrameProcessed.listen((frame) {

      // 음성(frame)의 인식 정도를 높임 (_speechThreshold의 수치를 임의로 0.5로 설정, 이보다 높아야 _chunk에 할당)
      if (frame.isSpeech > _speechThreshold) {
        _chunkBuffer.addAll(frame.frame.map((e) => (e * 32767).toInt()));
        add(UpdateAmplitude(frame.isSpeech)); // Speech animation
      }
    });

    // 에러 발생
    _vadHandler!.onError.listen((msg) => add(SpeechError(msg)));
  }

  /// 녹음 시작 (최초 실행)
  Future<void> _onStartRecording(StartRecording event, Emitter<RecordingState> emit) async {
    emit(state.copyWith(status: RecordingStatus.initializing, duration: 0, segments: []));

    final hasPermission = await checkAndRequestMicrophonePermission();
    if (!hasPermission) return emit(state.copyWith(status: RecordingStatus.idle));

    _vadHandler = VadHandler.create(isDebug: false); // 1. VAD 생성
    _setupVadHandler(emit); // 2. VAD 세팅 (음성인식 감지 외)
    await _vadHandler!.startListening(); // 3. 세팅 후, Listening 시작

    // 4. 청크 타이머 (_chunkInterval, 10초마다 강제 전송 _sendChunk)
    _chunkTimer = Timer.periodic(_chunkInterval, (_) => _sendChunk());
    _startTimer(); // 5. 일반 타이머 재생

    emit(state.copyWith(status: RecordingStatus.recording)); // 6. 상태 : recording으로 변경
  }

  /// 녹음 일시정지
  Future<void> _onPauseRecording(PauseRecording event, Emitter<RecordingState> emit) async {
    _chunkTimer?.cancel(); // 1. 청크 타이머 취소
    await _vadHandler!.pauseListening(); // 2. VAD 일시정지
    _stopTimer(); // 3. 일반 타이머 정지
    emit(state.copyWith(status: RecordingStatus.paused)); // 4. 상태 : paused
  }


  Future<void> _onStopRecording(StopRecording event, Emitter<RecordingState> emit) async {
    _chunkTimer?.cancel();
    _stopTimer();
    if (_chunkBuffer.isNotEmpty) _sendChunk();
    await _vadHandler?.stopListening();
    await _vadHandler?.dispose();
    _vadHandler = null;
    emit(state.copyWith(status: RecordingStatus.stopped));
  }

  /// 녹음 재개 (최초 start와 달리, _vadHalder 세팅 관련된 사항 제외)
  Future<void> _onResumeRecording(ResumeRecording event, Emitter<RecordingState> emit) async {
    await _vadHandler!.startListening(); // 1. VAD 재 시작
    _chunkTimer = Timer.periodic(_chunkInterval, (_) => _sendChunk()); // 2. 청크 타이머 재 시작
    _startTimer(); // 3. 일반 타이머 시작
    emit(state.copyWith(status: RecordingStatus.recording)); // 4. 상태 : recording
  }

  /// 청크 전송 (잘라서)
  void _sendChunk() {
    if (_chunkBuffer.isEmpty) return;
    final wavData = convertPcmToWav(_chunkBuffer);
    _chunkBuffer.clear();
    add(AudioChunkReceived(wavData));
  }

  /// 청크 전송 (STT 기능 실행)
  Future<void> _onAudioChunkReceived(AudioChunkReceived event, Emitter<RecordingState> emit) async {
    try {

      // 1. STT 실행 (event에 저장된 chunk wavData)
      final transcription = await transcribeAudioUseCase(event.chunk);

      // 2. wavData 내 텍스트 추출
      String text = transcription.text;

      // - 전처리
      text = text.trim();
      if (text.isEmpty) return; // 비어있으면 무시

      // - 공백 정규화
      text = text.replaceAll(RegExp(r'\s+'), ' ');

      // 3. 세그먼트(실시간 화면) 내 STT를 통해 변환된 텍스트 할당
      final updatedSegments = List<String>.from(state.segments)..add(text);
      emit(state.copyWith(segments: updatedSegments));

    } catch (e) {
      debugPrint("Whisper transcription error: $e");
    }
  }

  void _onTick(Tick event, Emitter<RecordingState> emit) {
    if (state.status == RecordingStatus.recording) {
      emit(state.copyWith(duration: state.duration + 1));
    }
  }

  /// 일반 타이머 시작
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(Tick()));
  }

  /// 일반 타이머 종료
  void _stopTimer() => _timer?.cancel();

  /// 녹음 권한 확인
  Future<bool> checkAndRequestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  /// Wav Data 생성 <--- VAD 음성데이터 기반
  Uint8List convertPcmToWav(List<int> pcmData) {
    const sampleRate = 16000;
    const numChannels = 1;
    const bitsPerSample = 16;

    final pcmBytes = Uint8List(pcmData.length * 2);
    final byteData = ByteData.view(pcmBytes.buffer);
    for (int i = 0; i < pcmData.length; i++) {
      int sample = pcmData[i];
      if (sample > 32767) sample = 32767;
      if (sample < -32768) sample = -32768;
      byteData.setInt16(i * 2, sample, Endian.little);
    }

    final header = ByteData(44);
    header.setUint8(0, 'R'.codeUnitAt(0));
    header.setUint8(1, 'I'.codeUnitAt(0));
    header.setUint8(2, 'F'.codeUnitAt(0));
    header.setUint8(3, 'F'.codeUnitAt(0));
    header.setUint32(4, 36 + pcmBytes.length, Endian.little);
    header.setUint8(8, 'W'.codeUnitAt(0));
    header.setUint8(9, 'A'.codeUnitAt(0));
    header.setUint8(10, 'V'.codeUnitAt(0));
    header.setUint8(11, 'E'.codeUnitAt(0));
    header.setUint8(12, 'f'.codeUnitAt(0));
    header.setUint8(13, 'm'.codeUnitAt(0));
    header.setUint8(14, 't'.codeUnitAt(0));
    header.setUint8(15, ' '.codeUnitAt(0));
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * numChannels * (bitsPerSample ~/ 8), Endian.little);
    header.setUint16(32, numChannels * (bitsPerSample ~/ 8), Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    header.setUint8(36, 'd'.codeUnitAt(0));
    header.setUint8(37, 'a'.codeUnitAt(0));
    header.setUint8(38, 't'.codeUnitAt(0));
    header.setUint8(39, 'a'.codeUnitAt(0));
    header.setUint32(40, pcmBytes.length, Endian.little);

    return Uint8List.fromList(header.buffer.asUint8List() + pcmBytes);
  }

  /// dispose 정리
  @override
  Future<void> close() {
    _timer?.cancel();
    _chunkTimer?.cancel();
    _vadHandler?.dispose();
    return super.close();
  }
}
