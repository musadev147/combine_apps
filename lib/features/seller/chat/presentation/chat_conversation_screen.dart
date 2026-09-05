import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:bd_shope_combined/common_widgets/glass_background_scaffold.dart';

class ChatConversationScreen extends StatelessWidget {
  const ChatConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassBackgroundScaffold(
      body: Center(
        child: Text("Chat Conversation Screen", style: TextStyle(color: Get.isRegistered<ThemeController>() ? Get.find<ThemeController>().textColor : Colors.black)),
      ),
    );
  }
}
