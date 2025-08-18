import 'package:firebase_ai/firebase_ai.dart'; // firebase_ai 패키지를 import 합니다.
import 'package:firebase_core/firebase_core.dart'; // Firebase 초기화를 위해 필요합니다.

class SummaryService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

  Future<String> summarize(String transcript, {String? context}) async {
    try {
      final contextLine = (context != null && context.isNotEmpty)
          ? '회의 주제: "$context"\n\n'
          : '';

      final prompt = '''
${contextLine}다음 회의 내용을 전문적인 회의록 형태로 작성해주세요. 회의록에는 다음 항목이 포함되어야 합니다:

- 회의 제목
- 회의 일시
- 참석자
- 안건 및 논의 내용
- 결정 사항

회의 스크립트:
$transcript

각 항목을 명확히 구분하고, 간결하고 공식적인 문서 스타일로 작성해주세요.
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

