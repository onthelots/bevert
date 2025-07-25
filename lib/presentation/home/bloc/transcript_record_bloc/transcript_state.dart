import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';

abstract class TranscriptState {}

class TranscriptInitial extends TranscriptState {}

class TranscriptLoading extends TranscriptState {}

class TranscriptLoaded extends TranscriptState {
  final List<TranscriptRecord> transcripts;

  TranscriptLoaded(this.transcripts);
}

class TranscriptError extends TranscriptState {
  final String message;

  TranscriptError(this.message);
}
