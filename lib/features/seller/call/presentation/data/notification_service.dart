import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
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
  _handleNotificationPayload(message.data);
}

void _handleNotificationPayload(Map<String, dynamic> data) {
  log("FCM Payload data: $data");
  final action = data['action'] ?? data['type'];
  if (action == 'incoming_call') {
    final callId = data['session_id']?.toString() ?? data['call_id']?.toString() ?? 'call_${DateTime.now().millisecondsSinceEpoch}';
    final customerId = data['buyer_name']?.toString() ?? data['customer_id']?.toString() ?? 'Customer';
    final product = data['tag_name']?.toString() ?? data['product']?.toString() ?? '';
    final customerImage = data['buyer_image']?.toString() ?? data['customer_image']?.toString() ?? '';

    // Show native call kit incoming UI
    final params = CallKitParams(
      id: callId,
      nameCaller: customerId,
      appName: 'Damadami Live Hub',
      avatar: customerImage.isNotEmpty ? customerImage : null,
      handle: 'Product Inquiry: #$product',
      type: 1, // 1 for video, 0 for audio
      duration: 30000,
      textAccept: 'Accept',
      textDecline: 'Decline',
      missedCallNotification: const NotificationParams(
        showNotification: true,
        subtitle: 'You have a missed product inquiry call.',
      ),
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#097A3E',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: 'Incoming Call',
      ),
      ios: const IOSParams(
        iconName: 'AppIcon',
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'default',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: true,
        supportsUngrouping: true,
        ringtonePath: 'system_ringtone_default',
      ),
    );
    FlutterCallkitIncoming.showCallkitIncoming(params);
  } else if (action == 'cancel_call' || action == 'call_cancelled' || action == 'call_missed') {
    FlutterCallkitIncoming.endAllCalls();
  } else {
    // Show Local Notification for non-call actions (e.g. new_invoice, short_notes) in the background/foreground
    final title = data['title'] ?? 'New Notification';
    final body = data['body'] ?? '';
    if (title.isNotEmpty || body.isNotEmpty) {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      _bgLocalNotifications.initialize(initSettings);
      
      _bgLocalNotifications.show(
        data.hashCode,
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

      // Initialize Flutter Local Notifications for Heads-Up Banner Display
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
        final title = message.notification?.title ?? message.data['title'] ?? 'New Notification';
        final body = message.notification?.body ?? message.data['body'] ?? '';
        final action = message.data['action'] ?? message.data['type'];
        
        if (action != 'incoming_call' && action != 'cancel_call' && action != 'call_cancelled' && action != 'call_missed') {
          // Show real system heads-up notification in foreground using Flutter Local Notifications
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
        }
        _handleNotificationPayload(message.data);
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
          Get.toNamed(
            '/payment-invoice', // Routes.PAYMENT_INVOICE
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
    } else if (action == 'invoice_paid' || action == 'short_notes' || action == 'new_invoice' || action == 'create_invoice') {
      Get.toNamed<dynamic>(Routes.HOME, arguments: {'tab': 'short_notes'});
    }
  }

  void showLocalNotification(String title, String body, {String payload = ''}) {
    final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    _localNotifications.show(
      id,
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
    
    Get.snackbar(
      title,
      body,
      colorText: Colors.white,
      backgroundColor: const Color(0xFF53A4CA).withOpacity(0.9),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
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
    final userToken = appData.read(kKeyAccessToken)?.toString() ?? '';
    if (userToken.isEmpty) {
      log("NotificationService: User token not present. FCM registration deferred until login.");
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
[FCM REGISTRATION REQUEST - SELLER APP]
URL: ${Endpoints.registerFcmToken()}
Payload: $data
=====================================================""");

      final response = await postHttp(Endpoints.registerFcmToken(), data);
      
      log("""
=====================================================
[FCM REGISTRATION RESPONSE - SELLER APP]
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
[FCM REGISTRATION ERROR - SELLER APP]
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
