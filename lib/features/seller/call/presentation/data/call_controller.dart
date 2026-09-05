import 'dart:developer';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/networks/api_acess.dart';
import 'package:bd_shope_combined/features/seller/home/presentation/data/short_note_api.dart';
import 'call_websocket_service.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/incoming_call_screen.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/call_screen.dart';
import 'agora_service.dart';
import 'package:bd_shope_combined/features/seller/call/presentation/floating_call_bubble.dart';
import 'notification_service.dart';


enum CallState { idle, incoming, accepted, rejected, connected, ended }

class CallController extends GetxController {
  final _wsService = CallWebSocketService();
  bool _ignoreCallKitEvents = false;
  
  // Observable Call details
  var callState = CallState.idle.obs;
  var currentCallId = ''.obs;
  var currentCustomerId = ''.obs;
  var currentProduct = ''.obs;
  var currentCustomerImage = ''.obs;
  var isCallScreenVisible = false.obs;

  // Floating overlay and Call Timer variables
  var callTimerSeconds = 0.obs;
  var callTimerString = '00:00'.obs;
  Timer? _callTimer;
  OverlayEntry? _overlayEntry;

  @override
  void onInit() {
    super.onInit();
    _setupWebSocketCallbacks();
    _setupCallKitListener();
    autoConnectIfLoggedIn();

    // Watch calling state changes to show/hide overlay bubble automatically
    everAll([callState, isCallScreenVisible], (_) {
      _updateFloatingBubbleState();
    });
  }

  void _setupWebSocketCallbacks() {
    _wsService.onConnected = () {
      log('CallController: WebSocket connection established.');
    };

    _wsService.onDisconnected = (err) {
      log('CallController: WebSocket disconnected. Error: $err');
      _stopRingtone();
    };

    _wsService.onMessageReceived = (message) {
      _handleIncomingMessage(message);
    };
  }

