import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  final ThemeMode themeMode;
  final bool isCacheClearing;
  final String? message;

  const SettingsState({
    required this.themeMode,
    this.isCacheClearing = false,
    this.message,
  });

  factory SettingsState.initial() {
    return const SettingsState(themeMode: ThemeMode.system);
  }

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? isCacheClearing,
    String? message,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      isCacheClearing: isCacheClearing ?? this.isCacheClearing,
      message: message,
    );
  }

  @override
  List<Object?> get props => [themeMode, isCacheClearing, message];
}
