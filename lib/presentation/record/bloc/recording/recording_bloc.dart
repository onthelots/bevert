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

  void _onUpdateMeetingInfo(UpdateMeetingInfo event, Emitter<RecordingState> emit) {
    emit(state.copyWith(title: event.title, meetingContext: event.meetingContext));
  }

  void _setupVadHandler(Emitter<RecordingState> emit) {
    _vadHandler!.onFrameProcessed.listen((frame) {
      if (frame.isSpeech > _speechThreshold) {
        _chunkBuffer.addAll(frame.frame.map((e) => (e * 32767).toInt()));
        add(UpdateAmplitude(frame.isSpeech));
      }
    });

    _vadHandler!.onError.listen((msg) => add(SpeechError(msg)));
  }

  Future<void> _onStartRecording(StartRecording event, Emitter<RecordingState> emit) async {
    emit(state.copyWith(status: RecordingStatus.initializing, duration: 0, segments: []));

    final hasPermission = await checkAndRequestMicrophonePermission();
    if (!hasPermission) return emit(state.copyWith(status: RecordingStatus.idle));

    _vadHandler = VadHandler.create(isDebug: false);
    _setupVadHandler(emit);
    await _vadHandler!.startListening();

    _chunkTimer = Timer.periodic(_chunkInterval, (_) => _sendChunk());
    _startTimer();

    emit(state.copyWith(status: RecordingStatus.recording));
  }

  Future<void> _onPauseRecording(PauseRecording event, Emitter<RecordingState> emit) async {
    _chunkTimer?.cancel();
    await _vadHandler!.pauseListening();
    _stopTimer();
    emit(state.copyWith(status: RecordingStatus.paused));
  }

  Future<void> _onResumeRecording(ResumeRecording event, Emitter<RecordingState> emit) async {
    await _vadHandler!.startListening();
    _chunkTimer = Timer.periodic(_chunkInterval, (_) => _sendChunk());
    _startTimer();
    emit(state.copyWith(status: RecordingStatus.recording));
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

  void _sendChunk() {
    if (_chunkBuffer.isEmpty) return;
    final wavData = convertPcmToWav(_chunkBuffer);
    _chunkBuffer.clear();
    add(AudioChunkReceived(wavData));
  }

  Future<void> _onAudioChunkReceived(AudioChunkReceived event, Emitter<RecordingState> emit) async {
    try {
      final transcription = await transcribeAudioUseCase(event.chunk);
      String text = transcription.text;

      // 🔹 전처리
      text = text.trim();
      if (text.isEmpty) return; // 비어있으면 무시

      // 공백 정규화
      text = text.replaceAll(RegExp(r'\s+'), ' ');

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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => add(Tick()));
  }

  void _stopTimer() => _timer?.cancel();

  Future<bool> checkAndRequestMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isDenied) status = await Permission.microphone.request();
    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }
    return status.isGranted;
  }

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

  @override
  Future<void> close() {
    _timer?.cancel();
    _chunkTimer?.cancel();
    _vadHandler?.dispose();
    return super.close();
  }
}
