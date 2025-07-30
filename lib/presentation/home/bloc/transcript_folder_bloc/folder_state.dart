import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';

abstract class FolderState {}

class FolderInitial extends FolderState {}

class FolderLoading extends FolderState {}

class FolderLoaded extends FolderState {
  final List<Folder> folders;
  FolderLoaded(this.folders);
}

class FolderError extends FolderState {
  final String message;
  FolderError(this.message);
}

class FolderOperationSuccess extends FolderState {} // 삭제 성공용 상태값