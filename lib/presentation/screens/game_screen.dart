import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/breakpoints.dart';
import 'package:sudoku/presentation/widgets/action_row.dart';
import 'package:sudoku/presentation/widgets/digit_pad.dart';
import 'package:sudoku/presentation/widgets/game_layout.dart';
import 'package:sudoku/presentation/widgets/grid_widget.dart';
import 'package:sudoku/presentation/widgets/solved_overlay.dart';
import 'package:sudoku/presentation/widgets/theme_selector.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/game_notifier.dart';
import 'package:sudoku/providers/settings_provider.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameProvider);
    final showTimer = ref.watch(settingsProvider.select((s) => s.showTimer));
    final game = gameAsync.value;

    final board = ref.watch(boardProvider);
    final boardNotifier = ref.read(boardProvider.notifier);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: (showTimer && game != null && !game.puzzleComplete)
            ? Text(
                _formatTime(game.elapsed),
                style: Theme.of(context).textTheme.labelLarge,
              )
            : null,
        centerTitle: true,
        actions: const [ThemeSelector()],
      ),
      body: gameAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (game) {
          if (game == null) {
            return Center(
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  const Text('No active game'),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      gameNotifier.stopTimer();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Start New Game'),
                  ),
                ],
              ),
            );
          }

          return Focus(
            autofocus: true,
            onKeyEvent: (node, event) {
              if (event is! KeyDownEvent) return .ignored;
              final key = event.logicalKey;
              switch (key) {
                case .arrowLeft:
                  boardNotifier.selectCell((board.selectedCell ?? 0) - 1);
                  return .handled;
                case .arrowRight:
                  boardNotifier.selectCell((board.selectedCell ?? 0) + 1);
                  return .handled;
                case .arrowUp:
                  boardNotifier.selectCell((board.selectedCell ?? 0) - 9);
                  return .handled;
                case .arrowDown:
                  boardNotifier.selectCell((board.selectedCell ?? 0) + 9);
                  return .handled;
                case .backspace || .delete:
                  gameNotifier.erase();
                  return .handled;
                default:
              }
              if (key.keyLabel.length == 1) {
                final d = int.tryParse(key.keyLabel);
                if (d != null && d >= 1 && d <= 9) {
                  boardNotifier.selectDigit(d);
                  return .handled;
                }
              }
              if (key.keyLabel.toLowerCase() == 'p') {
                boardNotifier.toggleInputMode();
                return .handled;
              }
              return .ignored;
            },
            child: game.puzzleComplete
                ? SolvedOverlay(state: game, onBack: gameNotifier.stopTimer)
                : _GameBody(state: game),
          );
        },
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _GameBody extends ConsumerWidget {
  const _GameBody({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = context.isExpanded;
    final settings = ref.watch(settingsProvider);

    final grid = GridWidget(gameState: state);
    const action = ActionRow();
    final digits = DigitPad(state: state);

    final base = isExpanded
        ? GameLayoutParams.desktop
        : GameLayoutParams.mobile;
    final params = base.copyWith(
      gridWidth: settings.gridWidth,
      horizontalSpacing: settings.horizontalSpacing,
      verticalSpacing: settings.verticalSpacing,
      placement: settings.placement,
    );

    return GameLayout(
      params: params,
      grid: grid,
      actionRow: action,
      digitPad: digits,
      isExpanded: isExpanded,
    );
  }
}
