class TranscriptRecord {
  final String id;
  final String title;
  final String folderName;
  final String transcript;
  final String summary;
  final DateTime createdAt;
  final String status; // 'processing', 'completed', 'failed'

  TranscriptRecord({
    required this.id,
    required this.title,
    required this.folderName,
    required this.transcript,
    required this.summary,
    required this.createdAt,
    this.status = 'completed', // 기본값은 'completed'로 설정
  });

  factory TranscriptRecord.fromMap(Map<String, dynamic> map) {
    return TranscriptRecord(
      id: map['id'],
      title: map['title'],
      folderName: map['folderName'],
      transcript: map['transcript'],
      summary: map['summary'],
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'] ?? 'completed', // DB에 status가 없으면 'completed'
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
      'status': status,
    };
  }
}
