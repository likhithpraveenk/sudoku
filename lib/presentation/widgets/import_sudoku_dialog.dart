import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/engine/game_utils.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/presentation/screens/game_screen.dart';
import 'package:sudoku/providers/services_provider.dart';

class ImportSudokuDialog extends ConsumerStatefulWidget {
  const ImportSudokuDialog({super.key});

  @override
  ConsumerState<ImportSudokuDialog> createState() => _ImportSudokuState();
}

class _ImportSudokuState extends ConsumerState<ImportSudokuDialog> {
  final controller = TextEditingController();
  String? errorText;
  Difficulty? computedDifficulty;
  GameState? validPuzzle;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        mainAxisSize: .min,
        children: [
          const Text('Import Puzzle'),
          if (computedDifficulty != null)
            Padding(
              padding: const .only(top: 12),
              child: Text(
                'Detected difficulty: ${computedDifficulty!.displayName}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
        ],
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: .min,
          children: [
            TextFormField(
              controller: controller,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Paste 81-digit puzzle here. The gaps can be `0`, `.`, `x`, `X`, `_`',
                border: const OutlineInputBorder(),
                errorText: errorText,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter or paste a puzzle';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final file = await FilePicker.pickFile(type: .any);
                  if (file == null) return;
                  final bytes = await file.readAsBytes();
                  final raw = String.fromCharCodes(bytes);
                  controller.text = raw;
                  setState(() {});
                },
                icon: const Icon(Icons.folder_open_outlined),
                label: const Text('Pick File'),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: .spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (validPuzzle != null)
          FilledButton(
            onPressed: () async {
              await ref.read(saveGameServiceProvider).save(validPuzzle!);
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const GameScreen()),
                );
              }
            },
            child: const Text('Start'),
          ),
        OutlinedButton(
          onPressed: () async {
            final raw = controller.text.trim();
            if (raw.isEmpty) return;

            try {
              final puzzleString = parsePuzzleInput(raw);
              final service = ref.read(puzzleImportServiceProvider);
              final state = await service.loadPuzzleIntoGame(puzzleString);
              setState(() {
                computedDifficulty = state.difficulty;
                validPuzzle = state;
                errorText = null;
              });
            } on FormatException catch (e) {
              setState(() {
                errorText = e.message;
                validPuzzle = null;
              });
            } catch (_) {
              setState(() {
                errorText = 'Failed to load puzzle';
                validPuzzle = null;
              });
            }
          },
          child: const Text('Import'),
        ),
      ],
    );
  }
}
