import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode { light, dark }
enum SortOrder { titleAsc, titleDesc }

class SettingsController extends ChangeNotifier {
  static const _kTheme = 'pref_theme';
  static const _kSort = 'pref_sort_order';
  static const _kScale = 'pref_text_scale';
  static const _kSearchInDescription = 'pref_search_in_description';

  AppThemeMode _theme = AppThemeMode.dark;
  SortOrder _sort = SortOrder.titleAsc;
  double _textScale = 1.0; // 0.85 .. 1.30
  bool _searchInDescription = false;

  AppThemeMode get theme => _theme;
  SortOrder get sort => _sort;
  double get textScale => _textScale;
  bool get searchInDescription => _searchInDescription;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    _theme = AppThemeMode.values[p.getInt(_kTheme) ?? AppThemeMode.dark.index];
    _sort = SortOrder.values[p.getInt(_kSort) ?? SortOrder.titleAsc.index];
    _textScale = p.getDouble(_kScale) ?? 1.0;
    _searchInDescription = p.getBool(_kSearchInDescription) ?? false;
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode m) async {
    _theme = m;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kTheme, m.index);
    notifyListeners();
  }

  Future<void> setSort(SortOrder s) async {
    _sort = s;
    final p = await SharedPreferences.getInstance();
    await p.setInt(_kSort, s.index);
    notifyListeners();
  }

  Future<void> setTextScale(double v) async {
    _textScale = v.clamp(0.85, 1.30);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kScale, _textScale);
    notifyListeners();
  }

  Future<void> setSearchInDescription(bool v) async {
    _searchInDescription = v;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kSearchInDescription, v);
    notifyListeners();
  }
}
