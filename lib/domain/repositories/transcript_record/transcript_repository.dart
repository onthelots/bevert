import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TranscriptRepository {
  Future<List<TranscriptRecord>> fetchAllTranscripts({String? folderName, String? query});
  Future<void> saveTranscript(TranscriptRecord record);
}

class SupabaseTranscriptRepository implements TranscriptRepository {
  final SupabaseClient _client;

  SupabaseTranscriptRepository(this._client);

  @override
  Future<List<TranscriptRecord>> fetchAllTranscripts({String? folderName, String? query}) async {
    try {
      var queryBuilder = _client
          .from('transcripts')
          .select()
          .order('created_at', ascending: false);

      // Fetch all data first
      final data = await queryBuilder;
      List<TranscriptRecord> allTranscripts = (data as List).map((e) => TranscriptRecord.fromMap(e)).toList();

      // Apply filters in application code
      if (folderName != null) {
        allTranscripts = allTranscripts.where((record) => record.folderName == folderName).toList();
      }

      if (query != null && query.isNotEmpty) {
        final lowerCaseQuery = query.toLowerCase();
        allTranscripts = allTranscripts.where((record) => record.title.toLowerCase().contains(lowerCaseQuery)).toList();
      }

      return allTranscripts;
    } catch (e) {
      throw Exception('Failed to fetch transcripts: $e');
    }
  }


  @override
  Future<void> saveTranscript(TranscriptRecord record) async {
    try {
      await _client.from('transcripts').insert(record.toMap());
    } catch (e) {
      throw Exception('Failed to save transcript: $e');
    }
  }
}
