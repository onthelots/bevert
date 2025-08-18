import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

abstract class WhisperDataSource {
  Future<String> transcribeAudio(Uint8List audioData);
}

class WhisperDataSourceImpl implements WhisperDataSource {
  final Dio dio;

  WhisperDataSourceImpl(this.dio);

  @override
  Future<String> transcribeAudio(Uint8List audioData) async {
    final apiKey = dotenv.env['OPENAI_API_KEY']!;
    final filename = 'audio_${DateTime.now().millisecondsSinceEpoch}.wav';

    print("🔹 Whisper 호출 준비");
    print("🔹 파일 크기: ${audioData.length} bytes");
    print("🔹 파일 이름: $filename");
    print("🔹 API Key 존재 여부: ${apiKey.isNotEmpty}");

    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(audioData, filename: filename),
      'model': 'whisper-1',
    });

    try {
      final response = await dio.post(
        'https://api.openai.com/v1/audio/transcriptions',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            // multipart/form-data는 FormData 사용 시 자동 지정됨
            //'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) {
            // 200번대뿐만 아니라 모든 상태코드 확인
            return true;
          },
        ),
      );

      print("🔹 HTTP 상태 코드: ${response.statusCode}");
      print("🔹 Response data: ${response.data}");

      if (response.statusCode == 200) {
        return response.data['text'] ?? '';
      } else {
        throw Exception('Whisper API error: ${response.statusCode} - ${response.data}');
      }
    } catch (e, st) {
      print("❌ Whisper 호출 예외 발생: $e");
      print(st);
      rethrow;
    }
  }
}
