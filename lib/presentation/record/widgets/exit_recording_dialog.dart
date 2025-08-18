import 'package:flutter/material.dart';

class ExitRecordingDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const ExitRecordingDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(
        '녹음 종료',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        '현재까지의 녹음이 삭제됩니다. 정말 종료하시겠습니까?',
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  '취소',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  onConfirm(); // 실제 종료 동작
                },
                child: Text(
                  '종료',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
