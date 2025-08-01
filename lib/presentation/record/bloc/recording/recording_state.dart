enum RecordingStatus {
  idle,          // 대기 상태 (녹음 시작 전)
  initializing,  // 마이크 초기화 중
  recording,     // 녹음 중
  pausing,       // 일시정지 처리 중
  paused,        // 일시정지 완료
  resuming,      // 재개 처리 중
  stopped        // 녹음 종료 완료
}

class RecordingState {
  final RecordingStatus status;
  final List<String> segments;
  final String currentWords;
  final int duration;
  final String title;
  final String meetingContext;

  RecordingState({
    required this.status,
    this.segments = const [],
    this.currentWords = '',
    this.duration = 0,
    this.title = '',
    this.meetingContext = '',
  });

  RecordingState copyWith({
    RecordingStatus? status,
    List<String>? segments,
    String? currentWords,
    int? duration,
    String? title,
    String? meetingContext,
  }) {
    return RecordingState(
      status: status ?? this.status,
      segments: segments ?? this.segments,
      currentWords: currentWords ?? this.currentWords,
      duration: duration ?? this.duration,
      title: title ?? this.title,
      meetingContext: meetingContext ?? this.meetingContext,
    );
  }

  String getStatusText(RecordingStatus status) {
    switch (status) {
      case RecordingStatus.initializing:
        return '마이크 초기화 중';
      case RecordingStatus.recording:
        return '녹음 중';
      case RecordingStatus.pausing:
        return '일시정지 중';
      case RecordingStatus.paused:
        return '일시정지됨';
      case RecordingStatus.resuming:
        return '재개 중';
      case RecordingStatus.stopped:
        return '녹음 종료됨';
      case RecordingStatus.idle:
        return '녹음 대기';
    }
  }
}
