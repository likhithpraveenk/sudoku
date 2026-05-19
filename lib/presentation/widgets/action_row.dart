import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/input_method.dart';
import 'package:sudoku/providers/game_notifier.dart';

/// The gameplay action row positioned above the digit pad on the Game Screen.
///
/// This row provides players with a series of quick-access action buttons to:
/// * **Undo**: Revert the last move (digit placement, note toggle, or erase).
/// * **Erase**: Clear the value or notes of the selected cell.
/// * **Pencil**: Toggle the input mode between direct digits and pencil notes.
/// * **Hint**: Query the solver engine for a smart logical hint and apply it.
/// * **Check**: Run validation and flag incorrect entries on the board.
/// * **AutoNotes**: Pre-fill all empty cells with valid pencil candidates.
class ActionRow extends ConsumerWidget {
  /// Creates the action control row.
  const ActionRow({required this.state, super.key});

  /// The active state of the current game.
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(gameProvider.notifier);
    final isPencil = state.inputMode == InputMode.pencil;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.undo_rounded,
          label: 'Undo',
          onTap: notifier.canUndo ? notifier.undo : null,
        ),
        _ActionButton(
          icon: Icons.backspace_outlined,
          label: 'Erase',
          onTap: state.selectedCell != null
              ? () => notifier.erase(state.selectedCell!)
              : null,
        ),
        _ActionButton(
          icon: Icons.edit_outlined,
          label: 'Pencil',
          active: isPencil,
          onTap: notifier.toggleInputMode,
        ),
        _ActionButton(
          icon: Icons.lightbulb_outline_rounded,
          label: 'Hint',
          onTap: () {
            notifier.applyHint((message) {
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            });
          },
        ),
        _ActionButton(
          icon: Icons.check_circle_outline_rounded,
          label: 'Check',
          onTap: notifier.runValidation,
        ),
        _ActionButton(
          icon: Icons.autorenew,
          label: 'AutoNotes',
          onTap: notifier.applyAutoNotes,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = onTap == null
        ? cs.onSurface.withValues(alpha: 0.3)
        : active
        ? cs.primary
        : cs.onSurface;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 60,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}
