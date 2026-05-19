import 'package:flutter/material.dart';
import 'package:sudoku/domain/models/difficulty.dart';

/// Helper extension on the [Difficulty] enum.
///
/// This extension provides convenient mapping methods and getters to represent
/// [Difficulty] states on custom UI sliders and labels.
extension DifficultyExtension on Difficulty {
  /// Returns a clean, capitalized display name suitable for labels.
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
      case Difficulty.expert:
        return 'Expert';
    }
  }

  /// Maps the enum value to an index double suitable for a [Slider] component.
  double get sliderValue {
    switch (this) {
      case Difficulty.easy:
        return 0;
      case Difficulty.medium:
        return 1;
      case Difficulty.hard:
        return 2;
      case Difficulty.expert:
        return 3;
    }
  }

  /// Restores a [Difficulty] enum case from an index double chosen on a
  /// [Slider].
  static Difficulty fromSliderValue(double value) {
    final index = value.round().clamp(0, 3);
    return Difficulty.values[index];
  }
}

/// A custom slider widget used to pick a Sudoku gameplay difficulty level.
///
/// This slider maps the discrete values of the [Difficulty] enum (Easy, Medium,
/// Hard, Expert) to four stops on a standard [Slider] widget, displaying the
/// active selection in a text label below the slider track.
class DifficultySlider extends StatelessWidget {
  /// Creates a difficulty slider widget.
  const DifficultySlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// The currently selected difficulty level.
  final Difficulty value;

  /// Callback function triggered when the user moves the slider to a new
  /// difficulty.
  final void Function(Difficulty) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Slider(
          value: value.sliderValue,
          max: 3,
          divisions: 3,
          label: value.displayName,
          activeColor: colorScheme.primary,
          thumbColor: colorScheme.primary,
          onChanged: (newValue) {
            final newDifficulty = DifficultyExtension.fromSliderValue(newValue);
            onChanged(newDifficulty);
          },
        ),
        const SizedBox(height: 12),
        Text(value.displayName, style: theme.textTheme.titleLarge),
      ],
    );
  }
}
