import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/core/theme/theme.dart';
import 'package:sudoku/providers/preferences_provider.dart';

/// Constructor for [NotifierProvider].
final NotifierProvider<ThemeNotifier, ThemeConfig> themeNotifierProvider =
    NotifierProvider(ThemeNotifier.new);

/// Constructor for [Provider].
final Provider<ThemeData> currentThemeProvider = Provider((ref) {
  final config = ref.watch(themeNotifierProvider);
  final scheme = ColorScheme.fromSeed(
    seedColor: config.seedColor,
  );

  return ThemeData(
    colorScheme: config.surfaceColor != null
        ? scheme.copyWith(surface: config.surfaceColor)
        : scheme,
  );
});

/// [ThemeNotifier] definition.
class ThemeNotifier extends Notifier<ThemeConfig> {
  static const _key = 'sudoku_theme_config';

  @override
  ThemeConfig build() {
    final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
    final json = prefs?.getString(_key);
    if (json != null) {
      return ThemeConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
    return ThemeConfig.builtIn.first;
  }

  /// A public member.
  Future<void> selectBuiltIn(int index) async {
    if (index >= 0 && index < ThemeConfig.builtIn.length) {
      final config = ThemeConfig.builtIn[index];
      state = config;
      await _persist(config);
    }
  }

  /// A public member.
  Future<void> applyCustom(ThemeConfig customConfig) async {
    state = customConfig;
    await _persist(customConfig);
  }

  Future<void> _persist(ThemeConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(config.toJson()));
  }
}
