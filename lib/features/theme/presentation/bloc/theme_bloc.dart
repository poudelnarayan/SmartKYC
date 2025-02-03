import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme';

  ThemeBloc() : super(ThemeState.initial()) {
    on<ChangeTheme>(_onChangeTheme);
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);
      if (savedTheme != null) {
        add(ChangeTheme(_themeFromString(savedTheme)));
      }
    } catch (e) {
      print('Error loading saved theme: $e');
    }
  }

  Future<void> _onChangeTheme(
      ChangeTheme event, Emitter<ThemeState> emit) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, event.themeMode.toString());
      emit(state.copyWith(themeMode: event.themeMode));
    } catch (e) {
      print('Error changing theme: $e');
    }
  }

  ThemeMode _themeFromString(String themeString) {
    return ThemeMode.values.firstWhere(
      (e) => e.toString() == themeString,
      orElse: () => ThemeMode.light,
    );
  }
}
