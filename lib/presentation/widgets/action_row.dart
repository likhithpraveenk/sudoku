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
    final isFinished = ref.watch(isFinishedProvider);

    return IgnorePointer(
      ignoring: isFinished,
      child: Row(
        spacing: 6,
        mainAxisAlignment: .spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              gameNotifier.restart();
              boardNotifier.reset();
            },
            tooltip: 'Reset',
          ),
          _ActionButton(
            icon: Icons.lightbulb_outline_rounded,
            onTap: () => _showMoreSheet(context, gameNotifier),
            tooltip: 'Hint',
          ),
          _ActionButton(
            icon: Icons.edit_outlined,
            active: board.inputMode == .pencil,
            onTap: boardNotifier.toggleInputMode,
            tooltip: 'Pencil',
          ),
          _ActionButton(
            icon: Icons.undo_rounded,
            onTap: gameNotifier.undo,
            tooltip: 'Undo',
          ),
        ],
      ),
    );
  }

  Future<void> _showMoreSheet(
    BuildContext context,
    GameNotifier notifier,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const .only(bottom: 48, top: 24),
          child: Column(
            mainAxisSize: .min,
            children: [
              Text('Hints', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.lightbulb_outline_rounded),
                title: const Text('Reveal a cell'),
                onTap: () {
                  Navigator.pop(ctx);
                  notifier.hint();
                },
              ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline_rounded),
                title: const Text('Validate'),
                onTap: () {
                  Navigator.pop(ctx);
                  notifier.runValidation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.autorenew),
                title: const Text('Auto fill all notes'),
                onTap: () {
                  Navigator.pop(ctx);
                  notifier.applyAutoNotes();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    this.onTap,
    this.active = false,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = onTap == null
        ? scheme.onSurface.withValues(alpha: 0.3)
        : active
        ? scheme.surface
        : scheme.onSurface;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: .circular(6),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: active ? scheme.primary : Colors.transparent,
            borderRadius: .circular(6),
          ),
          child: Icon(icon, color: color, size: 26),
        ),
      ),
    );
  }
}
