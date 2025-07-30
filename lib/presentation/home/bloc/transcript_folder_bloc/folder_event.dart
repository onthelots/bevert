abstract class FolderEvent {}

class LoadFoldersEvent extends FolderEvent {}

// 생성
class CreateFolderEvent extends FolderEvent {
  final String folderName;
  final String colorHex;
  CreateFolderEvent(this.folderName, this.colorHex);
}

// 삭제
class DeleteFolderEvent extends FolderEvent {
  final String folderId;
  DeleteFolderEvent(this.folderId);
}

// 수정
class UpdateFolderEvent extends FolderEvent {
  final String folderId;
  final String oldName;
  final String newName;
  final String newColorHex;

  UpdateFolderEvent({
    required this.folderId,
    required this.oldName,
    required this.newName,
    required this.newColorHex,
  });
}