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
