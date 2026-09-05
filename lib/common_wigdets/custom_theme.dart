import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bd_shope_combined/helpers/di.dart';

class CustomThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get currentTheme => _isDarkMode ? dark : light;

  CustomThemeProvider() {
    _loadThemeFromPrefs();
  }

  void toggleTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();
      await _saveThemeToPrefs();
    }
  }

  Future<void> _loadThemeFromPrefs() async {
    _isDarkMode = appData.read('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    await appData.write('isDarkMode', _isDarkMode);
  }

  // 🔹 Define light theme
  final ThemeData light = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF0461D3),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.black),
    ),
  );

  // 🔹 Define dark theme
  final ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF0461D3),
    scaffoldBackgroundColor: const Color(0xff0E0E0E),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xff0E0E0E),
      iconTheme: IconThemeData(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black),
    ),
  );
}



