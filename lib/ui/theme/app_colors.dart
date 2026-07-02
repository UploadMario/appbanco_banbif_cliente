import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF0057B8);
  static const Color primaryDark = Color(0xFF003B7A);
  static const Color primaryLight = Color(0xFF1E9BFF);
  static const Color secondary = Color(0xFF003B7A);
  static const Color accent = Color(0xFF00AEEF);
  static const Color brandRed = Color(0xFFE30613);
  static const Color brandOrange = Color(0xFFFF7A1A);
  static const Color brandMagenta = Color(0xFFC2185B);
  static const Color brandWarmSoft = Color(0xFFFFEEF3);
  static const Color accentSoft = Color(0xFFDFF4FF);
  static const Color highlight = Color(0xFF00AEEF);
  static const Color dark = Color(0xFF151924);
  static const Color navy = Color(0xFF202636);
  static const Color background = Color(0xFFF5F8FC);
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFEEF3F8);
  static const Color textPrimary = Color(0xFF172033);
  static const Color textSecondary = Color(0xFF5B667A);
  static const Color border = Color(0xFFD8E1EC);
  static const Color success = Color(0xFF11A36A);
  static const Color warning = Color(0xFFF5A524);
  static const Color error = Color(0xFFD92D20);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandRed, brandOrange, brandMagenta],
  );

  static const LinearGradient bankingGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, accent],
  );

  static const LinearGradient softHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF7FF), surface],
  );
}
