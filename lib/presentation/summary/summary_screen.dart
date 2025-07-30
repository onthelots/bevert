import 'package:bevert/core/constants/constants.dart';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:flutter/material.dart';
import 'package:bevert/core/services/pdf_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class SummaryScreen extends StatelessWidget {
  final TranscriptRecord transcriptRecord;
  final bool fromRecord;
  final PdfService _pdfService = PdfService();

  SummaryScreen({
    super.key,
    required this.transcriptRecord,
    this.fromRecord = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(transcriptRecord.title),
        leading: fromRecord
            ? null
            : BackButton(),
        actions: fromRecord
            ? null
            : [
          IconButton(
            icon: const Icon(Icons.drive_file_move_outline),
            tooltip: '폴더 이동',
            onPressed: () async {
              final folderState = context.read<FolderBloc>().state;
              if (folderState is! FolderLoaded) return;

              final selectedFolder = await showDialog<Folder>(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('이동할 폴더 선택'),
                  children: folderState.folders.map((folder) {
                    return SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, folder),
                      child: Text(folder.name),
                    );
                  }).toList(),
                ),
              );

              if (selectedFolder != null && selectedFolder.name != transcriptRecord.folderName) {
                context.read<TranscriptBloc>().add(MoveTranscriptEvent(
                  transcriptId: transcriptRecord.id,
                  newFolderName: selectedFolder.name,
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('노트가 "${selectedFolder.name}" 폴더로 이동되었습니다.')),
                );
                Navigator.pop(context); // 상세 화면 닫기
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: '노트 삭제',
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('노트 삭제'),
                  content: const Text('정말 이 노트를 삭제하시겠습니까?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('취소'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<TranscriptBloc>().add(DeleteTranscriptEvent(transcriptRecord.id));
                        Navigator.pop(dialogContext); // 다이얼로그 닫기
                        Navigator.pop(context); // 상세 화면 닫기
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('노트가 삭제되었습니다.')),
                        );
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: '공유',
            onPressed: () {
              // 공유 로직 추가 가능
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
            child: Text(transcriptRecord.transcript),
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
              data: transcriptRecord.summary,
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
      bottomNavigationBar: fromRecord
          ? Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16), // 좌우 + 하단 여백
        child: SafeArea(
          minimum: const EdgeInsets.only(bottom: 0),
          child: SizedBox(
            width: double.infinity,
            height: 52, // 버튼 높이 넉넉하게
            child: ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('홈으로 이동'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: AppColors.lightPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                context.go(AppRouter.home.path); // or context.go('/');
              },
            ),
          ),
        ),
      )
          : null,
    );
  }
}
