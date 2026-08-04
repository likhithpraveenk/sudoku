import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/presentation/screens/about_screen.dart';
import 'package:sudoku/presentation/screens/game_screen.dart';
import 'package:sudoku/presentation/screens/settings_screen.dart';
import 'package:sudoku/presentation/screens/stats_screen.dart';
import 'package:sudoku/presentation/shared/utils.dart';
import 'package:sudoku/presentation/widgets/import_sudoku_dialog.dart';
import 'package:sudoku/presentation/widgets/theme_selector.dart';
import 'package:sudoku/providers/difficulty_provider.dart';
import 'package:sudoku/providers/services_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final continueGameMap = ref.watch(continueGameProvider);
    final difficulty = ref.watch(difficultyProvider);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: .expand,
          children: [
            Center(
              child: Padding(
                padding: const .all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          borderRadius: .all(.circular(6)),
                        ),
                        child: Image.asset(
                          'assets/icons/icon.png',
                          width: 160,
                          height: 160,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: difficulty.index > 0
                                ? () => ref
                                      .read(difficultyProvider.notifier)
                                      .set(
                                        Difficulty.values[difficulty.index - 1],
                                      )
                                : null,
                          ),
                          SizedBox(
                            width: 150,
                            child: Text(
                              difficulty.displayName,
                              textAlign: .center,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed:
                                difficulty.index < Difficulty.values.length - 1
                                ? () => ref
                                      .read(difficultyProvider.notifier)
                                      .set(
                                        Difficulty.values[difficulty.index + 1],
                                      )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            await ref
                                .read(saveGameServiceProvider)
                                .delete(difficulty);
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const GameScreen(),
                                ),
                              );
                            }
                          },
                          child: const Text('New Game'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (continueGameMap[difficulty] != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const GameScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Continue ${formatTime(continueGameMap[difficulty]!.elapsed)}',
                            ),
                          ),
                        )
                      else
                        const ExcludeSemantics(
                          child: Opacity(
                            opacity: 0,
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: null,
                                child: Text(''),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: .topRight,
              child: Row(
                mainAxisSize: .min,
                children: [
                  IconButton(
                    tooltip: 'About',
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AboutScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.info_outline),
                  ),
                  IconButton(
                    tooltip: 'Stats',
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const StatsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.bar_chart_outlined),
                  ),
                  IconButton(
                    tooltip: 'Import',
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => const ImportSudokuDialog(),
                    ),
                    icon: const Icon(Icons.file_upload_outlined),
                  ),
                  IconButton(
                    tooltip: 'Settings',
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings_outlined),
                  ),
                  const Padding(padding: .all(6), child: ThemeSelector()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
