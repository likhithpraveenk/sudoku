import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/models/theme_config.dart';
import 'package:sudoku/providers/theme_provider.dart';

class ThemeSwatch extends ConsumerWidget {
  const ThemeSwatch({required this.index, required this.config, super.key});

  final int index;
  final ThemeConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeConfigProvider);
    final active =
        theme.seedColor == config.seedColor &&
        theme.brightness == config.brightness;

    final scheme = ColorScheme.fromSeed(
      seedColor: config.seedColor,
      brightness: config.brightness,
    );

    return GestureDetector(
      onTap: () {
        ref.read(themeConfigProvider.notifier).select(config);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 32,
        height: 32,
        padding: .all(active ? 4 : 6),
        decoration: BoxDecoration(
          color: active ? scheme.surface : scheme.primary,
          shape: .circle,
          border: Border.all(
            color: active ? scheme.primary : scheme.surface,
            width: active ? 4 : 6,
          ),
        ),
      ),
    );
  }
}
