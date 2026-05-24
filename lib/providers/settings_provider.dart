import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:sudoku/data/hive_boxes.dart';
import 'package:sudoku/presentation/models/app_settings.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
  name: 'settingsProvider',
);

class SettingsNotifier extends Notifier<AppSettings> {
  static const _key = 'settings_key';

  Box<String> get box => Hive.box(settingsBox);

  @override
  AppSettings build() {
    final json = box.get(_key);
    if (json == null) {
      return const AppSettings();
    }

    return AppSettings.fromJson(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> update(AppSettings Function(AppSettings state) builder) async {
    state = builder(state);
    await _persist();
  }

  Future<void> _persist() async {
    await box.put(_key, jsonEncode(state.toJson()));
  }
}
