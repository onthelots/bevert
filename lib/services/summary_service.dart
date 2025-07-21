import 'package:firebase_ai/firebase_ai.dart';

class SummaryService {
  // Initialize the Vertex AI service
  final _vertexAI = FirebaseAI.vertexAI();

  Future<String> summarize(String transcript) async {
    try {
      // Select the Gemini model
      final model = _vertexAI.generativeModel(model: 'gemini-pro');

      // Create the prompt
      final prompt = '다음 회의 스크립트를 핵심 주제, 결정 사항, 실행 항목(Action Items)으로 구분하여 전문적인 회의록 형태로 요약해줘:\n\n$transcript';
      final content = [Content.text(prompt)];

      // Get the summary
      final response = await model.generateContent(content);

      return response.text ?? '요약 생성에 실패했습니다.';
    } catch (e) {
      print('Firebase AI Error: $e');
      return '요약 중 오류가 발생했습니다.';
    }
  }
}