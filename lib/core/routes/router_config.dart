import 'package:bevert/core/routes/router.dart';
import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/presentation/home/folder_detail_screen.dart';
import 'package:bevert/presentation/home/home_screen.dart';
import 'package:bevert/presentation/record/record_screen.dart';
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
    GoRoute(
      path: AppRouter.splash.path,
      name: AppRouter.splash.name,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRouter.home.path,
      name: AppRouter.home.name,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRouter.recording.path,
      name: AppRouter.recording.name,
      builder: (context, state) => const RecordScreen(),
    ),

    GoRoute(
      path: AppRouter.summary.path,
      name: AppRouter.summary.name,
      builder: (context, state) {
        final (fullTranscript, summary) = state.extra as (String, String);
        return SummaryScreen(fullTranscript: fullTranscript, summary: summary);
      },
    ),

    // Folder Detail
    GoRoute(
      path: AppRouter.folderDetail.path,
      name: AppRouter.folderDetail.name,
      builder: (context, state) {
        final folder = state.extra as Folder;
        return FolderDetailScreen(folder: folder);
      },
    ),
    // GoRoute(
    //   path: AppRouter.theme.path,
    //   name: AppRouter.theme.name,
    //   builder: (context, state) => const ThemeSettingScreen(),
    // ),
    // GoRoute(
    //   path: AppRouter.language.path,
    //   name: AppRouter.language.name,
    //   builder: (context, state) => const LanguageSettingScreen(),
    // ),
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
