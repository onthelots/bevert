import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class DeleteFolderDialog extends StatelessWidget {
  final String folderName;
  final VoidCallback onConfirmDelete;

  const DeleteFolderDialog({
    super.key,
    required this.folderName,
    required this.onConfirmDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.scaffoldBackgroundColor,
      title: Text(
        '폴더 삭제',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        '[$folderName] 폴더를 삭제하시겠습니까? 폴더 내 노트도 함께 삭제됩니다.',
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
                  onConfirmDelete();
                  Navigator.of(context).pop();
                },
                child: Text(
                  '삭제',
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
