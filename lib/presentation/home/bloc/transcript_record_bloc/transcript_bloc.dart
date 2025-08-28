import 'package:bevert/core/di/locator.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/domain/usecases/transcript_record/transcript_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'transcript_event.dart';
import 'transcript_state.dart';

class TranscriptBloc extends Bloc<TranscriptEvent, TranscriptState> {
  final FetchTranscriptsUseCase fetchUseCase;
  final SaveTranscriptUseCase saveUseCase;
  final DeleteTranscriptUseCase deleteUseCase;
  final MoveTranscriptUseCase moveUseCase;
  final UpdateSummaryStatusUseCase updateSummaryStatusUseCase;

  TranscriptBloc(
      this.fetchUseCase,
      this.saveUseCase,
      this.deleteUseCase,
      this.moveUseCase,
      this.updateSummaryStatusUseCase,
      ) : super(TranscriptInitial()) {
    on<LoadTranscriptsEvent>(_onLoad);
    on<SaveTranscriptEvent>(_onSave);
    on<DeleteTranscriptEvent>(_onDelete);
    on<MoveTranscriptEvent>(_onMove);
    on<SummarizeTranscriptEvent>(_onSummarizeTranscript);
    on<UpdateSummaryStatusEvent>((event, emit) async {
      try {
        await updateSummaryStatusUseCase(event.recordId, event.status, event.summary);
        add(LoadTranscriptsEvent()); // 상태 업데이트 후 목록 새로고침
      } catch (e) {
        emit(TranscriptError('Failed to update transcript status: ${e.toString()}'));
      }
    });
  }

  /// 데이터 Stream (forEach)
  Future<void> _onLoad(LoadTranscriptsEvent event, Emitter<TranscriptState> emit) async {
    emit(TranscriptLoading());
    try {
      await emit.forEach(
        fetchUseCase(folderName: event.folderName, query: event.query),

        // 새로운 데이터 (onData)가 도착할 때 마다 콜백 실행 (List<TranscriptRecord>)
        onData: (records) {
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

  Future<void> _onSummarizeTranscript(
      SummarizeTranscriptEvent event,
      Emitter<TranscriptState> emit,
      ) async {

    // 1. 현재 상태가 TranscriptLoaded인지, 데이터가 있는지 확인
    if (state is! TranscriptLoaded) return;
    final currentState = state as TranscriptLoaded;
    final List<TranscriptRecord> currentTranscripts = List.from(currentState.transcripts);

    // 2. 목록에서 해당 레코드의 인덱스 찾기
    final int recordIndex = currentTranscripts.indexWhere((r) => r.id == event.recordId);
    if (recordIndex == -1) return; // 레코드를 찾지 못하면 종료

    // 3. 레코드를 "processing" 상태로 즉시 업데이트 (Optimistic UI)
    final originalRecord = currentTranscripts[recordIndex];
    final processingRecord = originalRecord.copyWith(status: SummaryStatus.processing);
    currentTranscripts[recordIndex] = processingRecord;

    // 4. 변경된 목록으로 UI 즉시 갱신
    emit(TranscriptLoaded(currentTranscripts));

    try {
      // 5. Supabase 함수를 백그라운드에서 호출
      final supabase = locator<SupabaseClient>();
      await supabase.functions.invoke('summarize', body: {
        'recordId': event.recordId,
        'meetingContext': event.meetingContext,
      });
    } catch (e) {
      // 6. 함수 호출 실패 시, 상태를 "failed"로 업데이트
      final failedRecord = originalRecord.copyWith(status: SummaryStatus.failed, summary: '요약 처리 중 오류가 발생했습니다.');
      currentTranscripts[recordIndex] = failedRecord;
      emit(TranscriptLoaded(currentTranscripts));
    }
  }
}
