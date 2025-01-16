import 'package:flutter/material.dart';

class ThemeConfig {
  // Base colors that will be shared across themes
  static const Color primaryLeader = Color(0xFF1565C0);   // Deep Blue
  static const Color primaryMember = Color(0xFF2E7D32);   // Deep Green
  static const Color primaryParent = Color(0xFF6A1B9A);   // Deep Purple

  static const Color secondaryLeader = Color(0xFF42A5F5); // Light Blue
  static const Color secondaryMember = Color(0xFF81C784); // Light Green
  static const Color secondaryParent = Color(0xFFAB47BC); // Light Purple

  // Common colors
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Colors.white;

  // Create theme data for each user group
  static ThemeData leaderTheme = _createTheme(primaryLeader, secondaryLeader);
  static ThemeData memberTheme = _createTheme(primaryMember, secondaryMember);
  static ThemeData parentTheme = _createTheme(primaryParent, secondaryParent);

  static ThemeData _createTheme(Color primary, Color secondary) {
    return ThemeData(
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        secondary: secondary,
        surface: surfaceColor,
        error: errorColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primary,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}