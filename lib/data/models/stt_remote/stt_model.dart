class SttResponse {
  final int result;
  final String recognized;

  SttResponse({
    required this.result,
    required this.recognized,
  });

  factory SttResponse.fromJson(Map<String, dynamic> json) {
    return SttResponse(
      result: json['result'] ?? -1,
      recognized: json['return_object']?['recognized'] ?? "",
    );
  }
}
