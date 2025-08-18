class TranscriptSegment {
  final String text;
  final bool isDraft; // 로컬 STT 초안인지 여부
  final DateTime timestamp;

  TranscriptSegment({
    required this.text,
    this.isDraft = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  TranscriptSegment copyWith({
    String? text,
    bool? isDraft,
    DateTime? timestamp,
  }) {
    return TranscriptSegment(
      text: text ?? this.text,
      isDraft: isDraft ?? this.isDraft,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
