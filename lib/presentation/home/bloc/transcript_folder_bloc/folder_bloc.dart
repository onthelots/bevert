import 'package:bevert/domain/usecases/transcript_folder/folder_usecase.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final FetchFoldersUseCase fetchUseCase;

  FolderBloc(this.fetchUseCase) : super(FolderInitial()) {
    on<LoadFoldersEvent>(_onLoad);
  }

  Future<void> _onLoad(LoadFoldersEvent event, Emitter<FolderState> emit) async {
    emit(FolderLoading());
    try {
      final folders = await fetchUseCase();
      emit(FolderLoaded(folders));
    } catch (e) {
      emit(FolderError(e.toString()));
    }
  }
}
