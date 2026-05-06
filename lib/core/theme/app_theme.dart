/// Application-wide theme configuration.
///
/// Uses Material 3 design system with a custom seed color palette.
library;

import 'package:flutter/material.dart';

/// Returns the [ThemeData] for the application.
ThemeData buildAppTheme() {
  const seedColor = Color(0xFF5C6BC0); // Indigo 400

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    ),
    fontFamily: 'Roboto',
    cardTheme: const CardThemeData(
      clipBehavior: Clip.antiAlias,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
    ),
  );
}
