import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/providers/settings_provider.dart';

final themeConfigProvider = NotifierProvider(ThemeNotifier.new);

final kShape = RoundedRectangleBorder(borderRadius: .circular(6));

final currentThemeProvider = Provider((ref) {
  final config = ref.watch(themeConfigProvider);

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: config.seedColor,
      brightness: config.brightness,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(shape: kShape),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(shape: kShape),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(shape: kShape),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(shape: kShape),
    ),
    scrollbarTheme: ScrollbarThemeData(
      thumbVisibility: WidgetStateProperty.all(false),
      trackVisibility: WidgetStateProperty.all(false),
    ),
    chipTheme: ChipThemeData(shape: kShape),
  );
});

class ThemeNotifier extends Notifier<ThemeConfig> {
  static const _key = 'sudoku_theme_config';

  SharedPreferences get prefs => ref.read(sharedPrefsProvider);

  @override
  ThemeConfig build() {
    final json = prefs.getString(_key);
    if (json != null) {
      return ThemeConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
    return ref.read(allThemesProvider).first;
  }

  void select(ThemeConfig config) {
    state = config;
    _persist(config);
  }

  Future<void> _persist(ThemeConfig config) async {
    await prefs.setString(_key, jsonEncode(config));
  }
}

class CustomThemeNotifier extends Notifier<List<ThemeConfig>> {
  static const _key = 'sudoku_custom_themes';

  @override
  List<ThemeConfig> build() {
    final prefs = ref.watch(sharedPrefsProvider);
    final json = prefs.getString(_key);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map((e) => ThemeConfig.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void add(ThemeConfig config) {
    state = [...state, config];
    _persist();
  }

  void remove(ThemeConfig config) {
    state = state.where((e) => e != config).toList();
    _persist();
  }

  Future<void> _persist() async {
    final prefs = ref.read(sharedPrefsProvider);
    await prefs.setString(_key, jsonEncode(state));
  }
}

final customThemeProvider = NotifierProvider(CustomThemeNotifier.new);

final allThemesProvider = Provider((ref) {
  final custom = ref.watch(customThemeProvider);
  return [...ThemeConfig.builtIn, ...custom];
});
