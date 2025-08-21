import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';

abstract class TranscriptEvent {}

class LoadTranscriptsEvent extends TranscriptEvent {
  final String? folderName;
  final String? query;

  LoadTranscriptsEvent({this.folderName, this.query});
}

class SaveTranscriptEvent extends TranscriptEvent {
  final TranscriptRecord record;

  SaveTranscriptEvent(this.record);
}

class DeleteTranscriptEvent extends TranscriptEvent {
  final String transcriptId;
  final String currentFolderName;

  DeleteTranscriptEvent(this.transcriptId, this.currentFolderName);
}

class MoveTranscriptEvent extends TranscriptEvent {
  final String transcriptId;
  final String newFolderName;
  final String currentFolderName;

  MoveTranscriptEvent({required this.transcriptId, required this.newFolderName, required this.currentFolderName});
}

class UpdateStatusEvent extends TranscriptEvent {
  final String recordId;
  final String status;
  final String? summary; // 실패 시 에러 메시지를 담을 수 있음

  UpdateStatusEvent(this.recordId, this.status, [this.summary]);

  @override
  List<Object?> get props => [recordId, status, summary];
}
