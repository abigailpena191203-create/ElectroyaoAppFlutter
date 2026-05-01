import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = true; // Started with dark mode by default based on design

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  // Tema Claro (Basado en 'bg-slate-50 text-slate-900')
  static final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC), // slate-50
    primaryColor: const Color(0xFF2563EB), // blue-600
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF3B82F6), // blue-500
      surface: Colors.white,
    ),
    cardColor: Colors.white,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0F172A)), // slate-900
      bodyMedium: TextStyle(color: Color(0xFF1E293B)), // slate-800
    ),
  );

  // Tema Oscuro (Ajustado a azul profundo en lugar de grises)
  static final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF070B19), // Fondo azul muy profundo
    primaryColor: const Color(0xFF1E3A8A), // Acento azul
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF3B82F6), // blue-500
      secondary: Color(0xFF60A5FA), // blue-400
      surface: Color(0xFF0D142B), // Superficie/tarjeta azul noche
    ),
    cardColor: const Color(0xFF0D142B),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF1F5F9)), // slate-100
      bodyMedium: TextStyle(color: Color(0xFFE2E8F0)), // slate-200
    ),
    dividerColor: const Color(0xFF1C284A), // Líneas divisorias con matiz azulado
  );
}
