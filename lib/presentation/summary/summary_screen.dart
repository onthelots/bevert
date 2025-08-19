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

  /*
  fromRecord
  - 녹음 이후 Summary : true
  - 일반 Summary 접근 : false
   */
  final bool fromRecord;

  const SummaryScreen({
    super.key,
    required this.transcriptRecord,
    this.fromRecord = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // TabBar View Controller
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(transcriptRecord.title, style: theme.textTheme.titleMedium),

          // action buttons
          leading: fromRecord ? null : const BackButton(),

          // action buttons
          actions: fromRecord
              ? null
              : [

            /// 폴더 이동
            IconButton(
              icon: const Icon(Icons.drive_file_move_outline),
              tooltip: '폴더 이동',
              onPressed: () async {
                final folderState = context.read<FolderBloc>().state;
                if (folderState is! FolderLoaded) return;

                final currentFolderName = transcriptRecord.folderName;

                final selectedFolder = await showDialog<Folder>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('이동할 폴더 선택'),
                    children: folderState.folders
                        .where((folder) => folder.name != currentFolderName)
                        .map((folder) => SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, folder),
                      child: Text(folder.name),
                    ))
                        .toList(),
                  ),
                );

                if (selectedFolder != null && selectedFolder.name != currentFolderName) {
                  context.read<TranscriptBloc>().add(MoveTranscriptEvent(
                    transcriptId: transcriptRecord.id,
                    newFolderName: selectedFolder.name,
                    currentFolderName: currentFolderName,
                  ));

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('노트가 "${selectedFolder.name}" 폴더로 이동되었습니다.')),
                  );
                  context.pop();
                }
              },
            ),

            /// 삭제
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
                          context.read<TranscriptBloc>().add(
                              DeleteTranscriptEvent(transcriptRecord.id, transcriptRecord.folderName));
                          Navigator.pop(dialogContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('노트가 삭제되었습니다.')),
                          );
                          context.pop();
                        },
                        child: const Text('삭제', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),

            /// 공유
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: '공유',
              onPressed: () {
                // 공유 로직 추가 가능
              },
            ),
          ],

          // appBar bottom
          bottom: TabBar(
            dividerColor: theme.scaffoldBackgroundColor,
            indicatorColor: theme.primaryColor,
            tabs: [
              Tab(text: 'AI 문서'),
              Tab(text: '전체 스크립트'),
            ],
            labelStyle: theme.textTheme.labelMedium,
            labelColor: theme.colorScheme.primary,
          ),
        ),

        body: TabBarView(
          children: [
            // Tab1. AI 문서
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: MarkdownBody(
                    data: transcriptRecord.summary,
                    styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                      p: theme.textTheme.bodyMedium,
                      h1: theme.textTheme.titleLarge,
                      h2: theme.textTheme.titleMedium,
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),

            // Tab2. 전체 스크립트
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    transcriptRecord.transcript,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
            ),
          ],
        ),

        bottomNavigationBar: fromRecord
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            minimum: const EdgeInsets.only(bottom: 30),
            child: SizedBox(
              width: double.infinity,
              height: 52,
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
                onPressed: () => context.go(AppRouter.home.path),
              ),
            ),
          ),
        )
            : null,
      ),
    );
  }
}