  void _setupCallKitListener() {
    FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null || _ignoreCallKitEvents) return;
      switch (event.event) {
        case Event.actionCallAccept:
          log('CallController: CallKit Accepted Event triggered.');
          acceptCall(fromCallKit: true);
          _navigateToCallScreen();
          break;
        case Event.actionCallDecline:
          log('CallController: CallKit Declined Event triggered.');
          rejectCall();
          break;
        case Event.actionCallEnded:
          log('CallController: CallKit Ended Event triggered.');
          endCall();
          break;
        case Event.actionCallTimeout:
          log('CallController: CallKit Timeout Event triggered.');
          _cleanupAndGoBack();
          break;
        default:
          break;
      }
    });
  }

  Future<void> _showIncomingCallKit(
      String callId, String customerId, String product, String customerImage) async {
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
    await FlutterCallkitIncoming.showCallkitIncoming(params);
  }

  void autoConnectIfLoggedIn() {
    final token = appData.read(kKeyAccessToken)?.toString() ?? '';
    if (token.isNotEmpty) {
      connectSocket(token);
    } else {
      log("CallController: User not logged in yet. WebSocket connection deferred.");
    }
  }

  void connectSocket(String token) {
    _wsService.connect(token);
  }

  void disconnectSocket() {
    _wsService.disconnect();
    _stopRingtone();
    callState.value = CallState.idle;
  }

  void _playRingtone() {
    try {
      FlutterRingtonePlayer().playRingtone(asAlarm: true);
      log('CallController: Started playing ringtone.');
    } catch (e) {
      log('CallController: Error playing ringtone: $e');
    }
  }

  void _stopRingtone() {
    try {
      FlutterRingtonePlayer().stop();
      log('CallController: Stopped playing ringtone.');
    } catch (e) {
      log('CallController: Error stopping ringtone: $e');
    }
  }

  void _handleIncomingMessage(Map<String, dynamic> message) {
    final type = message['type'] ?? message['action'];
    log('CallController: Received WebSocket event type: $type');

    switch (type) {
      case 'incoming_call':
        final callId = message['session_id']?.toString() ?? message['call_id']?.toString() ?? '';
        final customerId = message['buyer_name']?.toString() ?? message['customer_id']?.toString() ?? '';
        final product = message['tag_name']?.toString() ?? message['product']?.toString() ?? '';
        final customerImage = message['buyer_image']?.toString() ?? message['customer_image']?.toString() ?? '';

        if (product.startsWith('[SHORT_NOTE]')) {
           final title = "New Short Note Received";
           final body = product.replaceAll('[SHORT_NOTE]', '').trim();
           NotificationService.instance.showLocalNotification(title, body);
           try { getNotificationsRx.fetchNotifications(); } catch (_) {}
           return; // Stop processing as a call
        }

        if (callState.value == CallState.idle) {
          currentCallId.value = callId;
          currentCustomerId.value = customerId;
          currentProduct.value = product;
          currentCustomerImage.value = customerImage;
          callState.value = CallState.incoming;

          isCallScreenVisible.value = true;

          // Trigger native callkit incoming UI (will show even if app is minimized)
          _showIncomingCallKit(callId, customerId, product, customerImage);

          // Open the incoming call screen overlay/page inside the app
          Get.to(() => const IncomingCallScreen(), routeName: 'IncomingCallScreen');
        }
        break;

      case 'accept_call':
        final callId = message['session_id']?.toString() ?? message['call_id']?.toString() ?? '';
        final acceptedBy = message['seller_id']?.toString() ?? '';
        final currentSellerId = appData.read(kKeyUserID)?.toString() ?? '';

        if (callId == currentCallId.value || currentCallId.value.isEmpty || callId.isEmpty) {
          _stopRingtone();
          if (acceptedBy == currentSellerId && currentSellerId.isNotEmpty) {
            // We successfully accepted the call first
            callState.value = CallState.connected;
            startCallTimer();
            // Transition to active call session screen
            _navigateToCallScreen();
          } else {
            // Other seller accepted the call first, stop ringing
            callState.value = CallState.ended;
            _cleanupAndGoBack();
          }
        }
        break;

      case 'call_started':
        final token = message['token'] as String?;
        final channelName = message['channel_name'] as String?;
        final uid = message['uid'] as int? ?? 0;
        final acceptedBy = message['seller_id']?.toString() ?? message['vendor_id']?.toString() ?? '';
        final currentSellerId = appData.read(kKeyUserID)?.toString() ?? '';
        
        _stopRingtone();
        if (callState.value == CallState.accepted || callState.value == CallState.incoming) {
          if (acceptedBy.isNotEmpty && acceptedBy != currentSellerId) {
            // Someone else accepted the call, so we should decline/cleanup
            callState.value = CallState.ended;
            _cleanupAndGoBack();
          } else {
            callState.value = CallState.connected;
            startCallTimer();
            _navigateToCallScreen();

            if (channelName != null && channelName.isNotEmpty) {
              AgoraService.instance.joinChannel(
                channelId: channelName,
                token: token,
                uid: uid,
              );
            }
          }
        }
        break;

      case 'call_declined':
        final callId = message['session_id']?.toString() ?? message['call_id']?.toString() ?? '';
        if (callId == currentCallId.value || currentCallId.value.isEmpty || callId.isEmpty) {
          _stopRingtone();
          callState.value = CallState.rejected;
          _cleanupAndGoBack();
        }
        break;

      case 'call_rejected_by_buyer':
        final callId = message['session_id']?.toString() ?? message['call_id']?.toString() ?? '';
        if (callId == currentCallId.value || currentCallId.value.isEmpty || callId.isEmpty) {
          _stopRingtone();
          callState.value = CallState.ended;
          _cleanupAndGoBack();
        }
        break;

      case 'call_missed':
      case 'call_cancelled':
      case 'cancel_call':
        final callId = message['session_id']?.toString() ?? message['call_id']?.toString() ?? '';
        if (callId == currentCallId.value || currentCallId.value.isEmpty || callId.isEmpty) {
          _stopRingtone();
          callState.value = CallState.ended;
          _cleanupAndGoBack();
        }
        break;
    }
  }

  void acceptCall({bool fromCallKit = false}) {
    _stopRingtone();
    final payload = {
      'action': 'accept_call',
      'session_id': currentCallId.value,
    };
    _wsService.send(payload);
    callState.value = CallState.accepted;

    if (!fromCallKit) {
      // Dismiss CallKit incoming notification UI programmatically only if accepted from in-app
      _ignoreCallKitEvents = true;
      FlutterCallkitIncoming.endAllCalls();
      Future.delayed(const Duration(milliseconds: 500), () {
        _ignoreCallKitEvents = false;
      });
    }
  }

  void _navigateToCallScreen() {
    final currentRoute = Get.currentRoute;
    if (currentRoute == 'IncomingCallScreen' || currentRoute == '/IncomingCallScreen') {
      Get.off(() => const CallScreen(), routeName: 'CallScreen');
    } else {
      if (currentRoute != 'CallScreen' && currentRoute != '/CallScreen') {
        Get.to(() => const CallScreen(), routeName: 'CallScreen');
      }
    }
  }

  void rejectCall() {
    _stopRingtone();
    final payload = {
      'action': 'decline_call',
      'session_id': currentCallId.value,
    };
    _wsService.send(payload);
    callState.value = CallState.rejected;
    _cleanupAndGoBack();
  }

  void startCall(String tagId) {
    _stopRingtone();
    final payload = {
      'action': 'initiate_call',
      'tag_id': tagId,
    };
    _wsService.send(payload);
    callState.value = CallState.accepted; // set state so call_started event is accepted
  }

  void endCall() {
    _stopRingtone();
    final payload = {
      'action': 'cancel_call',
      'session_id': currentCallId.value,
    };
    _wsService.send(payload);
    callState.value = CallState.ended;
    _cleanupAndGoBack();
  }

  void _cleanupAndGoBack() {
    _stopRingtone();
    stopCallTimer();
    AgoraService.instance.leaveChannel();
    
    // Clean up CallKit UI
    FlutterCallkitIncoming.endAllCalls();

    currentCallId.value = '';
    currentCustomerId.value = '';
    currentProduct.value = '';
    currentCustomerImage.value = '';
    callState.value = CallState.idle;

    // Pop the incoming call screen or active call screen if currently on screen
    if (isCallScreenVisible.value || Get.isDialogOpen == true) {
      isCallScreenVisible.value = false;
      Get.back();
    }
  }

  String? _lastShortNoteId;
  Timer? _shortNotePollTimer;

  void startCallTimer() {
    callTimerSeconds.value = 0;
    callTimerString.value = '00:00';
    _callTimer?.cancel();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callTimerSeconds.value++;
      final minutes = (callTimerSeconds.value ~/ 60).toString().padLeft(2, '0');
      final seconds = (callTimerSeconds.value % 60).toString().padLeft(2, '0');
      callTimerString.value = '$minutes:$seconds';
    });
    
    // Start polling for new short notes during call
    _lastShortNoteId = null;
    ShortNoteApi.instance.fetchShortNotes().then((list) {
      if (list.isNotEmpty) {
        _lastShortNoteId = list.first.id;
      } else {
        _lastShortNoteId = "none";
      }
    }).catchError((_) { _lastShortNoteId = "none"; });
    
    _shortNotePollTimer?.cancel();
    _shortNotePollTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      if (_lastShortNoteId == null) return;
      try {
        final list = await ShortNoteApi.instance.fetchShortNotes();
        if (list.isNotEmpty) {
          final latest = list.first;
          if (latest.id != null && latest.id != _lastShortNoteId) {
            _lastShortNoteId = latest.id;
            final title = "New Short Note Received";
            final body = "Invoice for '${latest.productName}' received.";
            NotificationService.instance.showLocalNotification(title, body);
          }
        }
      } catch (e) {
        log('CallController: Error polling short notes: $e');
      }
    });
  }

  void stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
    callTimerSeconds.value = 0;
    callTimerString.value = '00:00';
    
    _shortNotePollTimer?.cancel();
    _shortNotePollTimer = null;
  }

  void _updateFloatingBubbleState() {
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    if (callState.value == CallState.connected && !isCallScreenVisible.value) {
      if (_overlayEntry == null) {
        _overlayEntry = OverlayEntry(
          builder: (context) => FloatingCallBubble(
            onTap: () {
              _navigateToCallScreen();
            },
          ),
        );
        Overlay.of(context).insert(_overlayEntry!);
      }
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  void _initializeAgoraOrZego() {
    log('Agora/Zego Integration: Preparing RTC audio engines for Channel ID: ${currentCallId.value}');
    AgoraService.instance.joinChannel(channelId: currentCallId.value);
  }

  @override
  void onClose() {
    stopCallTimer();
    _overlayEntry?.remove();
    _overlayEntry = null;
    FlutterCallkitIncoming.endAllCalls();
    disconnectSocket();
    super.onClose();
  }
}
