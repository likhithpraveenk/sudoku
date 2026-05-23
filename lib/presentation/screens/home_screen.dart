import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/screens/game_screen.dart';
import 'package:sudoku/presentation/screens/settings_screen.dart';
import 'package:sudoku/presentation/shared/utils.dart';
import 'package:sudoku/presentation/widgets/difficulty_selector.dart';
import 'package:sudoku/presentation/widgets/theme_selector.dart';
import 'package:sudoku/providers/services_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saved = ref.watch(continueGameProvider).value;
    final continueGame = ref.read(continueGameFlagProvider.notifier);

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
                      const DifficultySelector(),
                      const SizedBox(height: 16),
                      if (saved != null) ...[
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {
                              continueGame.state = true;
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const GameScreen(),
                                ),
                              );
                            },
                            child: Text(
                              'Continue ${formatTime(saved.elapsed)}',
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            continueGame.state = false;
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const GameScreen(),
                              ),
                            );
                          },
                          child: const Text('New Game'),
                        ),
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
