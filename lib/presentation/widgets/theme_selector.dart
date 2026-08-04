import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/models/theme_config.dart';
import 'package:sudoku/presentation/widgets/theme_swatch.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/providers/theme_provider.dart';

class ThemeSelector extends ConsumerStatefulWidget {
  const ThemeSelector({super.key});

  @override
  ConsumerState<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends ConsumerState<ThemeSelector>
    with SingleTickerProviderStateMixin {
  final _controller = OverlayPortalController();
  final _link = LayerLink();
  final _groupId = Object();

  late final AnimationController _animation;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );

    _opacity = CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic);

    _scale = Tween(begin: .95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _animation.addStatusListener((status) {
      if (status == .dismissed) {
        _controller.hide();
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  bool get removeAnimations => ref.read(settingsProvider).removeAnimations;

  void _toggle() {
    if (removeAnimations) {
      if (_controller.isShowing) {
        _controller.hide();
      } else {
        _controller.show();
      }
      return;
    }
    if (_controller.isShowing) {
      _animation.reverse();
    } else {
      _controller.show();
      _animation.forward(from: 0);
    }
  }

  void _hide() {
    if (removeAnimations) {
      _controller.hide();
      return;
    }
    if (_controller.isShowing) {
      _animation.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final customThemes = ref.watch(customThemeProvider);
    final scheme = Theme.of(context).colorScheme;

    return TapRegion(
      groupId: _groupId,
      onTapOutside: (_) => _hide(),
      child: OverlayPortal(
        controller: _controller,
        overlayChildBuilder: (context) {
          return TapRegion(
            groupId: _groupId,
            child: UnconstrainedBox(
              alignment: .topRight,
              child: CompositedTransformFollower(
                link: _link,
                targetAnchor: .bottomRight,
                followerAnchor: .topRight,
                offset: const Offset(-1.6, 3),
                child: Material(
                  color: Colors.transparent,
                  child: FadeTransition(
                    opacity: _opacity,
                    child: ScaleTransition(
                      scale: _scale,
                      alignment: .topRight,
                      child: Container(
                        padding: const .all(8),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: .circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 200,
                            maxHeight: MediaQuery.sizeOf(context).height * .5,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: .min,
                              children: [
                                for (var i = 0; i < customThemes.length; i++)
                                  Padding(
                                    padding: const .symmetric(vertical: 4),
                                    child: ThemeSwatch(
                                      index: i,
                                      config: customThemes[i],
                                    ),
                                  ),
                                if (customThemes.isNotEmpty)
                                  Container(
                                    width: 32,
                                    margin: const .symmetric(vertical: 4),
                                    color: scheme.outline,
                                    height: 2,
                                  ),
                                for (var i = 0; i < builtInThemes.length; i++)
                                  Padding(
                                    padding: const .symmetric(vertical: 4),
                                    child: ThemeSwatch(
                                      index: i,
                                      config: builtInThemes[i],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
        child: CompositedTransformTarget(
          link: _link,
          child: Padding(
            padding: const .only(right: 4),
            child: IconButton(
              tooltip: 'Theme Selector',
              icon: const Icon(Icons.palette_outlined),
              onPressed: _toggle,
            ),
          ),
        ),
      ),
    );
  }
}
