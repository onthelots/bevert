import 'package:intl/date_symbol_data_local.dart';
import 'package:bevert/core/di/locator.dart';
import 'package:bevert/core/routes/router_config.dart';
import 'package:bevert/core/theme/app_theme.dart';
import 'package:bevert/domain/usecases/transcript_folder/folder_usecase.dart';
import 'package:bevert/domain/usecases/transcript_record/transcript_usecase.dart';
import 'package:bevert/presentation/home/folder_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';
import 'firebase_options.dart';
import 'presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'presentation/home/bloc/transcript_folder_bloc/folder_event.dart';
import 'presentation/home/bloc/transcript_record_bloc/transcript_bloc.dart';
import 'presentation/home/home_screen.dart';
import 'presentation/splash/bloc/theme_bloc/theme_bloc.dart';
import 'presentation/splash/bloc/theme_bloc/theme_event.dart';
import 'presentation/splash/bloc/theme_bloc/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('ko', null);

  // env
  await dotenv.load(fileName: ".env");

  // fetch supabase key
  final String supabseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? "";

  // supabase 초기화
  await Supabase.initialize(
    url: "https://otgijzsaalfsddcxdbpi.supabase.co",
    anonKey: supabseAnonKey,
  );

  // firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 의존성 주입
  await setupLocator();

  runApp(ToastificationWrapper(child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GoRouter _router = appRouter;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeBloc()..add(ThemeInitialEvent()),
        ),

        // 폴더 가져오기
        BlocProvider(
            create: (context) => locator<FolderBloc>()..add(LoadFoldersEvent()),
        ),

        // 폴더 내 녹음 파일 가져오기
        BlocProvider(
          create: (_) => locator<TranscriptBloc>(),
          child: HomeScreen(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final themeMode = (state is ThemeInitial)
              ? state.themeMode
              : ThemeMode.system;

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
