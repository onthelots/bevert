import 'package:bevert/core/routes/router.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<FolderBloc, FolderState>(
      listenWhen: (previous, current) => current is FolderLoaded || current is FolderError,
      listener: (context, state) {
        if (state is FolderLoaded) {
          context.replace(AppRouter.home.path);
        } else if (state is FolderError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('데이터 로딩 실패: ${state.message}')),
          );
        }
      },
      child: const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
