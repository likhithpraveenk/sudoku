import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/providers/board_notifier.dart';
import 'package:sudoku/providers/game_notifier.dart';

class ActionRow extends ConsumerWidget {
  const ActionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final board = ref.watch(boardProvider);
    final boardNotifier = ref.read(boardProvider.notifier);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Row(
      spacing: 6,
      mainAxisAlignment: .spaceEvenly,
      children: [
        _ActionButton(
          icon: Icons.refresh_rounded,
          onTap: () {
            // TODO: alert dialog to restart game
          },
        ),
        _ActionButton(
          icon: Icons.lightbulb_outline_rounded,
          onTap: () => _showMoreSheet(context, gameNotifier),
        ),
        _ActionButton(
          icon: Icons.edit_outlined,
          active: board.inputMode == .pencil,
          onTap: boardNotifier.toggleInputMode,
        ),
        _ActionButton(
          icon: Icons.undo_rounded,
          onTap: gameNotifier.canUndo ? gameNotifier.undo : null,
        ),
      ],
    );
  }

  Future<void> _showMoreSheet(
    BuildContext context,
    GameNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.lightbulb_outline_rounded),
              title: const Text('Hint'),
              onTap: () {
                Navigator.pop(ctx);
                notifier.hint();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle_outline_rounded),
              title: const Text('Check'),
              onTap: () {
                Navigator.pop(ctx);
                notifier.runValidation();
              },
            ),
            ListTile(
              leading: const Icon(Icons.autorenew),
              title: const Text('Auto Notes'),
              onTap: () {
                Navigator.pop(ctx);
                notifier.applyAutoNotes();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, this.onTap, this.active = false});

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = onTap == null
        ? scheme.onSurface.withValues(alpha: 0.3)
        : active
        ? scheme.surface
        : scheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? scheme.primary : Colors.transparent,
          borderRadius: .circular(6),
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }
}
