import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/providers/difficulty_provider.dart';

class DifficultySelector extends ConsumerWidget {
  const DifficultySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final difficulty = ref.watch(difficultyProvider);

    return Wrap(
      spacing: 8,
      children: Difficulty.values.map((d) {
        final selected = d == difficulty;
        return ChoiceChip(
          label: Text(d.displayName),
          selected: selected,
          onSelected: (_) {
            ref.read(difficultyProvider.notifier).set(d);
          },
        );
      }).toList(),
    );
  }
}
