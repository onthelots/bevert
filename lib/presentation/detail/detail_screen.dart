import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, String> log;

  const DetailScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(log['title'] ?? '회의록 상세'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            '저장 일시: ${log["date"]}',
            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
          const SizedBox(height: 24.0),
          const Text(
            '요약된 회의록',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(log['summary'] ?? '요약 내용이 없습니다.'),
          ),
          const SizedBox(height: 24.0),
          const Text(
            '전체 스크립트',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(log['transcript'] ?? '스크립트가 없습니다.'),
          ),
        ],
      ),
    );
  }
}
