import 'package:bevert/domain/usecases/transcript_folder/folder_usecase.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final FetchFoldersUseCase fetchUseCase;
  final CreateFolderUseCase createUseCase;
  final DeleteFolderUseCase deleteUseCase;
  final UpdateFolderUseCase updateUseCase;

  FolderBloc(
      this.fetchUseCase,
      this.createUseCase,
      this.deleteUseCase,
      this.updateUseCase,
      ) : super(FolderInitial()) {
    on<LoadFoldersEvent>(_onLoad);
    on<CreateFolderEvent>(_onCreate);
    on<DeleteFolderEvent>(_onDelete);
    on<UpdateFolderEvent>(_onUpdate);
  }

  // 불러오기
  Future<void> _onLoad(LoadFoldersEvent event, Emitter<FolderState> emit) async {
    emit(FolderLoading());
    try {
      final folders = await fetchUseCase();
      emit(FolderLoaded(folders));
    } catch (e) {
      emit(FolderError('데이터를 불러오지 못했어요'));
    }
  }

  // 생성
  Future<void> _onCreate(CreateFolderEvent event, Emitter<FolderState> emit) async {
    emit(FolderLoading());
    try {
      await createUseCase(event.folderName, event.colorHex);
      final folders = await fetchUseCase();
      emit(FolderLoaded(folders));
    } catch (e) {
      emit(FolderError('폴더 생성에 실패했습니다'));
    }
  }

  // 삭제
  Future<void> _onDelete(DeleteFolderEvent event, Emitter<FolderState> emit) async {
    emit(FolderLoading());
    try {
      await deleteUseCase(event.folderId);
      emit(FolderOperationSuccess());
      final folders = await fetchUseCase();
      emit(FolderLoaded(folders));
    } catch (e) {
      emit(FolderError('폴더를 삭제할 수 없습니다'));
    }
  }

  // 수정
  Future<void> _onUpdate(UpdateFolderEvent event, Emitter<FolderState> emit) async {
    emit(FolderLoading());
    try {
      await updateUseCase(
        folderId: event.folderId,
        oldName: event.oldName,
        newName: event.newName,
        newColorHex: event.newColorHex,
      );
      final folders = await fetchUseCase();
      emit(FolderLoaded(folders));
    } catch (e) {
      emit(FolderError('폴더 정보를 수정할 수 없습니다'));
    }
  }
}