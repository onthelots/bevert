import 'package:firebase_ai/firebase_ai.dart'; // firebase_ai 패키지를 import 합니다.
import 'package:firebase_core/firebase_core.dart'; // Firebase 초기화를 위해 필요합니다.

class SummaryService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

  Future<String> summarize(String transcript, {String? context}) async {
    try {
      final contextLine = (context != null && context.isNotEmpty)
          ? '회의 주제는 다음과 같습니다:\n"$context"\n\n'
          : '';

      final prompt = '''
${contextLine}다음 회의 스크립트를 핵심 주제, 결정 사항, 실행 항목(Action Items)으로 구분하여 전문적인 회의록 형태로 요약해줘:\n\n$transcript
''';

      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);
      return response.text ?? '요약 생성에 실패했습니다.';
    } catch (e) {
      print('Firebase AI Logic Error during summarization: $e');
      return '요약 중 오류가 발생했습니다.';
    }
  }
}
