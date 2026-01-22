import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class SettingsThemeToggled extends SettingsEvent {
  final ThemeMode themeMode;

  const SettingsThemeToggled(this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class SettingsCacheCleared extends SettingsEvent {}
