import 'dart:typed_data';

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

/// amplitude 업데이트
class UpdateAmplitude extends RecordingEvent {
  final double amplitude; // 0.0 ~ 1.0
  UpdateAmplitude(this.amplitude);
}

/// 주기적 타이머 tick
class Tick extends RecordingEvent {}

/// 원시 오디오 청크 수신 (Whisper STT 호출)
class AudioChunkReceived extends RecordingEvent {
  final Uint8List chunk;
  AudioChunkReceived(this.chunk);
}

/// VAD 프레임 이벤트 (필요 시)
class SpeechFrameReceived extends RecordingEvent {
  final List<int> frame;
  SpeechFrameReceived(this.frame);
}

/// VAD 오류 처리
class SpeechError extends RecordingEvent {
  final String message;
  SpeechError(this.message);
}
