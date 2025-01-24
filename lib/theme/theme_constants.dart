import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFFecf2f8),
    brightness: Brightness.light,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 24,
      fontFamily: "Geist Mono",
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontFamily: "Geist Mono",
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontFamily: "Geist Mono",
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: "Geist Mono",
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: "Geist Mono",
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: "Geist Mono",
    ),
    displayLarge: TextStyle(
      fontSize: 32,
      fontFamily: "Geist Mono",
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontFamily: "Geist Mono",
    ),
    displaySmall: TextStyle(
      fontSize: 20,
      fontFamily: "Geist Mono",
    ),
  ),
);

ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Color(0xFF0d1117),
    brightness: Brightness.dark,
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 24,
      fontFamily: "Geist Mono",
    ),
    titleMedium: TextStyle(
      fontSize: 20,
      fontFamily: "Geist Mono",
    ),
    titleSmall: TextStyle(
      fontSize: 16,
      fontFamily: "Geist Mono",
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontFamily: "Geist Mono",
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontFamily: "Geist Mono",
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontFamily: "Geist Mono",
    ),
  ),
);
