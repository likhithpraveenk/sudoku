import 'package:shared_preferences/shared_preferences.dart';
import 'package:sudoku/presentation/shared/grid_placement.dart';

class SettingsService {
  SettingsService(this._prefs);

  final SharedPreferences _prefs;

  static const _kShowRemaining = 'show_remaining';
  static const _kShowTimer = 'show_timer';
  static const _kGridWidth = 'grid_width';
  static const _kHSpacing = 'h_spacing';
  static const _kVSpacing = 'v_spacing';
  static const _kPlacement = 'placement';

  bool get showRemaining => _prefs.getBool(_kShowRemaining) ?? true;

  bool get showTimer => _prefs.getBool(_kShowTimer) ?? true;

  double get gridWidth => _prefs.getDouble(_kGridWidth) ?? 360.0;

  double get horizontalSpacing => _prefs.getDouble(_kHSpacing) ?? 16.0;

  double get verticalSpacing => _prefs.getDouble(_kVSpacing) ?? 24.0;

  GridPlacement get placement =>
      GridPlacement.values[_prefs.getInt(_kPlacement) ??
          GridPlacement.left.index];

  Future<void> setShowRemaining({required bool value}) =>
      _prefs.setBool(_kShowRemaining, value);

  Future<void> setShowTimer({required bool value}) =>
      _prefs.setBool(_kShowTimer, value);

  Future<void> setGridWidth({required double value}) =>
      _prefs.setDouble(_kGridWidth, value);

  Future<void> setHorizontalSpacing({required double value}) =>
      _prefs.setDouble(_kHSpacing, value);

  Future<void> setVerticalSpacing({required double value}) =>
      _prefs.setDouble(_kVSpacing, value);

  Future<void> setPlacement(GridPlacement p) =>
      _prefs.setInt(_kPlacement, p.index);
}
