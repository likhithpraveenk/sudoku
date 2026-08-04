import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/domain/models/stat_record.dart';
import 'package:sudoku/presentation/shared/utils.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/providers/stats_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  late final PageController _pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _page);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    final difficulty = Difficulty.values[_page];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset statistics?'),
        content: Text(
          'This will delete all ${difficulty.displayName} records. '
          'This cannot be undone',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
        actionsAlignment: .spaceBetween,
      ),
    );
    if (confirmed == true) {
      await ref
          .read(statsNotifierProvider.notifier)
          .resetPerDifficulty(difficulty);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allStats = ref.watch(statsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            tooltip: 'Reset difficulty',
            onPressed: allStats[Difficulty.values[_page]]!.isEmpty
                ? null
                : _reset,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          _DifficultyHeader(pageController: _pageController, index: _page),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: Difficulty.values.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (context, index) {
                final difficulty = Difficulty.values[index];
                final records = allStats[difficulty] ?? const [];
                return _DifficultyStats(
                  key: ValueKey(difficulty),
                  difficulty: difficulty,
                  records: records,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyHeader extends ConsumerWidget {
  const _DifficultyHeader({required this.pageController, required this.index});

  final PageController pageController;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final removeAnimations = ref.watch(
      settingsProvider.select((s) => s.removeAnimations),
    );

    return Row(
      mainAxisAlignment: .center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: index > 0
              ? () => pageController.previousPage(
                  duration: removeAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 250),
                  curve: Curves.ease,
                )
              : null,
        ),
        SizedBox(
          width: 150,
          child: Text(
            Difficulty.values[index].displayName,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: .bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: index < Difficulty.values.length - 1
              ? () => pageController.nextPage(
                  duration: removeAnimations
                      ? Duration.zero
                      : const Duration(milliseconds: 250),
                  curve: Curves.ease,
                )
              : null,
        ),
      ],
    );
  }
}

class _DifficultyStats extends StatelessWidget {
  const _DifficultyStats({
    super.key,
    required this.difficulty,
    required this.records,
  });

  final Difficulty difficulty;
  final List<StatRecord> records;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (records.isEmpty) {
      return Center(
        child: Padding(
          padding: const .all(24),
          child: Text(
            'No games completed yet.\nFinish a ${difficulty.displayName} '
            'puzzle to see your stats.',
            textAlign: .center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final clean = records.where((r) => r.isClean).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final assisted = records.where((r) => !r.isClean).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    final cleanBest = clean.firstOrNull;
    final assistedBest = assisted.firstOrNull;
    final bestTime = (cleanBest ?? assistedBest)?.time;
    final avgTime = Duration(
      milliseconds:
          records.map((r) => r.time.inMilliseconds).reduce((a, b) => a + b) ~/
          records.length,
    );

    return ListView(
      padding: const .all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Best time',
                value: bestTime != null ? formatTime(bestTime) : '—',
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatCard(label: 'Average', value: formatTime(avgTime)),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _StatCard(label: 'Played', value: '${records.length}'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (cleanBest != null)
          _BestTile(title: 'Best (no assists)', record: cleanBest),
        if (assistedBest != null)
          _BestTile(title: 'Best (with assists)', record: assistedBest),
        const SizedBox(height: 24),
        Text(
          'Recent games',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...records.reversed.map((r) => _RecordTile(record: r)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const .all(12),
        child: Column(
          children: [
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: .bold),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestTile extends StatelessWidget {
  const _BestTile({required this.title, required this.record});

  final String title;
  final StatRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: .zero,
      leading: const Icon(Icons.emoji_events_outlined),
      title: Text(title),
      subtitle: Text(
        record.assistsUsed.isEmpty ? 'No assists' : record.assistsUsed,
      ),
      trailing: Text(
        formatTime(record.time),
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: .bold),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final StatRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: .zero,
      leading: Icon(
        record.isClean ? Icons.shield_outlined : Icons.handyman_outlined,
        color: record.isClean
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
      ),
      title: Text(formatTime(record.time)),
      subtitle: Text(
        record.assistsUsed.isEmpty ? 'No assists' : record.assistsUsed,
      ),
      trailing: Text(
        formatDate(record.completedAt),
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
