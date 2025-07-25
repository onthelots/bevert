import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/domain/repositories/transcript_folder/folder_repository.dart';

class FetchFoldersUseCase {
  final FolderRepository _repository;

  FetchFoldersUseCase(this._repository);

  Future<List<Folder>> call() async {
    return await _repository.fetchFolders();
  }
}
