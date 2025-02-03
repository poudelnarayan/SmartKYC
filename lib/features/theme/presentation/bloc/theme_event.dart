import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ChangeTheme extends ThemeEvent {
  final ThemeMode themeMode;
  
  const ChangeTheme(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}