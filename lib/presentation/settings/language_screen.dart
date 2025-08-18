import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("언어 설정", style: theme.textTheme.bodyLarge,),
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.textTheme.bodyLarge?.color,
      ),
      body: const Center(
        child: Text('언어 설정 화면'),
      ),
    );
  }
}
