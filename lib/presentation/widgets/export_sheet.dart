import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:sudoku/domain/export/puzzle_export.dart';
import 'package:sudoku/domain/models/game_state.dart';

Future<void> showExportSheet(BuildContext context, GameState state) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    // M3: modal bottom sheets carry a drag handle and cap at 640dp, so they do
    // not stretch across a wide window on web or tablet.
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (_) => ExportSheet(state: state),
  );
}

class ExportSheet extends StatefulWidget {
  const new({required this.state, super.key});

  final GameState state;

  @override
  State<ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<ExportSheet> {
  ExportContent content = .progress;
  ExportFormat format = .pencilmarks;
  bool withPrompt = false;
  bool copied = false;
  Timer? _copiedTimer;

  late final PuzzleExport export = PuzzleExport.fromState(widget.state);

  String get text =>
      export.render(content: content, format: format, withPrompt: withPrompt);

  @override
  void dispose() {
    _copiedTimer?.cancel();
    super.dispose();
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    setState(() => copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Supporting text uses bodyMedium (14), not bodySmall (12), so it stays
    // readable at arm's length. 12 is Material's floor for captions.
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final label = theme.textTheme.labelLarge?.copyWith(
      fontWeight: .bold,
      color: scheme.onSurfaceVariant,
    );

    // The preview keeps one height for every option, so the sheet does not jump
    // when the format changes. 13 lines is the tallest format (the pencilmark
    // grid); a longer prompt scrolls inside the box instead of growing it. The
    // cap stops the box crowding out the options on a short screen.
    final line = MediaQuery.textScalerOf(context).scale(14) * 1.3;
    final previewHeight = math.min(
      line * 13 + 24,
      MediaQuery.sizeOf(context).height * .45,
    );

    // The headline and the Copy button stay put; only the options between
    // them scroll, so the primary action is never pushed off a small screen.
    return SafeArea(
      child: Padding(
        padding: const .fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Center(child: Text('Export', style: theme.textTheme.headlineSmall)),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Copy the board as text for an AI chat or solver.',
                style: muted,
                textAlign: .center,
              ),
            ),
            const SizedBox(height: 24),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text('Content', style: label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in ExportContent.values)
                          ChoiceChip(
                            label: Text(c.label),
                            selected: content == c,
                            onSelected: (_) => setState(() => content = c),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(content.description, style: muted),
                    const SizedBox(height: 20),
                    Text('Format', style: label),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final f in ExportFormat.values)
                          ChoiceChip(
                            label: Text(f.label),
                            selected: format == f,
                            onSelected: (_) => setState(() => format = f),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(format.description, style: muted),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: .zero,
                      title: const Text('Add AI prompt'),
                      subtitle: Text(
                        'Asks for a nudge first, not the solution.',
                        style: muted,
                      ),
                      value: withPrompt,
                      onChanged: (v) => setState(() => withPrompt = v),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: previewHeight,
                      padding: const .all(12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: .circular(6),
                      ),
                      child: SingleChildScrollView(
                        child: SingleChildScrollView(
                          scrollDirection: .horizontal,
                          child: SelectableText(
                            text,
                            // 'monospace' only resolves on Android and web;
                            // the fallbacks keep the columns aligned on iOS,
                            // macOS and Windows.
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontFamilyFallback: const [
                                'Courier New',
                                'Consolas',
                                'Menlo',
                              ],
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              // Announced to screen readers, since the label change is the only
              // feedback that the copy worked.
              child: Semantics(
                liveRegion: true,
                child: FilledButton.icon(
                  onPressed: _copy,
                  icon: Icon(copied ? Icons.check_rounded : Icons.copy_rounded),
                  label: Text(copied ? 'Copied' : 'Copy'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
