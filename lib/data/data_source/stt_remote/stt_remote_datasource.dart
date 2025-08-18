import 'dart:convert';
import 'dart:typed_data';
import 'package:bevert/data/models/stt_remote/stt_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class SttRemoteDataSource {
  final String baseUrl = "http://epretx.etri.re.kr:8000/api/WiseASR_Recognition";
  final String accessKey;
  final Dio dio;

  SttRemoteDataSource(this.accessKey, {Dio? dio}) : dio = dio ?? Dio();

  Future<SttResponse> recognize(Uint8List audioChunk, String languageCode) async {
    try {
      final audioBase64 = base64Encode(audioChunk);

      final requestJson = {
        "argument": {
          "language_code": languageCode,
          "audio": audioBase64,
        }
      };

      final response = await dio.post(
        baseUrl,
        options: Options(
          headers: {
            "Content-Type": "application/json; charset=UTF-8",
            "Authorization": accessKey,
          },
        ),
        data: jsonEncode(requestJson),
      );

      // 🔹 전체 응답 타입과 내용
      debugPrint("🔊 [STT raw response] type=${response.data.runtimeType}, data=${response.data}");

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonData;

        if (response.data is Map<String, dynamic>) {
          jsonData = response.data;
        } else if (response.data is String) {
          jsonData = jsonDecode(response.data);
        } else {
          throw Exception("Unexpected response format: ${response.data.runtimeType}");
        }

        // 🔹 인식된 텍스트 추출
        final recognizedText = jsonData['return_object']?['recognized'] ?? "[인식 실패]";
        debugPrint("📝 [STT recognized text] $recognizedText");

        // STT 모델로 변환
        final sttResponse = SttResponse.fromJson(jsonData);

        // 🔹 모델 변환 결과 확인
        debugPrint("✅ [STT parsed response] $sttResponse");

        return sttResponse;
      } else {
        throw Exception("STT API failed: ${response.statusCode}");
      }
    } catch (e, stack) {
      debugPrint("❌ STT API error: $e");
      debugPrint("$stack");
      throw Exception("STT API error: $e");
    }
  }
}
