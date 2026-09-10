import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/services/web_socket_service.dart';
import 'package:bd_shope_combined/services/agora_service.dart';
import 'package:bd_shope_combined/controllers/connection_controller.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/data/call_controller.dart';

class TokenRefreshService extends GetxService {
  Timer? _timer;
  
  static TokenRefreshService get instance => Get.find<TokenRefreshService>();

  void startTimer() {
    stopTimer();
    // Refresh immediately when app starts or service is initialized
    refreshToken();
    
    // Then run it every 5 minutes
    _timer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await refreshToken();
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refreshToken() async {
    final isLoggedIn = appData.read(kKeyIsLoggedIn) ?? false;
    final refreshTokenStr = appData.read<String>('refresh_token') ?? '';

    // Only refresh if logged in and we have a refresh token
    if (!isLoggedIn || refreshTokenStr.isEmpty) {
      return;
    }

    try {
      if (kDebugMode) {
        print("Periodic Token Refresh Started...");
      }
      final refreshDio = Dio(BaseOptions(
        baseUrl: url!,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ));

      final response = await refreshDio.post(
        'auth/getRefreshToken',
        data: {
          "refresh": refreshTokenStr,
          "refresh_token": refreshTokenStr,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final newAccessToken = (data['access_token'] ?? data['access'] ?? data['token'])?.toString() ?? '';
        final newRefreshToken = (data['refresh_token'] ?? data['refresh'])?.toString() ?? '';
        
        if (newAccessToken.isNotEmpty) {
          await appData.write(kKeyAccessToken, newAccessToken);
          if (newRefreshToken.isNotEmpty) {
            await appData.write('refresh_token', newRefreshToken);
          }
          
          DioSingleton.instance.update(newAccessToken);

          if (kDebugMode) {
            print("Periodic Token Refresh Successful!");
          }
        } else {
          throw Exception("No access token in response");
        }
      } else {
        throw Exception("Failed to refresh token with status: ${response.statusCode}");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Periodic Token Refresh Failed: $e");
      }
      // If refresh fails, log out the user
      await forceLogout();
    }
  }

  Future<void> forceLogout() async {
    stopTimer();
    
    // Check if seller
    final role = appData.read('userRole')?.toString().toLowerCase() ?? '';
    final isSeller = role == 'seller';

    await appData.write(kKeyIsLoggedIn, false);
    await appData.remove(kKeyAccessToken);
    await appData.remove(kKeyUserID);
    await appData.remove(kKeyEmail);
    DioSingleton.instance.update("");

    if (Get.isRegistered<WebSocketService>()) {
      Get.find<WebSocketService>().disconnect();
      Get.delete<WebSocketService>();
    }
    if (Get.isRegistered<AgoraService>()) {
      Get.delete<AgoraService>();
    }
    if (Get.isRegistered<ConnectionController>()) {
      Get.delete<ConnectionController>();
    }
    if (Get.isRegistered<CallController>()) {
      Get.find<CallController>().disconnectSocket();
      Get.delete<CallController>();
    }

    if (isSeller) {
      Get.offAllNamed(Routes.SELLER_LOGIN);
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}
