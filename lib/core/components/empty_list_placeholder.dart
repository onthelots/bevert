import 'package:flutter/material.dart';

class EmptyListPlaceholder extends StatelessWidget {
  final String message;
  final IconData icon;
  final double iconSize;

  const EmptyListPlaceholder({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.iconSize = 64,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: theme.disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.disabledColor,
            ),
          ),
        ],
      ),
    );
  }
}
