import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/presentation/screens/game_screen.dart';
import 'package:sudoku/presentation/screens/settings_screen.dart';
import 'package:sudoku/presentation/shared/utils.dart';
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
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: const .all(.circular(6)),
                        ),
                        child: Image.asset(
                          'assets/icons/icon.png',
                          width: 160,
                          height: 160,
                          color: theme.colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 36),
                      Wrap(
                        spacing: 8,
                        alignment: .center,
                        children: Difficulty.values.map((d) {
                          final selected = d == difficulty;
                          return ChoiceChip(
                            label: Text(d.displayName),
                            selected: selected,
                            onSelected: (_) {
                              ref.read(difficultyProvider.notifier).set(d);
                            },
                            visualDensity: .compact,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (continueGameMap[difficulty] != null) ...[
                            Expanded(
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
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
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
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: .spaceEvenly,
                        children: [
                          IconButton(
                            tooltip: 'Settings',
                            onPressed: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.settings),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned(top: 6, right: 6, child: ThemeSelector()),
          ],
        ),
      ),
    );
  }
}
