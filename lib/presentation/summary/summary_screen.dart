import 'package:bevert/core/components/toast_widget.dart';
import 'package:bevert/core/constants/constants.dart';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_state.dart';
import 'package:flutter/material.dart';
import 'package:bevert/core/services/pdf_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class SummaryScreen extends StatelessWidget {
  final TranscriptRecord transcriptRecord;

  const SummaryScreen({
    super.key,
    required this.transcriptRecord,
  });

  // Tab1. AI 요약 화면
  Widget _buildSummaryContent(BuildContext context, ThemeData theme, TranscriptRecord record) {

    // 요약 진행 중일 경우
    if (record.status == SummaryStatus.processing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI가 문서를 요약하고 있습니다...'),
          ],
        ),
      );
    }

    // 요약을 진행하지 않았을 경우
    if (record.summary.isEmpty) {
      return Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.auto_awesome),
          label: const Text('AI 요약하기'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          onPressed: () {
            context.read<TranscriptBloc>().add(
              SummarizeTranscriptEvent(
                recordId: record.id,
                meetingContext: record.meetingContext, // 실제 meetingContext 값 전달
                folderName: record.folderName,
              ),
            );
          },
        ),
      );
    }

    // 요약 완료 (summary 값이 존재할 경우)
    return MarkdownBody(
      data: record.summary,
      styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
        p: theme.textTheme.bodyMedium,
        h1: theme.textTheme.titleLarge,
        h2: theme.textTheme.titleMedium,
        strong: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(transcriptRecord.title, style: theme.textTheme.titleMedium),
          leading: const BackButton(),
          actions: [
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
                                ToastHelper.showSuccess("삭제가 완료되었습니다");
                                context.pop();
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
            BlocBuilder<TranscriptBloc, TranscriptState>(
              builder: (context, state) {
                TranscriptRecord currentRecord = transcriptRecord;
                if (state is TranscriptLoaded) {
                  try {
                    final foundRecord = state.transcripts.firstWhere((r) => r.id == transcriptRecord.id);
                    currentRecord = foundRecord;
                  } catch (e) {
                    currentRecord = transcriptRecord;
                  }
                }

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildSummaryContent(context, theme, currentRecord),
                    ),
                  ),
                );
              },
            ),

            // Tab2. 전체 스크립트
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    transcriptRecord.transcript,
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}