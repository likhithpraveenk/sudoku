import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Show remaining counts'),
            value: settings.showRemainingCounts,
            onChanged: (v) async {
              await notifier.update(showRemainingCounts: v);
            },
          ),
          SwitchListTile(
            title: const Text('Show timer'),
            value: settings.showTimer,
            onChanged: (v) async {
              await notifier.update(showTimer: v);
            },
          ),
          SwitchListTile(
            title: const Text('Auto remove notes'),
            value: settings.autoRemoveNotes,
            onChanged: (v) async {
              await notifier.update(autoRemoveNotes: v);
            },
          ),
          SwitchListTile(
            title: const Text('Mask given cells'),
            value: settings.maskGivenCells,
            onChanged: (v) async {
              await notifier.update(maskGivenCells: v);
            },
          ),
          SwitchListTile(
            title: const Text('Highlight same digits'),
            value: settings.highlightSameDigits,
            onChanged: (v) async {
              await notifier.update(highlightSameDigits: v);
            },
          ),
        ],
      ),
    );
  }
}
