import 'package:bevert/domain/usecases/transcript_record/transcript_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transcript_event.dart';
import 'transcript_state.dart';

class TranscriptBloc extends Bloc<TranscriptEvent, TranscriptState> {
  final FetchTranscriptsUseCase fetchUseCase;
  final SaveTranscriptUseCase saveUseCase;
  final DeleteTranscriptUseCase deleteUseCase;
  final MoveTranscriptUseCase moveUseCase;

  TranscriptBloc(
      this.fetchUseCase,
      this.saveUseCase,
      this.deleteUseCase,
      this.moveUseCase,
      ) : super(TranscriptInitial()) {
    on<LoadTranscriptsEvent>(_onLoad);
    on<SaveTranscriptEvent>(_onSave);
    on<DeleteTranscriptEvent>(_onDelete);
    on<MoveTranscriptEvent>(_onMove);
  }
  Future<void> _onLoad(LoadTranscriptsEvent event, Emitter<TranscriptState> emit) async {
    emit(TranscriptLoading());
    try {
      final records = await fetchUseCase(folderName: event.folderName, query: event.query);
      emit(TranscriptLoaded(records));
    } catch (e) {
      emit(TranscriptError(e.toString()));
    }
  }

  Future<void> _onSave(SaveTranscriptEvent event, Emitter<TranscriptState> emit) async {
    try {
      await saveUseCase(event.record);
      emit(TranscriptSaved(event.record)); // 저장상태 emit
      final updatedRecords = await fetchUseCase();
      emit(TranscriptLoaded(updatedRecords));
    } catch (e) {
      emit(TranscriptError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTranscriptEvent event, Emitter<TranscriptState> emit) async {
    try {
      await deleteUseCase(event.transcriptId);
      add(LoadTranscriptsEvent()); // 삭제 후 목록 새로고침
    } catch (e) {
      emit(TranscriptError('삭제 실패: $e'));
    }
  }

  Future<void> _onMove(MoveTranscriptEvent event, Emitter<TranscriptState> emit) async {
    try {
      await moveUseCase(transcriptId: event.transcriptId, newFolderName: event.newFolderName);
      add(LoadTranscriptsEvent(folderName: event.newFolderName)); // 이동 후 목록 새로고침
    } catch (e) {
      emit(TranscriptError('폴더 이동 실패: $e'));
    }
  }
}
