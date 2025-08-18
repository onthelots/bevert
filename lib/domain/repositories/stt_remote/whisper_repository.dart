import 'dart:typed_data';
import 'package:bevert/data/data_source/stt_remote/stt_remote_datasource.dart';
import 'package:bevert/domain/entities/stt_remote/audio_transcription.dart';

abstract class WhisperRepository {
  Future<AudioTranscription> transcribe(Uint8List wavData);
}

class WhisperRepositoryImpl implements WhisperRepository {
  final WhisperDataSource dataSource;
  WhisperRepositoryImpl(this.dataSource);

  @override
  Future<AudioTranscription> transcribe(Uint8List wavData) async {
    final text = await dataSource.transcribeAudio(wavData);
    return AudioTranscription(text: text);
  }
}
