import 'package:flutter/material.dart';

/// App Colors - Blue/Navy Theme
class AppColors {
  // 🌤️ LIGHT THEME
  static const Color lightPrimary = Color(0xFF1B77EC); // main blue (실제 배경 색)
  static const Color lightSecondary = Color(0xFF3B94F6); // 조화로운 medium blue
  static const Color lightTertiary = Color(0xFF94CDFD); // soft blue tone
  static const Color lightAccent = Color(0xFF2AD595); // vivid green (실제 포인트 색)
  static const Color lightBackground = Color(0xFFF2F6FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE6EDF6);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x22000000);

  // 🌙 DARK THEME
  static const Color darkPrimary = Color(0xFF94CDFD);
  static const Color darkSecondary = Color(0xFF63B4FA);
  static const Color darkTertiary = Color(0xFF1B77EC); // deep blue match
  static const Color darkAccent = Color(0xFF2AD595); // vivid green
  static const Color darkBackground = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF1E2530);
  static const Color darkCard = Color(0xFF242B38);
  static const Color darkDivider = Color(0xFF37474F);
  static const Color darkShadow = Color(0x44000000);

  static const Color darkAccentDarker = Color(0xFF1FAD7A);
}

/// Folder Colors
class FolderColors {
  static const List<Color> availableColors = [
    AppColors.lightPrimary,         // 강한 블루
    AppColors.lightAccent,          // 선명한 포인트 그린
    AppColors.lightTertiary,        // 소프트 블루
    Color(0xFFFFC107),              // 앰버 (명도 높은 노랑, 배경과 대비)
    Color(0xFFEF5350),              // 레드 (강한 존재감)
    Color(0xFF7E57C2),              // 퍼플 (톤 다운된 고급스러운 느낌)
  ];
}