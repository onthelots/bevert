import 'package:flutter/material.dart';

class CompletedRecordingDialog extends StatelessWidget {
  final String folderName;
  final VoidCallback onConfirm;

  const CompletedRecordingDialog({
    super.key,
    required this.folderName,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope( // 뒤로가기 버튼 방지
      onWillPop: () async => false,
      child: AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          '노트 생성 완료',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '[$folderName]폴더에서 생성된 노트를 확인하시고, 문서를 요약하거나 관리하세요 :)',
          style: theme.textTheme.bodyMedium,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              onConfirm();                 // 확인 콜백 실행
            },
            child: Text(
              '확인',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
