import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0F172A);
  static const Color secondary = Color(0xFF2563EB);
  static const Color accent = Color(0xFF06B6D4);
  static const Color success = Color(0xFF22C55E);
  static const Color danger = Color(0xFFEF4444);
  static const Color background = Color(0xFFF8FAFC);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      tertiary: accent,
      onTertiary: Colors.white,
      error: danger,
      onError: Colors.white,
      surface: brightness == Brightness.light ? Colors.white : const Color(0xFF111827),
      onSurface: brightness == Brightness.light ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      surfaceContainerHighest: brightness == Brightness.light ? Colors.white : const Color(0xFF1F2937),
      onSurfaceVariant: brightness == Brightness.light ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
      outline: brightness == Brightness.light ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
      outlineVariant: brightness == Brightness.light ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: brightness == Brightness.light ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      onInverseSurface: brightness == Brightness.light ? Colors.white : const Color(0xFF0F172A),
      inversePrimary: accent,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: brightness == Brightness.light ? background : const Color(0xFF0B1120),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          side: BorderSide(color: colorScheme.outline),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: DividerThemeData(color: colorScheme.outlineVariant),
    );
  }

  static ThemeData get lightTheme => _theme(Brightness.light);
  static ThemeData get darkTheme => _theme(Brightness.dark);
}
