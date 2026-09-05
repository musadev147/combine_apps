import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassBackgroundScaffold(
      body: Center(
        child: Text("Search Screen", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
      ),
    );
  }
}
