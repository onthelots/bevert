import 'dart:async';
import 'dart:typed_data';
import 'package:bevert/presentation/record/bloc/recording/recording_event.dart';
import 'package:bevert/presentation/record/bloc/recording/recording_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vad/vad.dart';

class RecordingBloc extends Bloc<RecordingEvent, RecordingState> {

  /// 녹음 진행 시간을 추적하는 타이머
  Timer? _timer;

  /// 음성 데이터를 주기적으로 청크(chunk)로 만들기 위한 타이머
  Timer? _chunkTimer;

  /// VAD가 감지한 음성 프레임(16-bit PCM)을 임시로 저장하는 버퍼
  final List<int> _chunkBuffer = [];

  /// VAD 패키지 핸들러
  VadHandlerBase? _vadHandler;

  /// 음성 감지 민감도 (0.0 ~ 1.0). 낮을수록 민감함.
  final double _speechThreshold = 0.3;

  /// 음성 데이터를 몇 초 간격으로 묶어서 처리할지 결정
  final Duration _chunkInterval = const Duration(seconds: 8);

  RecordingBloc() : super(RecordingState()) {
    // 각 이벤트 매핑
    on<UpdateMeetingInfo>(_onUpdateMeetingInfo);
    on<StartRecording>(_onStartRecording);
    on<PauseRecording>(_onPauseRecording);
    on<ResumeRecording>(_onResumeRecording);
    on<StopRecording>(_onStopRecording);
    on<Tick>(_onTick);
    on<ChunkReady>(_onChunkReady);
    on<AudioChunkReceived>(_onAudioChunkReceived);
    on<UpdateAmplitude>((event, emit) {
      emit(state.copyWith(amplitude: event.amplitude));
    });

    on<SpeechStarted>((event, emit) {
      emit(state.copyWith(segments: [...state.segments, "🟢 Speech started"]));
    });

    on<SpeechEnded>((event, emit) {
      emit(state.copyWith(
          segments: [...state.segments, "🔴 Speech ended (${event.sampleCount} samples)"]));
    });

    on<SpeechError>((event, emit) {
      debugPrint("VAD Error: ${event.message}");
    });
  }

  /// 회의 제목, 맥락 정보 업데이트
  void _onUpdateMeetingInfo(UpdateMeetingInfo event, Emitter<RecordingState> emit) {
    emit(state.copyWith(
      title: event.title,
      meetingContext: event.meetingContext,
    ));
  }

  /// VAD 이벤트 리스너 설정
  void _setupVadHandler(Emitter<RecordingState> emit) {
    _vadHandler!.onFrameProcessed.listen((frame) {
      final amplitude = frame.isSpeech;
      if (frame.isSpeech > _speechThreshold) {
        _chunkBuffer.addAll(frame.frame.map((e) => (e * 32767).toInt()));
        print("🗣️ 발화중 : ${amplitude}");
        add(UpdateAmplitude(amplitude));
      }
    });


    _vadHandler!.onSpeechStart.listen((_) {
      add(SpeechStarted());
    });

    _vadHandler!.onSpeechEnd.listen((samples) {
      add(SpeechEnded(samples.length));
    });

    _vadHandler!.onError.listen((msg) {
      add(SpeechError(msg));
    });
  }

  /// 녹음 시작 이벤트 처리
  Future<void> _onStartRecording(StartRecording event, Emitter<RecordingState> emit) async {
    emit(state.copyWith(
      status: RecordingStatus.initializing,
      duration: 0,
      segments: [],
    ));

    // 1. 마이크 권한 확인
    final hasPermission = await checkAndRequestMicrophonePermission();
    if (!hasPermission) {
      emit(state.copyWith(status: RecordingStatus.idle));
      return;
    }

    // 2. VAD 핸들러 생성 및 리스너 연결
    _vadHandler = VadHandler.create(isDebug: false);
    _setupVadHandler(emit);

    // 3. VAD 마이크 입력 시작
    await _vadHandler!.startListening();

    // 4. 타이머 시작
    _chunkTimer = Timer.periodic(_chunkInterval, (_) => _sendChunk());
    _startTimer();

    emit(state.copyWith(status: RecordingStatus.recording));
  }

