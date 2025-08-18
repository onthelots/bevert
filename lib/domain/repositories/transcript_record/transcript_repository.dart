import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TranscriptRepository {
  Future<List<TranscriptRecord>> fetchAllTranscripts({String? folderName, String? query});
  Future<void> saveTranscript(TranscriptRecord record);
  Future<void> updateFolderNameForTranscripts(String oldName, String newName);
  Future<void> deleteTranscript(String transcriptId); // 추가
  Future<void> updateTranscriptFolder(String id, String newFolderName);
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

  @override
  Future<void> updateFolderNameForTranscripts(String oldName,
      String newName) async {
    await _client
        .from('transcripts')
        .update({'folderName': newName})
        .eq('folderName', oldName);
  }

  @override
  Future<void> deleteTranscript(String transcriptId) async {
    try {
      await _client
          .from('transcripts')
          .delete()
          .eq('id', transcriptId);
    } catch (e) {
      throw Exception('Failed to delete transcript: $e');
    }
  }

  Future<void> updateTranscriptFolder(String id, String newFolderName) async {
    try {
      await _client
          .from('transcripts')
          .update({'folderName': newFolderName})
          .eq('id', id);
    } catch (e) {
      throw Exception('노트 폴더 이동 실패: $e');
    }
  }
}
