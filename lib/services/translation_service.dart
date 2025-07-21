import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationService {
  final String _apiKey = dotenv.env['GOOGLE_CLOUD_API_KEY']!;
  final String _apiUrl = 'https://translation.googleapis.com/language/translate/v2';

  Future<String> translate(String text, {String targetLanguage = 'ko'}) async {
    if (text.trim().isEmpty) return '';

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
          'key': _apiKey,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['data']['translations'][0]['translatedText'];
      } else {
        print('Translation API Error: ${response.body}');
        return 'Translation Error';
      }
    } catch (e) {
      print('Translation request failed: $e');
      return 'Translation Error';
    }
  }
}
