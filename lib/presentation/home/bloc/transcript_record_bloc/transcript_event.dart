import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:equatable/equatable.dart';

abstract class TranscriptEvent extends Equatable {
  const TranscriptEvent();

  @override
  List<Object?> get props => [];
}

class LoadTranscriptsEvent extends TranscriptEvent {
  final String? folderName;
  final String? query;

  LoadTranscriptsEvent({this.folderName, this.query});
}

class SaveTranscriptEvent extends TranscriptEvent {
  final TranscriptRecord record;

  const SaveTranscriptEvent(this.record);

  @override
  List<Object> get props => [record];
}

class DeleteTranscriptEvent extends TranscriptEvent {
  final String transcriptId;
  final String currentFolderName;

  const DeleteTranscriptEvent(this.transcriptId, this.currentFolderName);

  @override
  List<Object> get props => [transcriptId, currentFolderName];
}

class MoveTranscriptEvent extends TranscriptEvent {
  final String transcriptId;
  final String newFolderName;
  final String currentFolderName;

  const MoveTranscriptEvent({required this.transcriptId, required this.newFolderName, required this.currentFolderName});

  @override
  List<Object> get props => [transcriptId, newFolderName, currentFolderName];
}

class UpdateSummaryStatusEvent extends TranscriptEvent {
  final String recordId;
  final SummaryStatus status;
  final String? summary;

  const UpdateSummaryStatusEvent(this.recordId, this.status, [this.summary]);

  @override
  List<Object?> get props => [recordId, status, summary];
}

class SummarizeTranscriptEvent extends TranscriptEvent {
  final String recordId;
  final String meetingContext;
  final String folderName;

  const SummarizeTranscriptEvent({required this.recordId, required this.meetingContext, required this.folderName});

  @override
  List<Object> get props => [recordId, meetingContext, folderName];
}