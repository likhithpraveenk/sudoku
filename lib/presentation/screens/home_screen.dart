import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/screens/game_screen.dart';
import 'package:sudoku/presentation/screens/settings_screen.dart';
import 'package:sudoku/presentation/widgets/difficulty_selector.dart';
import 'package:sudoku/presentation/widgets/theme_selector.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

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
                      Text('Sudoku', style: textTheme.displaySmall),
                      const SizedBox(height: 36),
                      const DifficultySelector(),
                      const SizedBox(height: 16),
                      ...[
                        // TODO: continue game
                      ],
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
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
                        mainAxisAlignment: .center,
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
