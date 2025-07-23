import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _logsKey = 'meeting_logs';

  Future<void> saveMeetingLogs(List<Map<String, String>> logs) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = jsonEncode(logs);
    await prefs.setString(_logsKey, logsJson);
  }

  Future<List<Map<String, String>>> loadMeetingLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getString(_logsKey);
    if (logsJson != null) {
      final List<dynamic> decodedJson = jsonDecode(logsJson);
      return decodedJson.map((e) => Map<String, String>.from(e)).toList();
    }
    return [];
  }
}
