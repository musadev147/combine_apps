import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:bd_shope_combined/networks/dio/dio.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/route/app_pages.dart';
import 'package:fluttertoast/fluttertoast.dart';

final FlutterLocalNotificationsPlugin _bgLocalNotifications = FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Background Message Received: ${message.messageId}");
  await Firebase.initializeApp();

  final data = message.data;
  final title = data['title'] ?? message.notification?.title ?? 'New Notification';
  final body = data['body'] ?? message.notification?.body ?? '';
  
  if (title.isNotEmpty || body.isNotEmpty) {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    _bgLocalNotifications.initialize(initSettings);
    
    _bgLocalNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'damadami_high_priority',
          'High Importance Notifications',
          channelDescription: 'This channel is used for important notifications like new invoices.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: data['invoice_id'] ?? data['id'] ?? '',
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  NotificationService._internal();
  static NotificationService get instance => _instance;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    try {
      // Request permission
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Request notification permission on Android explicitly using permission_handler
      if (defaultTargetPlatform == TargetPlatform.android) {
        await Permission.notification.request();
      }

      // Initialize Local Notifications for Heads-Up Banners
      await initLocalNotifications();

      // Setup FCM Token registration
      await registerToken();

      // Listen to token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        log("FCM Token Refreshed: $newToken");
        _sendTokenToServer(newToken);
      });

      // Handle foreground notifications
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        log("Foreground FCM Message Received: ${message.messageId}");
        final String title = message.notification?.title ?? message.data['title']?.toString() ?? 'New Notification';
        final String body = message.notification?.body ?? message.data['body']?.toString() ?? '';
        
        // Trigger heads-up notification banner
        _localNotifications.show(
          message.hashCode,
          title,
          body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'damadami_high_priority',
              'High Importance Notifications',
              channelDescription: 'This channel is used for important notifications like new invoices.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: message.data['invoice_id'] ?? message.data['id'] ?? '',
        );

        Get.snackbar(
          title,
          body,
          colorText: Colors.white,
          backgroundColor: Color(0xFF53A4CA).withOpacity(0.9),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      });

      // Handle when app is opened from notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        log("FCM Message opened app: ${message.messageId}");
        _handleNotificationNavigation(message.data);
      });

    } catch (e) {
      log("NotificationService initialization failed: $e");
    }
  }

  Future<void> initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Notification clicked: ${response.payload}");
        if (response.payload != null && response.payload!.isNotEmpty) {
          Get.toNamed<dynamic>(
            Routes.INVOICE_DETAILS,
            arguments: response.payload,
          );
        }
      },
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'damadami_high_priority',
      'High Importance Notifications',
      description: 'This channel is used for important notifications like new invoices.',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    final action = data['action'] ?? data['type'];
    if (action == 'new_message') {
      final channelId = data['channel_id'];
      final senderName = data['sender_name'] ?? 'Chat';
      Get.toNamed<dynamic>(Routes.CHAT, arguments: {
        'channelId': channelId,
        'peerName': senderName,
      });
    } else if (action == 'new_invoice') {
      final invoiceId = data['invoice_id'];
      if (invoiceId != null) {
        Get.toNamed<dynamic>(Routes.INVOICE_DETAILS, arguments: invoiceId);
      }
    }
  }

  Future<void> showLocalNotification({required String title, required String body, String? payload}) async {
    try {
      await _localNotifications.show(
        DateTime.now().millisecond,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'damadami_high_priority',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications like new invoices.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      log("Error showing local notification: $e");
    }
  }

  Future<void> registerToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        log("FCM Token: $token");
        await _sendTokenToServer(token);
      }
    } catch (e) {
      log("Error fetching FCM token: $e");
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    final bool isLoggedIn = appData.read(kKeyIsLoggedIn) ?? false;
    final String userToken = appData.read(kKeyAccessToken) ?? '';
    
    if (!isLoggedIn || userToken.isEmpty) {
      log("NotificationService: User is not logged in. Skipping FCM token registration.");
      return;
    }

    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      String deviceId = 'unknown_android';
      String deviceName = 'Unknown Device';

      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id; 
        deviceName = "${androidInfo.brand} ${androidInfo.model}";
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'unknown_ios';
        deviceName = iosInfo.name;
      }

      final data = {
        "name": deviceName,
        "registration_id": token,
        "device_id": deviceId,
        "active": true,
        "type": defaultTargetPlatform == TargetPlatform.iOS ? "ios" : "android",
      };
      
      log("""
=====================================================
[FCM REGISTRATION REQUEST - BUYER APP]
URL: ${Endpoints.registerFcmToken()}
Payload: $data
=====================================================""");

      final response = await postHttp(Endpoints.registerFcmToken(), data);
      
      log("""
=====================================================
[FCM REGISTRATION RESPONSE - BUYER APP]
Status: ${response.statusCode}
Response Body: ${response.data}
=====================================================""");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Fluttertoast.showToast(
          msg: "FCM Token Registered Successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: "FCM Token Registration Failed: ${response.statusCode}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      log("""
=====================================================
[FCM REGISTRATION ERROR - BUYER APP]
Error Details: $e
=====================================================""");
      Fluttertoast.showToast(
        msg: "FCM Token Registration Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
}
