import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../../../core/config/app_constanst.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final Box themeBox;
  final Box todoBox;
  final Box sessionBox;

  SettingsBloc({
    required this.themeBox,
    required this.todoBox,
    required this.sessionBox,
  }) : super(
         SettingsState(
           themeMode: themeBox.get(AppConstants.darkMode, defaultValue: false)
               ? ThemeMode.dark
               : ThemeMode.light,
         ),
       ) {
    on<SettingsThemeToggled>(_onThemeToggled);
    on<SettingsCacheCleared>(_onCacheCleared);
  }

  Future<void> _onThemeToggled(
    SettingsThemeToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final isDark = event.themeMode == ThemeMode.dark;
    await themeBox.put(AppConstants.darkMode, isDark);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  Future<void> _onCacheCleared(
    SettingsCacheCleared event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isCacheClearing: true, message: null));
    try {
      await todoBox.clear();
      await sessionBox.clear();
      emit(
        state.copyWith(
          isCacheClearing: false,
          message: 'Cache Cleared Successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isCacheClearing: false,
          message: 'Failed to clear cache: $e',
        ),
      );
    }
  }
}
