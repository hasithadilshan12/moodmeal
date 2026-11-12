import 'package:flutter/material.dart';

/// Palette pulled from the Figma file (accent #F9751A, ink #655656, muted #BEB7B7)
/// plus tints introduced for a calmer, more premium surface system.
///
/// Neutral tokens are getters rather than constants so the whole app can flip
/// between the warm light palette and a warm dark palette. [setDark] is called
/// once from the root widget before the tree is built.
class AppColors {
  AppColors._();

  static bool _dark = false;

  static bool get isDark => _dark;

  static void setDark(bool value) {
    _dark = value;
  }

  // Accents stay identical in both themes; they carry the brand.
  static const orange = Color(0xFFF9751A);
  static const orangeDeep = Color(0xFFE85D04);
  static const orangeLight = Color(0xFFFFA149);

  // Neutral surfaces and text.
  static Color get peach =>
      _dark ? const Color(0xFF4A3226) : const Color(0xFFFFE8D6);
  static Color get peachSoft =>
      _dark ? const Color(0xFF33251C) : const Color(0xFFFFF1E5);

  static Color get cream =>
      _dark ? const Color(0xFF14100D) : const Color(0xFFFFF7F0);
  static Color get surface =>
      _dark ? const Color(0xFF211B17) : const Color(0xFFFFFFFF);
  static Color get surfaceAlt =>
      _dark ? const Color(0xFF2A231E) : const Color(0xFFFFFBF7);

  static Color get ink =>
      _dark ? const Color(0xFFF7EFE7) : const Color(0xFF2F2118);
  static Color get inkSoft =>
      _dark ? const Color(0xFFCDBFB3) : const Color(0xFF6B5A4E);
  static Color get muted =>
      _dark ? const Color(0xFF9C8D82) : const Color(0xFFA4938A);
  static Color get line =>
      _dark ? const Color(0xFF3B312A) : const Color(0xFFF0E4DA);

  static const green = Color(0xFF2E9E6B);
  static Color get greenSoft =>
      _dark ? const Color(0xFF1D3A2D) : const Color(0xFFE4F5EC);
  static const rose = Color(0xFFE45B78);
  static Color get roseSoft =>
      _dark ? const Color(0xFF3C232A) : const Color(0xFFFDE9EE);
  static const violet = Color(0xFF7B61FF);
  static Color get violetSoft =>
      _dark ? const Color(0xFF2B2547) : const Color(0xFFEDE9FF);
  static const amber = Color(0xFFF5A524);
  static Color get amberSoft =>
      _dark ? const Color(0xFF3A2E17) : const Color(0xFFFFF3D6);

  /// Keeps a pastel accent readable when the palette flips to dark.
  static Color pastel(Color light) => _dark
      ? Color.alphaBlend(Colors.black.withValues(alpha: 0.62), light)
      : light;

  static const moods = <String, List<Color>>{
    'calm': [Color(0xFF9BD8C4), Color(0xFF57B79C)],
    'happy': [Color(0xFFFFCB6B), Color(0xFFF5A524)],
    'stressed': [Color(0xFFFF9A8B), Color(0xFFE86A5B)],
    'sad': [Color(0xFF9CC6F0), Color(0xFF5B93C9)],
    'tired': [Color(0xFFC9BDE8), Color(0xFF9A83CF)],
    'excited': [Color(0xFFFFB86B), Color(0xFFFF7A45)],
    'angry': [Color(0xFFF79C9C), Color(0xFFD64545)],
    'bored': [Color(0xFFD8CFC4), Color(0xFFA79C90)],
  };

  static const orangeGradient = LinearGradient(
    colors: [Color(0xFFFFA24C), orange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
