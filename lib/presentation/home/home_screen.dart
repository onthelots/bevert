import 'package:bevert/core/components/toast_widget.dart';
import 'package:bevert/core/constants/app_asset.dart';
import 'package:bevert/core/constants/constants.dart';
import 'package:bevert/core/routes/router.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_event.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:bevert/presentation/home/widgets/folder_management_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAsset.icon.icon_circle_light, height: 20),
              const SizedBox(width: 8),
              Text("BeVERT", style: theme.textTheme.labelLarge),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_rounded),
            tooltip: '설정',
            onPressed: () {
              ToastHelper.showInfo("기능을 준비중입니다");
            },
          ),
        ],
        backgroundColor: theme.cardColor,
        elevation: 1,
      ),

      // drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const ClampingScrollPhysics(),
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppColors.lightPrimary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(AppAsset.icon.icon_original, height: 25),
                  const SizedBox(height: 30),
                  Text("Be heard. Be clear",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,)),
                  const SizedBox(height: 5),
                  Text("BeVert",
                      style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.calendar_month_outlined),
              title: Text('날짜별 노트', style: theme.textTheme.bodyLarge),
              onTap: () {
                context.push(AppRouter.calendar.path);
              },
            ),
            Divider(
              color: theme.dividerColor,
            ),
            ListTile(
              leading: const Icon(Icons.tonality),
              title: Text('테마 설정', style: theme.textTheme.bodyLarge),
              onTap: () {
                context.push(AppRouter.theme.path);
              },
            ),
          ],
        ),
      ),
      body: BlocBuilder<FolderBloc, FolderState>(
        builder: (context, state) {
          if (state is FolderLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FolderLoaded) {
            final folders = state.folders;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: ListView.builder(
                itemCount: folders.length,
                itemBuilder: (context, index) {
                  final folder = folders[index];
                  return Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.folder, color: folder.color),
                        title: Text(
                          folder.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        contentPadding: const EdgeInsets.symmetric(vertical: 2),
                        onTap: () {
                          context.read<TranscriptBloc>().add(
                              LoadTranscriptsEvent(folderName: folder.name));
                          context.push(
                              AppRouter.folderDetail.path, extra: folder);
                        },
                      ),
                    ],
                  );
                },
              ),
            );
          } else if (state is FolderError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('데이터를 불러올 수 없습니다'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context.read<FolderBloc>().add(LoadFoldersEvent()),
                    child: Text('다시 불러오기', style: theme.textTheme.titleMedium,),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        // 기본 + 아이콘
        activeIcon: Icons.close,
        // 눌렀을 때 X 아이콘
        animationCurve: Curves.easeInOut,
        // 기본값인데, 다른 곡선도 시도 가능
        animationDuration: const Duration(milliseconds: 100),
        backgroundColor: AppColors.lightPrimary,
        activeBackgroundColor: AppColors.lightTertiary,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 15,
        spaceBetweenChildren: 8,
        shape: const CircleBorder(),
        children: [
          SpeedDialChild(
            backgroundColor: theme.colorScheme.secondary,
            // 배경색
            foregroundColor: Colors.white,
            // 아이콘 색상
            labelBackgroundColor: theme.colorScheme.secondary,
            // 라벨 배경색
            labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white),
            child: const Icon(Icons.create_new_folder),
            label: '폴더 생성',
            onTap: () {
              final folderState = context
                  .read<FolderBloc>()
                  .state;
              if (folderState is FolderLoaded) {
                FolderManagementDialog.show(
                    context, existingFolders: folderState.folders);
              }
            },
          ),

          SpeedDialChild(
            backgroundColor: AppColors.darkAccentDarker,
            // 배경색
            foregroundColor: Colors.white,
            // 아이콘 색상
            labelBackgroundColor: AppColors.darkAccentDarker,
            // 라벨 배경색
            labelStyle: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white),
            child: const Icon(Icons.voicemail_outlined),
            label: '빠른 노트 생성',
            onTap: () {
              context.push(AppRouter.recording.path, extra: '기타');
            },
          ),
        ],
      ),
    );
  }
}
