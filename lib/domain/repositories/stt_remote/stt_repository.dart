import 'dart:typed_data';

import 'package:bevert/data/data_source/stt_remote/stt_remote_datasource.dart';
import 'package:bevert/data/models/stt_remote/stt_model.dart';

abstract class SttRepository {
  Future<SttResponse> recognize(Uint8List chunk, String languageCode);
}

class SttRepositoryImpl implements SttRepository {
  final SttRemoteDataSource remoteDataSource;

  SttRepositoryImpl(this.remoteDataSource);

  @override
  Future<SttResponse> recognize(Uint8List chunk, String languageCode) {
    return remoteDataSource.recognize(chunk, languageCode);
  }
}
