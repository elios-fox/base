import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState extends Equatable {
  const ThemeState({this.themeMode = ThemeMode.system});
  final ThemeMode themeMode;

  @override
  List<Object?> get props => [themeMode];
}

sealed class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

final class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}

final class ThemeLoaded extends ThemeEvent {
  const ThemeLoaded();
}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState()) {
    on<ThemeLoaded>(_onLoaded);
    on<ThemeToggled>(_onToggled);
  }

  static const _key = 'theme_mode';

  Future<void> _onLoaded(ThemeLoaded event, Emitter<ThemeState> emit) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    if (value == 'dark') {
      emit(const ThemeState(themeMode: ThemeMode.dark));
    } else if (value == 'light') {
      emit(const ThemeState(themeMode: ThemeMode.light));
    }
  }

  Future<void> _onToggled(ThemeToggled event, Emitter<ThemeState> emit) async {
    final newMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit(ThemeState(themeMode: newMode));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, newMode == ThemeMode.dark ? 'dark' : 'light');
  }
}
