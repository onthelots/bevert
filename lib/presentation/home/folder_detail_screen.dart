import 'package:bevert/core/components/empty_list_placeholder.dart';
import 'package:bevert/core/components/toast_widget.dart';
import 'package:bevert/core/constants/app_asset.dart';
import 'package:bevert/core/constants/constants.dart';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/core/services/helper/format_to_kst.dart';
import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_state.dart';
import 'package:bevert/presentation/home/widgets/folder_delete_dialog.dart';
import 'package:bevert/presentation/home/widgets/folder_management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_down_button/pull_down_button.dart';

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

  late String _folderName;
  late Color _folderColor;

  @override
  void initState() {
    super.initState();
    _folderName = widget.folder.name;
    _folderColor = widget.folder.color;
  }

  void _onSearchChanged(String query) {
    context.read<TranscriptBloc>().add(
      LoadTranscriptsEvent(folderName: widget.folder.name, query: query),
    );
  }

  Map<String, List<TranscriptRecord>> _groupByDate(
      List<TranscriptRecord> list) {
    Map<String, List<TranscriptRecord>> grouped = {};
    final now = DateTime.now();
    for (var item in list) {
      final date = item.createdAt;
      String key;
      final diff = now
          .difference(DateTime(date.year, date.month, date.day))
          .inDays;

      if (diff == 0) {
        key = "오늘";
      } else if (diff == 1) {
        key = "어제";
      } else {
        key = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
            .toString().padLeft(2, '0')}";
      }

      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<FolderBloc, FolderState>(
      listener: (context, state) {
        if (state is FolderError) {
          ToastHelper.showError(state.message); // toast 띄우기
          context.read<FolderBloc>().add(LoadFoldersEvent()); // 폴더 load
        } else if (state is FolderOperationSuccess) {
          context.pop();
          ToastHelper.showSuccess("폴더가 삭제되었습니다"); // toast 띄우기
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.folder, color: _folderColor),
              SizedBox(width: 8,),
              Text(_folderName, style: theme.textTheme.bodyLarge,),
            ],
          ),
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
          foregroundColor: theme.textTheme.bodyLarge?.color,
          actions: [
            PullDownButton(
              itemBuilder: (context) => [
                if (_folderName != '기타')
                  PullDownMenuItem(
                    title: '폴더 삭제',
                    icon: Icons.delete,
                    iconColor: Colors.redAccent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => DeleteFolderDialog(
                          folderName: widget.folder.name,
                          onConfirmDelete: () {
                            dialogContext.read<FolderBloc>().add(
                                DeleteFolderEvent(widget.folder.id));
                          },
                        ),
                      );
                    },
                  ),
                if (_folderName != '기타')
                  PullDownMenuItem(
                    title: '폴더 수정',
                    icon: Icons.edit_note,
                    onTap: () async {
                      final folderState = context.read<FolderBloc>().state;
                      if (folderState is FolderLoaded) {
                        final editResult = await FolderManagementDialog.show(
                          context,
                          existingFolders: folderState.folders,
                          folderToEdit: widget.folder,
                        );

                        if (editResult != null) {
                          setState(() {
                            _folderName = editResult.name;
                            _folderColor = editResult.color;
                          });
                        }
                      }
                    },
                  ),
                PullDownMenuItem(
                  title: '노트 생성',
                  icon: Icons.voicemail_outlined,
                  onTap: () {
                    context.push(
                      AppRouter.recording.path,
                      extra: widget.folder.name,
                    );
                  },
                ),
              ],
              position: PullDownMenuPosition.automatic,
              buttonBuilder: (context, showMenu) => IconButton(
                icon: Icon(Icons.adaptive.more),
                onPressed: showMenu,
              ),
            ),
          ],
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
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15, horizontal: 12),
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

                    print("노트가 몇개있어요?: ${state.transcripts.length}");
                    print("Transcripts: ${state.transcripts.map((e) => e.title).toList()}");

                    if (items.isEmpty) {
                      return EmptyListPlaceholder(
                        message: '해당 폴더에 저장된 노트가 없어요',
                        icon: Icons.sentiment_neutral_outlined,
                      );
                    }

                    final groupedItems = _groupByDate(items);

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                                style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),

                            // 날짜별 아이템 리스트
                            ...group.map((transcript) =>
                                Dismissible(
                                  key: Key(transcript.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    color: Colors.redAccent,
                                    child: const Icon(
                                        Icons.delete, color: Colors.white),
                                  ),
                                  confirmDismiss: (direction) async {
                                    return await showDialog(
                                      context: context,
                                      builder: (context) =>
                                          AlertDialog(
                                            title: const Text('노트 삭제'),
                                            content: Text('정말 "${transcript
                                                .title}"을(를) 삭제하시겠습니까?'),
                                            actions: [
                                              TextButton(onPressed: () =>
                                                  Navigator.of(context).pop(
                                                      false),
                                                  child: const Text('취소')),
                                              TextButton(
                                                onPressed: () {
                                                  context.read<TranscriptBloc>()
                                                      .add(
                                                      DeleteTranscriptEvent(
                                                          transcript.id, transcript.folderName));
                                                  Navigator.of(context).pop(
                                                      true);
                                                },
                                                child: const Text('삭제',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                    );
                                  },

                                  /// 노트(transcript) Card
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 6),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    child: ListTile(
                                      title: Text(transcript.title, maxLines: 1,
                                          overflow: TextOverflow.ellipsis, style: theme.textTheme.titleSmall,),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              formatToKST(transcript.createdAt), style: theme.textTheme.labelSmall,),
                                          if (transcript.status == 'processing')
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                '요약 중...',
                                                style: theme.textTheme.labelSmall?.copyWith(color: theme.focusColor), // 요약 중 색상
                                              ),
                                            )
                                          else if (transcript.status == 'failed')
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(
                                                '요약 실패',
                                                style: theme.textTheme.labelSmall?.copyWith(color: Colors.red), // 요약 실패 색상
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: const Icon(Icons.chevron_right),
                                        onTap: () {
                                          context.push(
                                            AppRouter.summary.path,
                                            extra: (transcript, false),
                                          );
                                        }
                                    ),
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
      ),
    );
  }
}
