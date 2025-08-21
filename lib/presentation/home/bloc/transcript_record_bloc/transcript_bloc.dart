import 'package:bevert/domain/usecases/transcript_record/transcript_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transcript_event.dart';
import 'transcript_state.dart';

class TranscriptBloc extends Bloc<TranscriptEvent, TranscriptState> {
  final FetchTranscriptsUseCase fetchUseCase;
  final SaveTranscriptUseCase saveUseCase;
  final DeleteTranscriptUseCase deleteUseCase;
  final MoveTranscriptUseCase moveUseCase;
  final UpdateTranscriptStatusUseCase updateStatusUseCase;

  TranscriptBloc(
      this.fetchUseCase,
      this.saveUseCase,
      this.deleteUseCase,
      this.moveUseCase,
      this.updateStatusUseCase,
      ) : super(TranscriptInitial()) {
    on<LoadTranscriptsEvent>(_onLoad);
    on<SaveTranscriptEvent>(_onSave);
    on<DeleteTranscriptEvent>(_onDelete);
    on<MoveTranscriptEvent>(_onMove);
    on<UpdateStatusEvent>((event, emit) async {
      try {
        await updateStatusUseCase(event.recordId, event.status, event.summary);
        add(LoadTranscriptsEvent()); // 상태 업데이트 후 목록 새로고침
      } catch (e) {
        emit(TranscriptError('Failed to update transcript status: ${e.toString()}'));
      }
    });
  }
  Future<void> _onLoad(LoadTranscriptsEvent event, Emitter<TranscriptState> emit) async {
    emit(TranscriptLoading());
    try {
      await emit.forEach(
        fetchUseCase(folderName: event.folderName, query: event.query),
        onData: (records) {
          print("Stream data received. Records count: ${records.length}");
          return TranscriptLoaded(records);
        },
        onError: (error, stackTrace) {
          print("Stream error: $error");
          return TranscriptError(error.toString());
        },
      );
    } catch (e) {
      emit(TranscriptError(e.toString()));
    }
  }

  Future<void> _onSave(SaveTranscriptEvent event, Emitter<TranscriptState> emit) async {
    try {
      await saveUseCase(event.record);
      emit(TranscriptSaved(event.record)); // 저장상태 emit
    } catch (e) {
      emit(TranscriptError(e.toString()));
    }
  }

  Future<void> _onDelete(DeleteTranscriptEvent event, Emitter<TranscriptState> emit) async {
    try {
      await deleteUseCase(event.transcriptId);
      add(LoadTranscriptsEvent(folderName: event.currentFolderName));
    } catch (e) {
      emit(TranscriptError('삭제 실패: $e'));
    }
  }

  Future<void> _onMove(MoveTranscriptEvent event, Emitter<TranscriptState> emit) async {
    try {
      await moveUseCase(transcriptId: event.transcriptId, newFolderName: event.newFolderName);
      add(LoadTranscriptsEvent(folderName: event.currentFolderName));
    } catch (e) {
      emit(TranscriptError('폴더 이동 실패: $e'));
    }
  }
}
