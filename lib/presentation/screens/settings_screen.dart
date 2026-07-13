import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/widgets/game_preview.dart';
import 'package:sudoku/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: SingleChildScrollView(
            padding: const .only(bottom: 48),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: const .all(16),
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      Text(
                        'Preview',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: .bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: GamePreview(
                          showRemainingCounts: settings.showRemainingCounts,
                          maskGivenCells: settings.maskGivenCells,
                          highlightSameDigits: settings.highlightSameDigits,
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Show remaining counts'),
                  value: settings.showRemainingCounts,
                  onChanged: (v) async {
                    await notifier.update(
                      (s) => s.copyWith(showRemainingCounts: v),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Show timer'),
                  value: settings.showTimer,
                  onChanged: (v) async {
                    await notifier.update((s) => s.copyWith(showTimer: v));
                  },
                ),
                SwitchListTile(
                  title: const Text('Auto remove notes'),
                  value: settings.autoRemoveNotes,
                  onChanged: (v) async {
                    await notifier.update(
                      (s) => s.copyWith(autoRemoveNotes: v),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Mask given cells'),
                  value: settings.maskGivenCells,
                  onChanged: (v) async {
                    await notifier.update((s) => s.copyWith(maskGivenCells: v));
                  },
                ),
                SwitchListTile(
                  title: const Text('Highlight same digits'),
                  value: settings.highlightSameDigits,
                  onChanged: (v) async {
                    await notifier.update(
                      (s) => s.copyWith(highlightSameDigits: v),
                    );
                  },
                ),
                Padding(
                  padding: const .all(12),
                  child: Text(
                    'Themes',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: .bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('True black mode'),
                  value: settings.trueBlackMode,
                  onChanged: (v) async {
                    await notifier.update((s) => s.copyWith(trueBlackMode: v));
                  },
                ),
                Container(
                  padding: const .all(12),
                  width: double.infinity,
                  child: SegmentedButton<DynamicSchemeVariant>(
                    segments: const [
                      ButtonSegment(
                        value: .tonalSpot,
                        label: Text('Default'),
                        icon: Icon(Icons.palette_outlined),
                      ),
                      ButtonSegment(
                        value: .fidelity,
                        label: Text('Fidelity'),
                        icon: Icon(Icons.lens_blur),
                      ),
                      ButtonSegment(
                        value: .vibrant,
                        label: Text('Vibrant'),
                        icon: Icon(Icons.auto_awesome),
                      ),
                    ],
                    selected: {settings.schemeVariant},
                    onSelectionChanged: (sv) {
                      notifier.update(
                        (s) => s.copyWith(schemeVariant: sv.first),
                      );
                    },
                  ),
                ),
                // TODO: add custom theme
              ],
            ),
          ),
        ),
      ),
    );
  }
}
