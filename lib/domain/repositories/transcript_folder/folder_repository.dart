import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FolderRepository {
  Future<List<Folder>> fetchFolders();
  Future<void> createFolder(String name, String colorHex);
  Future<void> deleteFolder(String id);
  Future<void> updateFolder(String id, String newName, String newColorHex);
}

class SupabaseFolderRepository implements FolderRepository {
  final SupabaseClient _client;

  SupabaseFolderRepository(this._client);

  @override
  Future<List<Folder>> fetchFolders() async {
    try {
      final data = await _client
          .from('folders')
          .select()
          .order('created_at', ascending: false); // 최신 생성순, 내림차순 (가장 최근에 생성된 폴더가 위쪽으로 올라오도록)
      return (data as List).map((e) => Folder.fromMap(e)).toList();
    } catch (e) {
      throw Exception('폴더 불러오기 실패: $e');
    }
  }

  @override
  Future<void> createFolder(String name, String colorHex) async {
    try {
      await _client.from('folders').insert({
        'name': name,
        'color_hex': colorHex,
      });
    } catch (e) {
      throw Exception('폴더 생성 실패: $e');
    }
  }

  @override
  Future<void> deleteFolder(String id) async {
    try {
      // 1. 해당 폴더 이름 가져오기
      final folderData = await _client
          .from('folders')
          .select()
          .eq('id', id)
          .single();

      final folderName = folderData['name'] as String;

      // 2. 해당 폴더에 속한 transcripts 삭제
      await _client
          .from('transcripts')
          .delete()
          .eq('folderName', folderName);

      // 3. 폴더 삭제
      await _client
          .from('folders')
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('폴더 삭제 실패: $e');
    }
  }

  @override
  Future<void> updateFolder(String id, String newName, String newColorHex) async {
    try {

      await _client
          .from('folders')
          .update({
        'name': newName,
        'color_hex': newColorHex,
      })
          .eq('id', id);
    } catch (e) {
      throw Exception('폴더 수정 실패: $e');
    }
  }
}

