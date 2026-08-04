import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/models/app_settings.dart';
import 'package:sudoku/presentation/screens/custom_colors_screen.dart';
import 'package:sudoku/presentation/widgets/game_preview.dart';
import 'package:sudoku/presentation/widgets/theme_selector.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: const [ThemeSelector()],
      ),
      body: SingleChildScrollView(
        padding: const .only(bottom: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: const .all(12),
                  child: Text(
                    'Theme',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: .bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('True black'),
                  value: settings.trueBlackMode,
                  contentPadding: const .symmetric(horizontal: 12),
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
                Consumer(
                  builder: (_, ref, _) {
                    final count = ref.watch(customThemeProvider).length;
                    return ListTile(
                      title: const Text('Custom colors'),
                      subtitle: Text(
                        count == 0
                            ? 'Add and manage your own themes'
                            : '$count',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CustomColorsScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
                Padding(
                  padding: const .all(12),
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
                      const SizedBox(height: 12),
                      Center(
                        child: GamePreview(
                          showRemainingCounts: settings.showRemainingCounts,
                          maskGivenCells: settings.maskGivenCells,
                          highlightSameDigits: settings.highlightSameDigits,
                          notesLayout: settings.notesLayout,
                          removeAnimations: settings.removeAnimations,
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: const Text('Show remaining counts'),
                  value: settings.showRemainingCounts,
                  contentPadding: const .symmetric(horizontal: 12),
                  onChanged: (v) async {
                    await notifier.update(
                      (s) => s.copyWith(showRemainingCounts: v),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Show timer'),
                  value: settings.showTimer,
                  contentPadding: const .symmetric(horizontal: 12),
                  onChanged: (v) async {
                    await notifier.update((s) => s.copyWith(showTimer: v));
                  },
                ),
                SwitchListTile(
                  title: const Text('Remove animations'),
                  value: settings.removeAnimations,
                  contentPadding: const .symmetric(horizontal: 12),
                  onChanged: (v) async {
                    await notifier.update(
                      (s) => s.copyWith(removeAnimations: v),
                    );
                  },
                ),
                SwitchListTile(
                  title: const Text('Mask given cells'),
                  value: settings.maskGivenCells,
                  contentPadding: const .symmetric(horizontal: 12),
                  onChanged: (v) async {
                    await notifier.update((s) => s.copyWith(maskGivenCells: v));
                  },
                ),
                SwitchListTile(
                  title: const Text('Highlight same digits'),
                  value: settings.highlightSameDigits,
                  contentPadding: const .symmetric(horizontal: 12),
                  onChanged: (v) async {
                    await notifier.update(
                      (s) => s.copyWith(highlightSameDigits: v),
                    );
                  },
                ),
                Padding(
                  padding: const .all(12),
                  child: Column(
                    crossAxisAlignment: .stretch,
                    children: [
                      Text(
                        'Notes layout',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: .bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'How notes are shown inside empty cells',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<NotesLayout>(
                        segments: [
                          for (final layout in NotesLayout.values)
                            ButtonSegment(
                              value: layout,
                              label: Text(layout.label),
                            ),
                        ],
                        selected: {settings.notesLayout},
                        onSelectionChanged: (selection) {
                          notifier.update(
                            (s) => s.copyWith(notesLayout: selection.first),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        settings.notesLayout.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
