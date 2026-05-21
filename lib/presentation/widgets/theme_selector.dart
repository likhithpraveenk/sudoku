import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/widgets/theme_swatch.dart';
import 'package:sudoku/providers/theme_provider.dart';

class ThemeSelector extends ConsumerStatefulWidget {
  const ThemeSelector({super.key});

  @override
  ConsumerState<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends ConsumerState<ThemeSelector> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(allThemesProvider);
    final scheme = Theme.of(context).colorScheme;

    return TapRegion(
      onTapOutside: (_) => setState(() => _expanded = false),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .end,
        children: [
          Padding(
            padding: const .only(right: 4),
            child: IconButton(
              tooltip: 'Theme Selector',
              icon: const Icon(Icons.palette_outlined),
              onPressed: () => setState(() => _expanded = !_expanded),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topRight,
              heightFactor: _expanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              curve: _expanded ? Curves.easeOutCubic : Curves.easeInCubic,
              child: Container(
                margin: const .only(top: 4),
                padding: const .all(8),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: .circular(6),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(context).height * 0.5,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Padding(
                            padding: const .symmetric(vertical: 4),
                            child: ThemeSwatch(index: i, config: items[i]),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
