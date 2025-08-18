enum RecordingStatus {
  idle,          // 대기 상태 (녹음 시작 전)
  initializing,  // 마이크 초기화 중
  recording,     // 녹음 중
  paused,        // 일시정지 완료
  resuming,      // 재개 처리 중
  stopped        // 녹음 종료 완료
}

class RecordingState {
  final RecordingStatus status;
  final int duration; // 초 단위 녹음 시간
  final List<String> segments; // 실시간 단어/청크 결과
  final String finalTranscript; // 녹음 종료 후 문장 단위 결과
  final String title;
  final String meetingContext;
  final double amplitude;

  RecordingState({
    this.status = RecordingStatus.idle,
    this.duration = 0,
    this.segments = const [],
    this.finalTranscript = "",
    this.title = "",
    this.meetingContext = "",
    this.amplitude = 0.0,
  });

  RecordingState copyWith({
    RecordingStatus? status,
    int? duration,
    List<String>? segments,
    String? finalTranscript,
    String? title,
    String? meetingContext,
    double? amplitude,
  }) {
    return RecordingState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      segments: segments ?? this.segments,
      finalTranscript: finalTranscript ?? this.finalTranscript,
      title: title ?? this.title,
      meetingContext: meetingContext ?? this.meetingContext,
      amplitude: amplitude ?? this.amplitude,
    );
  }

  /// UI에 보여줄 친화적인 상태 텍스트
  String get statusText {
    switch (status) {
      case RecordingStatus.initializing:
        return '마이크 초기화 중';
      case RecordingStatus.recording:
        return '녹음 중';
      case RecordingStatus.paused:
        return '일시정지 완료';
      case RecordingStatus.resuming:
        return '재개 처리 중';
      case RecordingStatus.stopped:
        return '녹음 종료 완료';
      case RecordingStatus.idle:
      return '녹음 대기';
    }
  }
}
