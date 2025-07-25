import 'package:bevert/domain/usecases/transcript_record/transcript_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'transcript_event.dart';
import 'transcript_state.dart';

class TranscriptBloc extends Bloc<TranscriptEvent, TranscriptState> {
  final FetchTranscriptsUseCase fetchUseCase;
  final SaveTranscriptUseCase saveUseCase;

  TranscriptBloc(this.fetchUseCase, this.saveUseCase) : super(TranscriptInitial()) {
    on<LoadTranscriptsEvent>(_onLoad);
    on<SaveTranscriptEvent>(_onSave);
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
      final updatedRecords = await fetchUseCase();
      emit(TranscriptLoaded(updatedRecords));
    } catch (e) {
      emit(TranscriptError(e.toString()));
    }
  }
}
