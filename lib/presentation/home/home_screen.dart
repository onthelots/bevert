import 'package:bevert/core/routes/router.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_record_bloc/transcript_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
            "BeVERT", style: theme.textTheme.labelLarge),
        automaticallyImplyLeading: true,
        backgroundColor: theme.cardColor,
        elevation: 1,
      ),

      // drawer
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.account_circle, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text('사용자 이름',
                      style: TextStyle(color: Colors.white, fontSize: 18)),
                  Text('email@example.com',
                      style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('내 회의록'),
              onTap: () {
                Navigator.pop(context); // 닫고
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('설정'),
              onTap: () {
                // TODO: 설정 화면으로 이동
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('로그아웃'),
              onTap: () {
                // TODO: 로그아웃 로직 추가
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
            return ListView.builder(
              itemCount: folders.length,
              itemBuilder: (context, index) {
                final folder = folders[index];
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.folder, color: Colors.blueAccent),
                      title: Text(
                        folder.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      onTap: () {
                        context.read<TranscriptBloc>().add(
                            LoadTranscriptsEvent(folderName: folder.name));
                        context.push(AppRouter.folderDetail.path, extra: folder);
                      },
                    ),
                  ],
                );
              },
            );

          } else if (state is FolderError) {
            return Center(child: Text('오류: ${state.message}'));
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push(AppRouter.recording.path);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
