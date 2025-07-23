import 'package:firebase_ai/firebase_ai.dart'; // firebase_ai 패키지를 import 합니다.
import 'package:firebase_core/firebase_core.dart'; // Firebase 초기화를 위해 필요합니다.

class SummaryService {
  final GenerativeModel _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

  Future<String> summarize(String transcript) async {
    try {
      final prompt = '다음 회의 스크립트를 핵심 주제, 결정 사항, 실행 항목(Action Items)으로 구분하여 전문적인 회의록 형태로 요약해줘:\n\n$transcript';
      final content = [Content.text(prompt)];

      // 모델에 요약 요청을 보냅니다.
      final response = await _model.generateContent(content);

      // 응답에서 텍스트를 추출하여 반환합니다.
      return response.text ?? '요약 생성에 실패했습니다.';
    } catch (e) {
      // 오류 발생 시 콘솔에 출력하고, 사용자에게 알릴 메시지를 반환합니다.
      print('Firebase AI Logic Error during summarization: $e');
      return '요약 중 오류가 발생했습니다.';
    }
  }
}