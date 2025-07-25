import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/domain/repositories/transcript_record/transcript_repository.dart';

class FetchTranscriptsUseCase {
  final TranscriptRepository _repository;

  FetchTranscriptsUseCase(this._repository);

  Future<List<TranscriptRecord>> call({String? folderName, String? query}) async {
    return await _repository.fetchAllTranscripts(folderName: folderName, query: query);
  }
}

class SaveTranscriptUseCase {
  final TranscriptRepository _repository;

  SaveTranscriptUseCase(this._repository);

  Future<void> call(TranscriptRecord record) async {
    await _repository.saveTranscript(record);
  }
}
