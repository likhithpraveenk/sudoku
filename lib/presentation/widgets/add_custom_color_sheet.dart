import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/presentation/models/theme_config.dart';
import 'package:sudoku/providers/theme_provider.dart';


class AddCustomColorSheet extends ConsumerStatefulWidget {
  const AddCustomColorSheet({super.key});

  @override
  ConsumerState<AddCustomColorSheet> createState() =>
      _AddCustomColorSheetState();
}

class _AddCustomColorSheetState extends ConsumerState<AddCustomColorSheet> {
  late final TextEditingController _controller;
  late Color _previewColor;
  late Brightness _brightness;
  String? _error;

  @override
  void initState() {
    super.initState();
    final current = ref.read(themeConfigProvider);
    _previewColor = current.seedColor;
    _brightness = current.brightness;
    _controller = TextEditingController(text: _previewColor.toHexNoAlpha());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {
      _error = null;
      try {
        _previewColor = ColorExtensions.fromHex(value);
      } catch (_) {
        _error = 'Enter a valid hex color (e.g. A1B2C3)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _previewColor,
      brightness: _brightness,
    );

    return ListView(
      padding: const .all(24),
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Hex color',
            hintText: 'A1B2C3',
            errorText: _error,
            prefixText: '#',
            helperText: '3, 6, or 8 digit hex value',
            suffixIcon: Container(
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: _previewColor, shape: .circle),
            ),
            suffixIconConstraints: const BoxConstraints(
              maxWidth: 48,
              maxHeight: 48,
            ),
          ),
          onChanged: _onChanged,
        ),
        const SizedBox(height: 16),
        SegmentedButton<Brightness>(
          segments: const [
            ButtonSegment(value: .dark, label: Text('Dark')),
            ButtonSegment(value: .light, label: Text('Light')),
          ],
          selected: {_brightness},
          onSelectionChanged: (v) => setState(() => _brightness = v.first),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: scheme.surface,
            border: .all(width: 2, color: scheme.outline),
            borderRadius: .circular(12),
          ),
          child: Row(
            spacing: 12,
            mainAxisAlignment: .center,
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
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _error == null
                ? () {
                    final config = ThemeConfig(
                      seedColor: _previewColor,
                      brightness: _brightness,
                    );
                    ref.read(customThemeProvider.notifier).add(config);
                    ref.read(themeConfigProvider.notifier).select(config);
                    Navigator.of(context).pop();
                  }
                : null,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }
}

class PreviewDot extends StatelessWidget {
  const PreviewDot({
    required this.color,
    required this.outline,
    required this.label,
    required this.textColor,
    super.key,
  });

  final Color color;
  final Color outline;
  final String label;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: .circle,
            border: .all(color: outline, width: 4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: textColor),
        ),
      ],
    );
  }
}
