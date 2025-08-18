import 'dart:typed_data';

import 'package:bevert/data/models/stt_remote/stt_model.dart';
import 'package:bevert/domain/repositories/stt_remote/stt_repository.dart';

class RecognizeUseCase {
  final SttRepository repository;

  RecognizeUseCase(this.repository);

  Future<SttResponse> call(Uint8List chunk, String languageCode) {
    return repository.recognize(chunk, languageCode);
  }
}