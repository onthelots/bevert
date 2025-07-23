import 'package:bevert/presentation/detail/detail_screen.dart';
import 'package:bevert/presentation/record/record_screen.dart';
import 'package:bevert/services/storage_service.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<Map<String, String>> _meetingLogs = [];

  @override
  void initState() {
    super.initState();
    _loadMeetingLogs();
  }

  Future<void> _loadMeetingLogs() async {
    final logs = await _storageService.loadMeetingLogs();
    setState(() {
      _meetingLogs = logs;
    });
  }

  Future<void> _saveMeetingLogs() async {
    await _storageService.saveMeetingLogs(_meetingLogs);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bevert'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: _meetingLogs.length,
        itemBuilder: (context, index) {
          final log = _meetingLogs[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              title: Text(log['title']!),
              subtitle: Text(log['date']!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(log: log),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newLog = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RecordScreen()),
          );

          if (newLog != null && newLog is Map<String, String>) {
            setState(() {
              _meetingLogs.insert(0, newLog);
            });
            _saveMeetingLogs(); // 변경된 리스트를 저장합니다.
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
