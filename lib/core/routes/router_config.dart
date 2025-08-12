import 'package:bevert/core/routes/router.dart';
import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/data/models/transcript_record/transcript_record_model.dart';
import 'package:bevert/presentation/home/folder_detail_screen.dart';
import 'package:bevert/presentation/home/home_screen.dart';
import 'package:bevert/presentation/notes_by_date/notes_by_date_screen.dart';
import 'package:bevert/presentation/record/record_screen.dart';
import 'package:bevert/presentation/settings/language_screen.dart';
import 'package:bevert/presentation/settings/theme_screen.dart';
import 'package:bevert/presentation/splash/splash_screen.dart';
import 'package:bevert/presentation/summary/summary_screen.dart';
import 'package:flutter/material.dart';
import 'package:bevert/core/routes/router_observer.dart';
import 'package:go_router/go_router.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final appRouterObserver = AppRouterObserver(name: 'Root Router');

final GoRouter appRouter = GoRouter(
  initialLocation: AppRouter.splash.path,
  navigatorKey: rootNavigatorKey,
  observers: [appRouterObserver],
  routes: [

    // 스플래시
    GoRoute(
      path: AppRouter.splash.path,
      name: AppRouter.splash.name,
      builder: (context, state) => const SplashScreen(),
    ),

    // 홈
    GoRoute(
      path: AppRouter.home.path,
      name: AppRouter.home.name,
      builder: (context, state) => const HomeScreen(),
    ),

    // 녹음
    GoRoute(
      path: AppRouter.recording.path,
      name: AppRouter.recording.name,
      builder: (context, state) {
        final folderName = state.extra as String;
        return RecordScreen(folderName: folderName);
      },
    ),

    // 요약
    GoRoute(
      path: AppRouter.summary.path,
      name: AppRouter.summary.name,
      builder: (context, state) {
        final (transcriptRecord, fromRecord) = state.extra as (TranscriptRecord, bool);
        return SummaryScreen(transcriptRecord: transcriptRecord, fromRecord: fromRecord,);
      },
    ),

    // 폴더 내 노트 리스트
    GoRoute(
      path: AppRouter.folderDetail.path,
      name: AppRouter.folderDetail.name,
      builder: (context, state) {
        final folder = state.extra as Folder;
        return FolderDetailScreen(folder: folder);
      },
    ),

    // 달력에서 노트보기
    GoRoute(
      path: AppRouter.calendar.path,
      name: AppRouter.calendar.name,
      builder: (context, state) => const NotesByDateScreen(),
    ),

    // 테마 설정
    GoRoute(
      path: AppRouter.theme.path,
      name: AppRouter.theme.name,
      builder: (context, state) => const ThemeScreen(),
    ),

    // 언어 설정
    GoRoute(
      path: AppRouter.language.path,
      name: AppRouter.language.name,
      builder: (context, state) => const LanguageScreen(),
    ),

    // GoRoute(
    //   path: AppRouter.policy.path,
    //   name: AppRouter.policy.name,
    //   builder: (context, state) => const PolicyScreen(),
    // ),

    // GoRoute(
    //   path: AppRouter.about.path,
    //   name: AppRouter.about.name,
    //   builder: (context, state) => const AboutScreen(),
    // ),
  ],
);
