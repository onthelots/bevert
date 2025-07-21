import 'package:bevert/screens/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // .env 파일 로드
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BeVertApp());
}

class BeVertApp extends StatelessWidget {
  const BeVertApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeVERT',
      theme: ThemeData.dark(

      ).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.tealAccent,
      ),
      home: const HomeScreen(),
    );
  }
}
