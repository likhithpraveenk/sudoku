import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/models/theme_config.dart';
import 'package:sudoku/presentation/widgets/add_custom_color_sheet.dart';
import 'package:sudoku/providers/theme_provider.dart';

class CustomColorsScreen extends ConsumerWidget {
  const CustomColorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final custom = ref.watch(customThemeProvider);
    final active = ref.watch(themeConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Custom colors')),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Add color',
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => const AddCustomColorSheet(),
          );
        },
      ),
      floatingActionButtonLocation: .centerFloat,
      body: SingleChildScrollView(
        padding: const .only(bottom: 48),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView.separated(
              padding: const .all(12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: custom.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final config = custom[index];
                final isActive = config == active;

                return _CustomColorRow(
                  config: config,
                  isActive: isActive,
                  onTap: () =>
                      ref.read(themeConfigProvider.notifier).select(config),
                  onDelete: () {
                    final wasActive = isActive;
                    ref.read(customThemeProvider.notifier).remove(config);
                    if (wasActive) {
                      ref
                          .read(themeConfigProvider.notifier)
                          .select(builtInThemes.first);
                    }
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomColorRow extends StatelessWidget {
  const _CustomColorRow({
    required this.config,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  final ThemeConfig config;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = ColorScheme.fromSeed(
      seedColor: config.seedColor,
      brightness: config.brightness,
    );

    return InkWell(
      borderRadius: .circular(12),
      onTap: onTap,
      child: Container(
        padding: const .symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: .circular(12),
          border: Border.all(
            width: 4,
            color: isActive ? scheme.primaryContainer : scheme.surfaceContainer,
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Text(
                    config.seedColor.toHexNoAlpha(addHash: true),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: .bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    spacing: 6,
                    children: [
                      PreviewDot(
                        color: scheme.primary,
                        label: 'Primary',
                        outline: scheme.primaryContainer,
                        textColor: scheme.onSurface,
                      ),
                      PreviewDot(
                        color: scheme.error,
                        label: 'Error',
                        outline: scheme.errorContainer,
                        textColor: scheme.onSurface,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Remove',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
