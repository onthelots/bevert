import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();
}

class ThemeInitial extends ThemeState {
  final ThemeMode themeMode;

  const ThemeInitial({required this.themeMode});

  @override
  List<Object> get props => [themeMode];
}
