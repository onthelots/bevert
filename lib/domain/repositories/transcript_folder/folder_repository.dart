import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class FolderRepository {
  Future<List<Folder>> fetchFolders();
}

class SupabaseFolderRepository implements FolderRepository {
  final SupabaseClient client;

  SupabaseFolderRepository(this.client);

  @override
  Future<List<Folder>> fetchFolders() async {
    try {
      final data = await client
          .from('folders')
          .select()
          .order('name', ascending: true);

      return (data as List).map((e) => Folder.fromMap(e)).toList();
    } catch (e) {
      throw Exception('폴더 불러오기 실패: $e');
    }
  }
}