  /// 녹음 일시정지 이벤트 처리
  Future<void> _onPauseRecording(PauseRecording event, Emitter<RecordingState> emit) async {
    _chunkTimer?.cancel();
    await _vadHandler!.pauseListening();
    _stopTimer();

    emit(state.copyWith(status: RecordingStatus.paused));
  }

  /// 녹음 재개 이벤트 처리
  Future<void> _onResumeRecording(ResumeRecording event, Emitter<RecordingState> emit) async {
    await _vadHandler!.startListening();
    _chunkTimer = Timer.periodic(_chunkInterval, (_) => _sendChunk());
    _startTimer();
    emit(state.copyWith(status: RecordingStatus.recording));
  }

  /// 녹음 종료 이벤트 처리
  Future<void> _onStopRecording(StopRecording event, Emitter<RecordingState> emit) async {
    _chunkTimer?.cancel();
    _stopTimer();

    if (_chunkBuffer.isNotEmpty) _sendChunk();
    await _vadHandler?.stopListening();
    await _vadHandler?.dispose();
    _vadHandler = null;

    emit(state.copyWith(status: RecordingStatus.stopped));
  }

  /// 청크 전송
  void _sendChunk() {
    if (_chunkBuffer.isEmpty) return;

    final audioData = _convertPcmToWav(_chunkBuffer);
    _chunkBuffer.clear();

    // Whisper 같은 STT API에 전달할 수 있음
    add(AudioChunkReceived(audioData));
  }

  /// ChunkReady 이벤트 처리 (단순히 크기만 보고 로그 기록)
  void _onChunkReady(ChunkReady event, Emitter<RecordingState> emit) {
    debugPrint("📦 ChunkReady 이벤트 발생, size: ${event.size}");
  }

  /// AudioChunkReceived 이벤트 처리 (STT 연동 자리)
  void _onAudioChunkReceived(AudioChunkReceived event, Emitter<RecordingState> emit) {
    debugPrint("🎧 AudioChunkReceived, bytes: ${event.chunk.length}");

    // 여기서 실제 STT API 호출 후 transcript 결과를 받아서
    // emit(state.copyWith(segments: [...state.segments, transcript]));
  }

  /// 1초마다 녹음 시간을 증가
  void _onTick(Tick event, Emitter<RecordingState> emit) {
    if (state.status == RecordingStatus.recording) {
      emit(state.copyWith(duration: state.duration + 1));
    }
  }

  //==================================================================
  // Private Helpers
  //==================================================================

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(Tick()));
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<bool> checkAndRequestMicrophonePermission() async {
    PermissionStatus status = await Permission.microphone.status;
    if (status.isDenied) status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

  Uint8List _convertPcmToWav(List<int> pcmData) {
    final sampleRate = 16000;
    final numChannels = 1;
    final bitsPerSample = 16;

    final byteData = ByteData(pcmData.length * 2);
    for (int i = 0; i < pcmData.length; i++) {
      byteData.setInt16(i * 2, pcmData[i], Endian.little);
    }
    final pcmBytes = byteData.buffer.asUint8List();

    final header = ByteData(44);
    header.setUint32(0, 0x46464952, Endian.big); // "RIFF"
    header.setUint32(4, 36 + pcmBytes.length, Endian.little);
    header.setUint32(8, 0x45564157, Endian.big); // "WAVE"
    header.setUint32(12, 0x20746d66, Endian.big); // "fmt "
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, numChannels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, sampleRate * numChannels * (bitsPerSample ~/ 8), Endian.little);
    header.setUint16(32, numChannels * (bitsPerSample ~/ 8), Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    header.setUint32(36, 0x61746164, Endian.big); // "data"
    header.setUint32(40, pcmBytes.length, Endian.little);

    return Uint8List.fromList(header.buffer.asUint8List() + pcmBytes);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _chunkTimer?.cancel();
    _vadHandler?.dispose();
    return super.close();
  }
}
