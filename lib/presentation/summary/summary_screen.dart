import 'package:flutter/material.dart';
import 'package:bevert/core/services/pdf_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
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
              // PDF 생성 후 공유
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
          // 요약된 회의록
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
            child: MarkdownBody(
              data: summary,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: const TextStyle(fontSize: 16, color: Colors.white70),
                h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                strong: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
