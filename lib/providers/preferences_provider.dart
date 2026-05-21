import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final FutureProvider<SharedPreferences> sharedPreferencesProvider =
    FutureProvider((ref) => SharedPreferences.getInstance());
