import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/shared/breakpoints.dart';
import 'package:sudoku/providers/game_notifier.dart';

/// A row of digit buttons (1 through 9) used to input values or candidates
/// onto the board.
///
/// This pad highlights the button corresponding to the currently active digit
/// (either explicitly selected for digit-first entry, or matching the digit of
/// the selected cell). When a button is pressed, it routes the command through
/// the [GameNotifier] to update the selected cell or prime the global active
/// digit.
class DigitPad extends ConsumerWidget {
  /// Creates a digit input pad.
  const DigitPad({required this.state, super.key});

  /// The active state of the current game.
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final selectedCell = state.selectedCell;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(9, (i) {
          final digit = i + 1;
          final isActive =
              state.selectedDigit == digit ||
              (selectedCell != null &&
                  state.grid.valueAt(selectedCell) == digit);

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _DigitButton(
                digit: digit,
                active: isActive,
                onTap: () => notifier.pressDigit(digit),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DigitButton extends StatelessWidget {
  const _DigitButton({required this.digit, required this.active, this.onTap});
  final int digit;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: context.isExpanded ? 64 : null,
      child: AspectRatio(
        aspectRatio: context.isExpanded ? 1.0 : 0.65,
        child: Material(
          color: active ? cs.primaryContainer : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: Center(
              child: Text(
                '$digit',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: active ? cs.onPrimaryContainer : cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
