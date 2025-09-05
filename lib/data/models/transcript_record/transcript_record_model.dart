enum SummaryStatus {
  none,
  processing,
  completed,
  failed,
}

class TranscriptRecord {
  final String id;
  final String title;
  final String folderName;
  final String transcript;
  final String summary;
  final DateTime createdAt;
  final SummaryStatus status;
  final String meetingContext;

  TranscriptRecord({
    required this.id,
    required this.title,
    required this.folderName,
    required this.transcript,
    required this.summary,
    required this.createdAt,
    this.status = SummaryStatus.none,
    this.meetingContext = '',
  });

  factory TranscriptRecord.fromMap(Map<String, dynamic> map) {
    return TranscriptRecord(
      id: map['id'],
      title: map['title'],
      folderName: map['folderName'],
      transcript: map['transcript'],
      summary: map['summary'],
      createdAt: DateTime.parse(map['created_at']),
      status: SummaryStatus.values.firstWhere(
        (e) => e.name == (map['status'] ?? 'none'),
        orElse: () => SummaryStatus.none,
      ),
      meetingContext: map['meeting_context'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'folderName': folderName,
      'transcript': transcript,
      'summary': summary,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'meeting_context': meetingContext,
    };
  }

  TranscriptRecord copyWith({
    String? id,
    String? title,
    String? folderName,
    String? transcript,
    String? summary,
    DateTime? createdAt,
    SummaryStatus? status,
    String? meetingContext,
  }) {
    return TranscriptRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      folderName: folderName ?? this.folderName,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      meetingContext: meetingContext ?? this.meetingContext,
    );
  }
}