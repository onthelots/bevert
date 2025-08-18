import 'package:bevert/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastHelper {
  static void showError(String message, {BuildContext? context}) {
    toastification.show(
      context: context,
      autoCloseDuration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 150),
      title: Text(
        '오류',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      alignment: Alignment.bottomCenter,
      showIcon: true,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      backgroundColor: AppColors.darkPrimary,    // 강한 블루 (darkPrimary)
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static void showSuccess(String message, {BuildContext? context}) {
    toastification.show(
      context: context,
      autoCloseDuration: const Duration(seconds: 2),
      animationDuration: const Duration(milliseconds: 150),
      title: Text(
        '성공',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 14,
        ),
      ),
      description: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      alignment: Alignment.bottomCenter,
      showIcon: true,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      backgroundColor: AppColors.lightPrimary,
      foregroundColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
