import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../helpers/di.dart';

class ThemeController extends GetxController {
  final _box = locator.get<GetStorage>();
  final _key = 'isDarkMode';

  // Get theme mode from storage, defaults to false (light mode)
  RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _box.read<bool>(_key) ?? false;
  }

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _box.write(_key, isDarkMode.value);
    Get.changeThemeMode(themeMode);
  }

  // Helper colors that respond to theme mode dynamically
  Color get textColor => isDarkMode.value ? Colors.white : Colors.black87;
  Color get textSecondaryColor => isDarkMode.value ? Colors.white70 : Colors.black54;
  Color get cardBackground => isDarkMode.value ? const Color(0xFF1A1833) : Colors.white;
  Color get inputBackground => isDarkMode.value ? Colors.white.withOpacity(0.05) : Colors.white;
  Color get inputBorderColor => isDarkMode.value ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.08);
  Color get inputTextColor => isDarkMode.value ? Colors.white : Colors.black87;
  Color get inputHintColor => isDarkMode.value ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.45);
  Color get iconColor => isDarkMode.value ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6);
  Color get dividerColor => isDarkMode.value ? Colors.white12 : Colors.black12;
}
