import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';

class SolvedOverlay extends ConsumerWidget {
  const SolvedOverlay({required this.state, this.onBack, super.key});

  final GameState state;

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final minutes = state.elapsed.inMinutes;
    final seconds = state.elapsed.inSeconds % 60;
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    final timeStr = '$mStr:$sStr';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_rounded, size: 72, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Puzzle Solved!',
              style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text('Time: $timeStr', style: tt.bodyLarge),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () {
                onBack?.call();
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.home_rounded),
              label: const Text('Back to Home'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
