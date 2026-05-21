import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/breakpoints.dart';
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
    final boardNotifier = ref.watch(boardProvider.notifier);
    final digitCounts = state.grid.digitCounts;
    final showRemaining = ref.watch(settingsServiceProvider).showRemaining;

    final buttons =
        List.generate(9, (i) {
          final digit = i + 1;
          final isActive = board.selectedDigit == digit;
          final count = digitCounts[digit] ?? 0;

          return _DigitButton(
            digit: '$digit',
            active: isActive,
            count: count,
            showCount: showRemaining,
            onTap: () {
              if (board.selectedCell != null) {
                gameNotifier.inputDigit(board.selectedCell!, digit);
              } else {
                boardNotifier.selectDigit(digit);
              }
            },
          );
        })..add(
          _DigitButton(
            digit: 'X',
            active: false,
            count: 9,
            showCount: showRemaining,
            onTap: gameNotifier.erase,
          ),
        );

    return Padding(
      padding: const .symmetric(horizontal: 16),
      child: context.isExpanded
          ? Wrap(spacing: 6, runSpacing: 6, children: buttons)
          : Column(
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

class _DigitButton extends StatelessWidget {
  const _DigitButton({
    required this.digit,
    required this.active,
    required this.count,
    this.showCount = true,
    required this.onTap,
  });
  final String digit;
  final bool active;
  final int count;
  final bool showCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final remaining = showCount && count != 9
        ? (count < 9 ? '${9 - count}' : '+${count - 9}')
        : null;

    return Container(
      height: 48,
      width: 48,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: active ? scheme.surface : scheme.onSurface,
                ),
              ),
            ),
            if (remaining != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: Text(
                  remaining,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
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
