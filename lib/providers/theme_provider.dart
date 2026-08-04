import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sudoku/data/hive_boxes.dart';
import 'package:sudoku/presentation/models/theme_config.dart';
import 'package:sudoku/presentation/shared/no_transition_builder.dart';
import 'package:sudoku/providers/settings_provider.dart';

final themeConfigProvider = NotifierProvider(
  ThemeNotifier.new,
  name: 'themeConfigProvider',
);

final kShape = RoundedRectangleBorder(borderRadius: .circular(6));

final customThemeProvider = NotifierProvider(
  CustomThemeNotifier.new,
  name: 'customThemeProvider',
);

final currentThemeProvider = Provider((ref) {
  final config = ref.watch(themeConfigProvider);
  final trueBlack = ref.watch(settingsProvider.select((s) => s.trueBlackMode));
  final schemeVariant = ref.watch(
    settingsProvider.select((s) => s.schemeVariant),
  );
  final removeAnimations = ref.watch(
    settingsProvider.select((s) => s.removeAnimations),
  );

  ColorScheme colorScheme = ColorScheme.fromSeed(
    seedColor: config.seedColor,
    brightness: config.brightness,
    dynamicSchemeVariant: schemeVariant,
  );
  if (trueBlack && config.brightness == .dark) {
    colorScheme = colorScheme.copyWith(surface: Colors.black);
  }

  return ThemeData(
    colorScheme: colorScheme,
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
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        .android: removeAnimations
            ? const NoTransitionBuilder()
            : const CupertinoPageTransitionsBuilder(),
        .iOS: removeAnimations
            ? const NoTransitionBuilder()
            : const CupertinoPageTransitionsBuilder(),
        .linux: removeAnimations
            ? const NoTransitionBuilder()
            : const FadeUpwardsPageTransitionsBuilder(),
        .windows: removeAnimations
            ? const NoTransitionBuilder()
            : const FadeUpwardsPageTransitionsBuilder(),
        .macOS: removeAnimations
            ? const NoTransitionBuilder()
            : const CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}, name: 'currentThemeProvider');

class ThemeNotifier extends Notifier<ThemeConfig> {
  static const _key = 'theme_config';

  Box<String> get box => Hive.box(themeBox);

  @override
  ThemeConfig build() {
    final json = box.get(_key);
    if (json != null) {
      return ThemeConfig.fromJson(jsonDecode(json) as Map<String, dynamic>);
    }
    return builtInThemes.first;
  }

  void select(ThemeConfig config) {
    state = config;
    _persist(config);
  }

  Future<void> _persist(ThemeConfig config) async {
    await box.put(_key, jsonEncode(config));
  }
}

class CustomThemeNotifier extends Notifier<List<ThemeConfig>> {
  static const _key = 'custom_themes';

  Box<String> get box => Hive.box(themeBox);

  @override
  List<ThemeConfig> build() {
    final json = box.get(_key);
    if (json == null) return [];
    return (jsonDecode(json) as List)
        .map((t) => ThemeConfig.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  void add(ThemeConfig config) {
    if (state.any((e) => e == config)) return;
    state = [...state, config];
    _persist();
  }

  void remove(ThemeConfig config) {
    state = state.where((e) => e != config).toList();
    _persist();
  }

  Future<void> _persist() async {
    await box.put(_key, jsonEncode(state));
  }
}
