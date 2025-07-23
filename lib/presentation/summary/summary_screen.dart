import 'package:bevert/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SummaryScreen extends StatelessWidget {
  final String fullTranscript;
  final String summary;
  final PdfService _pdfService = PdfService();

  SummaryScreen({
    super.key,
    required this.fullTranscript,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('회의록 요약'),
        actions: [

          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () async {
              final pdfPath = await _pdfService.createPdf(
                "Meeting Summary",
                fullTranscript,
                summary,
              );

              final result = await SharePlus.instance.share(
                ShareParams(
                  text: '회의록 요약입니다.',
                  files: [XFile(pdfPath)],
                ),
              );

              if (result.status == ShareResultStatus.success) {
                print('파일 공유 완료!');
              } else if (result.status == ShareResultStatus.dismissed) {
                print('공유가 취소되었습니다.');
              }
            },
          ),

          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // TODO: Implement a more robust way to get the title
              final newLog = {
                "title": "새로운 회의록",
                "date": "2024년 7월 24일", // Should be dynamic
                "summary": summary,
                "transcript": fullTranscript,
              };
              Navigator.of(context).pop(newLog);
            },
          ),
        ],
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
