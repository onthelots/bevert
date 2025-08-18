import 'package:bevert/core/services/db/shared_preferences_helper.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeInitial(themeMode: ThemeMode.system)) {
    // 앱 실행 시 SharedPreferences에서 테마 값 로드
    on<ThemeInitialEvent>((event, emit) async {
      final themeMode = await SharedPreferencesHelper.getThemeMode();
      emit(ThemeInitial(themeMode: themeMode));
    });

    on<ThemeChanged>((event, emit) {
      emit(ThemeInitial(themeMode: event.themeMode));
      SharedPreferencesHelper.saveThemeMode(event.themeMode);
    });
  }
}
