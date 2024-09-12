import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

enum ColorSchemeOption { light, dark, colorful }

extension ColorSchemeOptionExtension on ColorSchemeOption {
  String get displayName {
    switch (this) {
      case ColorSchemeOption.light:
        return '浅色';
      case ColorSchemeOption.dark:
        return '深色';
      case ColorSchemeOption.colorful:
        return '五彩';
    }
  }
}

class ColorSchemeManager {
  static const String _fileName = '.vcsb_color';
  static ColorSchemeOption _currentScheme = ColorSchemeOption.light;

  static ColorSchemeOption get currentScheme => _currentScheme;

  static ThemeData get currentTheme {
    switch (_currentScheme) {
      case ColorSchemeOption.light:
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        );
      case ColorSchemeOption.dark:
        return ThemeData.dark().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        );
      case ColorSchemeOption.colorful:
        return ThemeData.light().copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.purple,
            secondary: Colors.orange,
          ),
        );
    }
  }

  static Future<void> initialize() async {
    final file = await _getFile();
    if (await file.exists()) {
      final contents = await file.readAsString();
      _currentScheme = ColorSchemeOption.values.firstWhere(
        (e) => e.toString() == contents,
        orElse: () => ColorSchemeOption.light,
      );
    }
    _themeChangeNotifier.value = currentTheme;
  }

  static Future<void> setColorScheme(ColorSchemeOption scheme) async {
    _currentScheme = scheme;
    final file = await _getFile();
    await file.writeAsString(scheme.toString());
    _themeChangeNotifier.value = currentTheme;
  }

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final vcsbDir = Directory('${directory.path}/vcsb');
    if (!await vcsbDir.exists()) {
      await vcsbDir.create(recursive: true);
    }
    return File('${vcsbDir.path}/$_fileName');
  }

  static final ValueNotifier<ThemeData> _themeChangeNotifier =
      ValueNotifier(currentTheme);
  static ValueNotifier<ThemeData> get themeChangeNotifier =>
      _themeChangeNotifier;
}
