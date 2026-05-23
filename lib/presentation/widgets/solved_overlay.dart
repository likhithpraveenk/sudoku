import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/game_state.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/presentation/shared/utils.dart';
import 'package:sudoku/providers/game_notifier.dart';
import 'package:sudoku/providers/services_provider.dart';

void showSolvedOverlay(BuildContext context, WidgetRef ref, GameState game) {
  final record = ref.read(gameProvider.notifier).lastRecord;
  if (!game.puzzleComplete || record == null) {
    return;
  }
  final top = ref.read(topStatsProvider(game.difficulty));
  final list = record.isClean ? top.clean : top.assisted;

  final displayList = list.take(10).toList();
  final currentRecordIndex = list.indexWhere(
    (item) => item.completedAt == record.completedAt,
  );
  final isRecordInTop10 = currentRecordIndex >= 0 && currentRecordIndex < 10;

  if (!isRecordInTop10 && currentRecordIndex != -1) {
    displayList.add(record);
  }

  showDialog(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;

      return Dialog(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        child: SolvedOverlay(
          currentRecordIndex: currentRecordIndex,
          record: record,
          displayList: displayList,
        ),
      );
    },
  );
}

class SolvedOverlay extends StatelessWidget {
  const SolvedOverlay({
    required this.record,
    required this.displayList,
    required this.currentRecordIndex,
    super.key,
  });

  final int currentRecordIndex;
  final StatRecord record;
  final List<StatRecord> displayList;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: .circular(12),
          border: .all(color: scheme.primary),
        ),
        padding: const .all(24),
        child: Column(
          mainAxisSize: .min,
          children: [
            Text(
              record.difficulty.displayName,
              style: textTheme.labelLarge?.copyWith(
                color: scheme.primary,
                fontWeight: .bold,
              ),
            ),
            if (record.assistsUsed.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Assists: ${record.assistsUsed}',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: displayList.length,
                itemBuilder: (context, index) {
                  final item = displayList[index];
                  final isCurrentRecord =
                      item.completedAt == record.completedAt;
                  final trueRank = isCurrentRecord
                      ? currentRecordIndex + 1
                      : index + 1;

                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$trueRank.',
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: isCurrentRecord ? .bold : .normal,
                              color: isCurrentRecord
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            formatDate(item.completedAt),
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: isCurrentRecord ? .bold : .normal,
                              color: isCurrentRecord
                                  ? scheme.primary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          formatTime(item.time),
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: isCurrentRecord ? .bold : .normal,
                            color: isCurrentRecord
                                ? scheme.primary
                                : scheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
