import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/breakpoints.dart';
import 'package:sudoku/presentation/widgets/action_row.dart';
import 'package:sudoku/presentation/widgets/digit_pad.dart';
import 'package:sudoku/presentation/widgets/grid_widget.dart';
import 'package:sudoku/presentation/widgets/solved_overlay.dart';
import 'package:sudoku/providers/game_notifier.dart';

/// The main active gameplay screen of the Sudoku application.
///
/// This screen acts as the shell that coordinates the active game. It handles
/// loading and error states of the [gameProvider], presents the current
/// mistake count in the AppBar, and renders the solved state via the
/// [SolvedOverlay] or the interactive board via [_GameBody].
class GameScreen extends ConsumerWidget {
  /// Creates a new gameplay screen.
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameProvider);

    return Scaffold(
      appBar: AppBar(
        title: async.maybeWhen(
          data: (s) => Text(
            _difficultyLabel(s.difficulty),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          orElse: () => const Text('Sudoku'),
        ),
        centerTitle: true,
        actions: [
          async.maybeWhen(
            data: (s) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  'Mistakes: ${s.mistakeCount}',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (state) => state.isSolved
            ? SolvedOverlay(state: state)
            : _GameBody(state: state),
      ),
    );
  }

  String _difficultyLabel(Difficulty d) => switch (d) {
    Difficulty.easy => 'Easy',
    Difficulty.medium => 'Medium',
    Difficulty.hard => 'Hard',
    Difficulty.expert => 'Expert',
  };
}

class _GameBody extends ConsumerWidget {
  const _GameBody({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = context.isExpanded;

    final grid = GridWidget(state: state);
    final controls = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ActionRow(state: state),
        const SizedBox(height: 12),
        DigitPad(state: state),
      ],
    );

    if (isExpanded) {
      return SafeArea(
        child: Row(
          children: [
            Expanded(child: Center(child: grid)),
            SizedBox(
              width: 320,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ActionRow(state: state),
                    const SizedBox(height: 24),
                    DigitPad(state: state),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            grid,
            const SizedBox(height: 16),
            controls,
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
