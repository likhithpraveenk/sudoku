import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/domain/models/input_method.dart';
import 'package:sudoku/providers/board_notifier.dart';

void main() {
  group('BoardNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    test('initial state', () {
      final state = container.read(boardProvider);

      expect(state.selectedCell, isNull);
      expect(state.selectedDigit, isNull);
      expect(state.inputMode, InputMode.number);
      expect(state.errorCells, isEmpty);
    });

    group('selectCell', () {
      test('selects cell', () {
        container.read(boardProvider.notifier).selectCell(4);

        expect(container.read(boardProvider).selectedCell, 4);
      });

      test('toggles selected cell off', () {
        container.read(boardProvider.notifier)
          ..selectCell(4)
          ..selectCell(4);

        expect(container.read(boardProvider).selectedCell, isNull);
      });
    });

    group('selectDigit', () {
      test('selects digit', () {
        container.read(boardProvider.notifier).selectDigit(7);

        expect(container.read(boardProvider).selectedDigit, 7);
      });

      test('toggles selected digit off', () {
        container.read(boardProvider.notifier)
          ..selectDigit(7)
          ..selectDigit(7);

        expect(container.read(boardProvider).selectedDigit, isNull);
      });
    });

    group('toggleInputMode', () {
      test('number -> pencil', () {
        container.read(boardProvider.notifier).toggleInputMode();

        expect(container.read(boardProvider).inputMode, InputMode.pencil);
      });

      test('pencil -> number', () {
        final notifier = container.read(boardProvider.notifier);

        notifier
          ..toggleInputMode()
          ..toggleInputMode();

        expect(container.read(boardProvider).inputMode, InputMode.number);
      });
    });

    group('setErrorCells', () {
      test('sets error cells', () {
        container.read(boardProvider.notifier).setErrorCells({1, 5, 9});

        expect(container.read(boardProvider).errorCells, {1, 5, 9});
      });

      test('replaces previous error cells', () {
        final notifier = container.read(boardProvider.notifier);

        notifier
          ..setErrorCells({1, 2})
          ..setErrorCells({8});

        expect(container.read(boardProvider).errorCells, {8});
      });

      test('clears error cells', () {
        final notifier = container.read(boardProvider.notifier);

        notifier
          ..setErrorCells({1, 2})
          ..setErrorCells({});

        expect(container.read(boardProvider).errorCells, isEmpty);
      });
    });
  });
}
