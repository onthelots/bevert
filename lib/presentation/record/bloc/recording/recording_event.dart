import 'package:speech_to_text/speech_recognition_result.dart';

abstract class RecordingEvent {}

// 노트정보 할당
class UpdateMeetingInfo extends RecordingEvent {
  final String title;
  final String meetingContext;

  UpdateMeetingInfo(this.title, this.meetingContext);
}

// 녹음 시작
class StartRecording extends RecordingEvent {}

class PauseRecording extends RecordingEvent {}

class ResumeRecording extends RecordingEvent {}

class StopRecording extends RecordingEvent {}

class SpeechResultReceived extends RecordingEvent {
  final SpeechRecognitionResult result;
  SpeechResultReceived(this.result);
}

class Tick extends RecordingEvent {} // 타이머 tick 이벤트