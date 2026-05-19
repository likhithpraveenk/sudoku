import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sudoku/domain/models/difficulty.dart';
import 'package:sudoku/presentation/screens/game_screen.dart';
import 'package:sudoku/presentation/widgets/difficulty_slider.dart';
import 'package:sudoku/providers/game_notifier.dart';

/// The landing/home screen of the Sudoku application.
///
/// This screen provides an intuitive user interface for players to select their
/// desired gameplay difficulty (Easy, Medium, Hard, Expert) via a
/// [DifficultySlider] and initiate a new game. When the start button is
/// tapped, it requests the generator service to prepare a valid, unique puzzle
/// and transitions seamlessly to the [GameScreen] once ready.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates the home screen.
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Difficulty _selected = Difficulty.easy;
  bool _loading = false;

  Future<void> _start() async {
    setState(() => _loading = true);
    await ref.read(gameProvider.notifier).startGame(_selected);
    if (mounted) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const GameScreen()));
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const .symmetric(horizontal: 24, vertical: 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisAlignment: .center,
                children: [
                  Text('Sudoku', style: textTheme.displaySmall),
                  const SizedBox(height: 36),
                  DifficultySlider(
                    value: _selected,
                    onChanged: (value) {
                      setState(() {
                        _selected = value;
                      });
                    },
                  ),
                  const SizedBox(height: 36),
                  OutlinedButton(
                    onPressed: _loading ? null : _start,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: .circular(4)),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text('Start Game', style: textTheme.labelLarge),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
