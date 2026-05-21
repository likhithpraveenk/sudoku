import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/presentation/screens/home_screen.dart';
import 'package:sudoku/presentation/widgets/no_scrollbar_behavior.dart';
import 'package:sudoku/providers/settings_provider.dart';
import 'package:sudoku/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  // debugRepaintRainbowEnabled = true;
  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(currentThemeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sudoku',
      theme: theme,
      scrollBehavior: NoScrollbarBehavior(),
      home: const HomeScreen(),
    );
  }
}
