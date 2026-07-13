import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/game_notifier.dart';
import 'package:sudoku/providers/settings_provider.dart';

class DigitPad extends ConsumerWidget {
  const DigitPad({required this.state, super.key});

  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final boardNotifier = ref.read(boardProvider.notifier);
    final digitCounts = state.grid.digitCounts;
    final showRemaining = ref.watch(
      settingsProvider.select((s) => s.showRemainingCounts),
    );

    final buttons =
        List.generate(9, (i) {
          final digit = i + 1;
          final isActive = board.selectedDigit == digit;
          final count = digitCounts[digit] ?? 0;

          return DigitButton(
            digit: '$digit',
            active: isActive,
            count: count,
            showCount: showRemaining,
            onTap: () {
              if (state.puzzleComplete) return;
              if (board.selectedCell != null) {
                gameNotifier.inputDigit(board.selectedCell!, digit);
              } else {
                boardNotifier.selectDigit(digit);
              }
            },
          );
        })..add(
          DigitButton(
            digit: 'X',
            active: false,
            count: 9,
            showCount: false,
            onTap: gameNotifier.erase,
          ),
        );

    return Padding(
      padding: const .symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: .min,
        children: [
          Wrap(spacing: 6, children: buttons.sublist(0, 5)),
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: buttons.sublist(5)),
        ],
      ),
    );
  }
}

class DigitButton extends StatelessWidget {
  const DigitButton({
    required this.digit,
    required this.active,
    required this.count,
    this.showCount = true,
    required this.onTap,
    this.size = 48.0,
    super.key,
  });
  final String digit;
  final bool active;
  final int count;
  final bool showCount;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = showCount && count != 9
        ? (count < 9 ? '${9 - count}' : '+${count - 9}')
        : null;

    final badgeFont = size * 0.2;
    final badgeOffset = size * 0.08;

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: active ? scheme.primary : Colors.transparent,
        borderRadius: .circular(6),
        border: .all(color: scheme.outlineVariant),
      ),
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: .circular(6),
        onTap: onTap,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Center(
              child: Text(
                digit,
                style: TextStyle(
                  fontSize: size * 0.48,
                  fontWeight: .w600,
                  color: active ? scheme.surface : scheme.onSurface,
                ),
              ),
            ),
            if (remaining != null)
              Positioned(
                bottom: badgeOffset,
                right: badgeOffset,
                child: Text(
                  remaining,
                  style: TextStyle(
                    fontSize: badgeFont,
                    fontWeight: .w400,
                    color: active ? scheme.surface : scheme.onSurface,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
