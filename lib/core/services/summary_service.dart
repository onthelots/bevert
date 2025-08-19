import 'package:firebase_ai/firebase_ai.dart'; // firebase_ai 패키지를 import 합니다.

class SummaryService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

  Future<String> summarize(String transcript, {String? context}) async {
    try {
      final contextLine = (context != null && context.isNotEmpty)
          ? '회의 주제: "$context"\n\n'
          : '';

      final prompt = '''
${contextLine}다음 회의 내용을 전문적인 회의록 형태로 작성해야해. 회의록에이 포함되어야 해:

1. 개요
- 회의주제(내용 요약)
- 일시
- 참석자
- 장소

2. 요약
- 주요 안건

3. 주요 내용
- 

회의 스크립트는 다음과 같습니다:
$transcript

각 항목을 명확히 구분하고, 간결하고 공식적인 문서 스타일로 작성해줘.
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

