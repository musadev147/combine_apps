import 'package:bd_shope_combined/controllers/theme_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// A minimal placeholder implementation for the missing ChatScreen.
/// This satisfies the GetPage route expecting `const ChatScreen()`.
class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        backgroundColor: Colors.blueAccent,
      ),
      body: const Center(
        child: Text(
          'Chat screen placeholder',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
