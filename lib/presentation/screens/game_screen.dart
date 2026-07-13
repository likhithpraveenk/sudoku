import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/utils.dart';
import 'package:sudoku/presentation/widgets/action_row.dart';
import 'package:sudoku/presentation/widgets/digit_pad.dart';
import 'package:sudoku/presentation/widgets/game_layout.dart';
import 'package:sudoku/presentation/widgets/grid_widget.dart';
import 'package:sudoku/presentation/widgets/solved_overlay.dart';
import 'package:sudoku/presentation/widgets/theme_selector.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/game_notifier.dart';
import 'package:sudoku/providers/services_provider.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/providers/stats_provider.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameProvider);
    final gameNotifier = ref.watch(gameProvider.notifier);
    final showTimer = ref.watch(settingsProvider.select((s) => s.showTimer));
    final game = gameAsync.value;

    final board = ref.watch(boardProvider);
    final boardNotifier = ref.read(boardProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          fit: .expand,
          children: [
            gameAsync.when(
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
                    final current = board.selectedCell ?? 0;

                    switch (key) {
                      case .arrowLeft || .keyA:
                        if (current % 9 > 0) {
                          boardNotifier.selectCell(current - 1);
                        }
                        return .handled;
                      case .arrowRight || .keyD:
                        if (current % 9 < 8) {
                          boardNotifier.selectCell(current + 1);
                        }
                        return .handled;
                      case .arrowUp || .keyW:
                        if (current >= 9) boardNotifier.selectCell(current - 9);
                        return .handled;
                      case .arrowDown || .keyS:
                        if (current <= 71) {
                          boardNotifier.selectCell(current + 9);
                        }
                        return .handled;
                      case .backspace || .delete:
                        gameNotifier.erase();
                        return .handled;
                      default:
                    }
                    if (key.keyLabel.length == 1) {
                      final d = int.tryParse(key.keyLabel);
                      if (d != null && d >= 1 && d <= 9) {
                        if (board.selectedCell != null) {
                          gameNotifier.inputDigit(board.selectedCell!, d);
                        } else {
                          boardNotifier.selectDigit(d);
                        }
                        return .handled;
                      }
                    }
                    if (key.keyLabel.toLowerCase() == 'p') {
                      boardNotifier.toggleInputMode();
                      return .handled;
                    }
                    return .ignored;
                  },
                  child: _GameBody(state: game),
                );
              },
            ),
            Align(
              alignment: .topCenter,
              child: Padding(
                padding: const .all(6),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    if (showTimer && game != null && !game.puzzleComplete)
                      Text(
                        formatTime(game.elapsed),
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    const ThemeSelector(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameBody extends ConsumerStatefulWidget {
  const _GameBody({required this.state});
  final GameState state;

  @override
  ConsumerState<_GameBody> createState() => _GameBodyState();
}

class _GameBodyState extends ConsumerState<_GameBody>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == .paused || state == .detached || state == .hidden) {
      final current = ref.read(gameProvider).value;
      if (current != null) {
        ref.read(saveGameServiceProvider).save(current);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isFinishedProvider, (_, next) {
      if (next) {
        final record = ref.read(lastCompletionRecordProvider);
        if (record != null) {
          showSolvedOverlay(context, ref, record);
        }
        ref.read(boardProvider.notifier).reset();
      }
    });

    final grid = GridWidget(gameState: widget.state);
    const action = ActionRow();
    final digits = DigitPad(state: widget.state);

    return GameLayout(grid: grid, digitPad: digits, actionRow: action);
  }
}
