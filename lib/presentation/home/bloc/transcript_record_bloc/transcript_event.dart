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

  DeleteTranscriptEvent(this.transcriptId);
}

class MoveTranscriptEvent extends TranscriptEvent {
  final String transcriptId;
  final String newFolderName;

  MoveTranscriptEvent({required this.transcriptId, required this.newFolderName});
}
