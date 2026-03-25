import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeModeNotifier extends _$ThemeModeNotifier {
  static const String _boxName = 'settings';
  static const String _key = 'theme_mode';

  @override
  ThemeMode build() {
    final box = Hive.box(_boxName);
    final themeIndex =
        box.get(_key, defaultValue: ThemeMode.system.index) as int;
    return ThemeMode.values[themeIndex];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final box = Hive.box(_boxName);
    await box.put(_key, mode.index);
    state = mode;
  }
}
