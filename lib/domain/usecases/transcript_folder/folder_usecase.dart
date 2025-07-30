import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/domain/repositories/transcript_folder/folder_repository.dart';
import 'package:bevert/domain/repositories/transcript_record/transcript_repository.dart';

class FetchFoldersUseCase {
  final FolderRepository _repository;

  FetchFoldersUseCase(this._repository);

  Future<List<Folder>> call() async {
    return await _repository.fetchFolders();
  }
}

class CreateFolderUseCase {
  final FolderRepository _repository;

  CreateFolderUseCase(this._repository);

  Future<void> call(String name, String colorHex) async {
    await _repository.createFolder(name, colorHex);
  }
}

class DeleteFolderUseCase {
  final FolderRepository _repository;

  DeleteFolderUseCase(this._repository);

  Future<void> call(String id) async {
    await _repository.deleteFolder(id);
  }
}

class UpdateFolderUseCase {
  final FolderRepository _folderRepo;
  final TranscriptRepository _transcriptRepo;

  UpdateFolderUseCase(this._folderRepo, this._transcriptRepo);

  Future<void> call({
    required String folderId,
    required String oldName,
    required String newName,
    required String newColorHex,
  }) async {
    await _folderRepo.updateFolder(folderId, newName, newColorHex);
    await _transcriptRepo.updateFolderNameForTranscripts(oldName, newName);
  }
}
