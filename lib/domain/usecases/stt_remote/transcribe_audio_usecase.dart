import 'dart:typed_data';
import 'package:bevert/domain/entities/stt_remote/audio_transcription.dart';
import 'package:bevert/domain/repositories/stt_remote/whisper_repository.dart';

class TranscribeAudioUseCase {
  final WhisperRepository repository;
  TranscribeAudioUseCase(this.repository);

  Future<AudioTranscription> call(Uint8List wavData) async {
    return repository.transcribe(wavData);
  }
}