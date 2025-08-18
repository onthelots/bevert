import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class TranslationService {
  final String _apiKey = Platform.isIOS
      ? dotenv.env['IOS_TRANSLATION_API_KEY'] ?? ''
      : dotenv.env['ANDROID_TRANSLATION_API_KEY'] ?? '';

  final String _apiUrl = 'https://translation.googleapis.com/language/translate/v2';

  TranslationService() {
    if (_apiKey.isEmpty) {
      print('[TranslationService] Warning: API Key is empty!');
    } else {
      print('[TranslationService] Loaded API Key: ${_apiKey.substring(0, 5)}******');
    }
  }

  Future<String> translate(String text, {String targetLanguage = 'ko'}) async {
    if (text.trim().isEmpty) return '';

    final url = '$_apiUrl?key=$_apiKey';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'q': text,
          'target': targetLanguage,
        }),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final translatedText = body['data']['translations'][0]['translatedText'];
        return translatedText;
      } else {
        return 'Translation Error';
      }
    } catch (e) {
      return 'Translation Error';
    }
  }
}
