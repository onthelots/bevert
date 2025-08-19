import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/domain/repositories/transcript_record/transcript_repository.dart';

// 노트 불러오기
class FetchTranscriptsUseCase {
  final TranscriptRepository _repository;

  FetchTranscriptsUseCase(this._repository);

  Stream<List<TranscriptRecord>> call({String? folderName, String? query}) {
    return _repository.streamAllTranscripts(folderName: folderName, query: query);
  }
}

// 노트 저장
class SaveTranscriptUseCase {
  final TranscriptRepository _repository;

  SaveTranscriptUseCase(this._repository);

  Future<void> call(TranscriptRecord record) async {
    await _repository.saveTranscript(record);
  }
}

// 노트 삭제
class DeleteTranscriptUseCase {
  final TranscriptRepository _repository;

  DeleteTranscriptUseCase(this._repository);

  Future<void> call(String transcriptId) async {
    await _repository.deleteTranscript(transcriptId);
  }
}

// 노트 폴더 이동
class MoveTranscriptUseCase {
  final TranscriptRepository _repository;

  MoveTranscriptUseCase(this._repository);

  Future<void> call({required String transcriptId, required String newFolderName}) async {
    await _repository.updateTranscriptFolder(transcriptId, newFolderName);
  }
}

// 노트 상태 업데이트
class UpdateTranscriptStatusUseCase {
  final TranscriptRepository _repository;

  UpdateTranscriptStatusUseCase(this._repository);

  Future<void> call(String id, String status, String? summary) async {
    await _repository.updateTranscriptStatus(id, status, summary);
  }
}
