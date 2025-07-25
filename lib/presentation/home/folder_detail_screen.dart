import 'package:bevert/core/routes/router.dart';
import 'package:bevert/core/services/format_to_kst.dart';
import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FolderDetailScreen extends StatefulWidget {
  final Folder folder;

  const FolderDetailScreen({
    super.key,
    required this.folder,
  });

  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged(String query) {
    context.read<TranscriptBloc>().add(
      LoadTranscriptsEvent(folderName: widget.folder.name, query: query),
    );
  }

  Map<String, List<TranscriptRecord>> _groupByDate(List<TranscriptRecord> list) {
    Map<String, List<TranscriptRecord>> grouped = {};
    final now = DateTime.now();
    for (var item in list) {
      final date = item.createdAt;
      String key;
      final diff = now.difference(DateTime(date.year, date.month, date.day)).inDays;

      if (diff == 0) {
        key = "오늘";
      } else if (diff == 1) {
        key = "어제";
      } else {
        key = "${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}";
      }

      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.folder.name),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                hintText: '녹음파일 제목을 검색해주세요',
                hintStyle: theme.textTheme.bodyMedium,
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: theme.cardColor,
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.cardColor,
                    width: 0.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                    width: 0.8,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<TranscriptBloc, TranscriptState>(
              builder: (context, state) {
                if (state is TranscriptLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TranscriptLoaded) {
                  final items = state.transcripts;
                  if (items.isEmpty) {
                    return const Center(child: Text('해당 폴더에 문서가 없습니다.'));
                  }

                  final groupedItems = _groupByDate(items);

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: groupedItems.keys.length,
                    itemBuilder: (context, index) {
                      final dateKey = groupedItems.keys.elementAt(index);
                      final group = groupedItems[dateKey]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 날짜 섹션 타이틀
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              dateKey,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),

                          // 날짜별 아이템 리스트
                          ...group.map((transcript) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 1,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              title: Text(
                                transcript.title,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                formatToKST(transcript.createdAt),
                                style: theme.textTheme.bodySmall,
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                context.push(
                                  AppRouter.summary.path,
                                  extra: (transcript.transcript, transcript.summary),
                                );
                              },
                            ),
                          )),
                        ],
                      );
                    },
                  );
                } else if (state is TranscriptError) {
                  return Center(child: Text('오류: ${state.message}'));
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
