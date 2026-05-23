import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:sudoku/data/hive_boxes.dart';
import 'package:sudoku/presentation/screens/home_screen.dart';
import 'package:sudoku/presentation/widgets/no_scrollbar_behavior.dart';
import 'package:sudoku/providers/theme_provider.dart';

final class Logger extends ProviderObserver {
  @override
  void didAddProvider(ProviderObserverContext context, Object? value) {
    log('[+] $value', name: '${context.provider.name}');
  }

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    log('[~] $newValue', name: '${context.provider.name}');
  }

  @override
  void didDisposeProvider(ProviderObserverContext context) {
    log('[-]', name: '${context.provider.name}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Future.wait([
    Hive.openBox<String>(settingsBox),
    Hive.openBox<String>(themeBox),
    Hive.openBox<List>(statsBox),
    Hive.openBox<String>(gameBox),
  ]);
  // debugRepaintRainbowEnabled = true;
  runApp(ProviderScope(observers: [Logger()], child: const MyApp()));
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
