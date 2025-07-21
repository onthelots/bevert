import 'package:flutter/material.dart';

class SummaryScreen extends StatelessWidget {
  final String fullTranscript;
  final String summary;

  const SummaryScreen({
    super.key,
    required this.fullTranscript,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회의록 요약'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
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
            child: Text(fullTranscript),
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
            child: Text(summary),
          ),
        ],
      ),
    );
  }
}
