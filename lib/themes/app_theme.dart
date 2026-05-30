import 'package:flutter/material.dart';

const _seedColor = Color(0xFF062847);

/// App Theme
final appDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  fontFamily: 'Ghibli',
  colorScheme: ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  ),
  visualDensity: .standard,
  appBarTheme: const AppBarTheme(
    centerTitle: false,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    backgroundColor: Colors.transparent,
  ),
  inputDecorationTheme: const InputDecorationThemeData(
    contentPadding: .symmetric(horizontal: 8, vertical: 8),
    border: InputBorder.none,
    isDense: true,
  ),
  cardTheme: const CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: .all(
        .circular(24),
      ),
    ),
  ),
);
