import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class ThemeInitialEvent extends ThemeEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class ThemeChanged extends ThemeEvent {
  final ThemeMode themeMode;

  const ThemeChanged({required this.themeMode});

  @override
  List<Object> get props => [themeMode];
}
