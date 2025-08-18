class TranscriptRecord {
  final String id;
  final String title;
  final String folderName;
  final String transcript;
  final String summary;
  final DateTime createdAt;

  TranscriptRecord({
    required this.id,
    required this.title,
    required this.folderName,
    required this.transcript,
    required this.summary,
    required this.createdAt,
  });

  factory TranscriptRecord.fromMap(Map<String, dynamic> map) {
    return TranscriptRecord(
      id: map['id'],
      title: map['title'],
      folderName: map['folderName'],
      transcript: map['transcript'],
      summary: map['summary'],
      createdAt: DateTime.parse(map['created_at']),
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
    };
  }
}
