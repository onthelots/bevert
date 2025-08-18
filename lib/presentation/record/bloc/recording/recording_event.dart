import 'dart:typed_data';

/// 모든 이벤트의 베이스 클래스
abstract class RecordingEvent {}

/// 회의 정보 업데이트
class UpdateMeetingInfo extends RecordingEvent {
  final String title;
  final String meetingContext;
  UpdateMeetingInfo(this.title, this.meetingContext);
}

/// 기본적인 녹음 제어
class StartRecording extends RecordingEvent {}
class PauseRecording extends RecordingEvent {}
class ResumeRecording extends RecordingEvent {}
class StopRecording extends RecordingEvent {}
class UpdateAmplitude extends RecordingEvent {
  final double amplitude; // 0.0 ~ 1.0
  UpdateAmplitude(this.amplitude);
}

/// 주기적 타이머 tick
class Tick extends RecordingEvent {}

/// 청크 준비됨 (예: 일정 크기 이상 쌓였을 때)
class ChunkReady extends RecordingEvent {
  final int size;
  ChunkReady(this.size);
}

/// 원시 오디오 청크 수신
class AudioChunkReceived extends RecordingEvent {
  final Uint8List chunk;
  AudioChunkReceived(this.chunk);
}

/// 🎤 VAD 관련 이벤트들
class SpeechStarted extends RecordingEvent {}
class SpeechEnded extends RecordingEvent {
  final int sampleCount;
  SpeechEnded(this.sampleCount);
}
class SpeechFrameReceived extends RecordingEvent {
  final List<int> frame;
  SpeechFrameReceived(this.frame);
}
class SpeechError extends RecordingEvent {
  final String message;
  SpeechError(this.message);
}