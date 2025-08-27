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
  final UpdateSummaryStatusUseCase updateStatusUseCase;

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
    on<SummarizeTranscriptEvent>(_onSummarizeTranscript);
    on<UpdateSummaryStatusEvent>((event, emit) async {
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

  Future<void> _onSummarizeTranscript(
      SummarizeTranscriptEvent event,
      Emitter<TranscriptState> emit,
      ) async {
    try {
      // 1. DB 상태를 'processing'으로 변경 -> 스트림이 감지하여 UI 업데이트
      await updateStatusUseCase(event.recordId, SummaryStatus.processing, null);

      // 2. Supabase 함수 호출 (fire and forget)
      final supabase = locator<SupabaseClient>();
      supabase.functions.invoke('summarize', body: {
        'recordId': event.recordId,
        'meetingContext': event.meetingContext,
      }).catchError((e) async {
        // 함수 호출 자체의 실패 처리
        print('Edge Function 호출 실패: $e');
        await updateStatusUseCase(event.recordId, SummaryStatus.failed, 'Edge Function 호출에 실패했습니다.');
      });
    } catch (e) {
      // updateStatusUseCase 실패 처리
      print('상태 업데이트 실패: $e');
      await updateStatusUseCase(event.recordId, SummaryStatus.failed, '상태 업데이트에 실패했습니다.');
    }
  }
}