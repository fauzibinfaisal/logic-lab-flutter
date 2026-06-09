library;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _kAccent = Color(0xFF00D4FF);
const _kBackground = Color(0xFF080D1A);
const _kSurface = Color(0xFF0F1729);
const _kSurfaceVariant = Color(0xFF162040);
const _kOutline = Color(0xFF1E2D4A);

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _kAccent,
      brightness: Brightness.dark,
      surface: _kBackground,
      primary: _kAccent,
    ).copyWith(
      surface: _kBackground,
      surfaceContainerLow: _kSurface,
      surfaceContainerHigh: _kSurfaceVariant,
      outline: _kOutline,
      outlineVariant: _kOutline,
    ),
    scaffoldBackgroundColor: _kBackground,
    cardTheme: CardThemeData(
      clipBehavior: Clip.antiAlias,
      color: _kSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _kOutline),
      ),
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
  );
}
