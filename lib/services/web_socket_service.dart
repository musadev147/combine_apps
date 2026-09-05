import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:get/get.dart';
import 'package:bd_shope_combined/helpers/di.dart';
import 'package:bd_shope_combined/constants/app_constants.dart';
import 'package:bd_shope_combined/networks/endpoints.dart';

class WebSocketService extends GetxService {
  static WebSocketService get to => Get.find();
  
  WebSocketChannel? _channel;
  bool _isConnected = false;
  bool _isConnecting = false;
  bool get isConnected => _isConnected;
  
  // Callback when a message is received
  void Function(Map<String, dynamic>)? onMessageReceived;
  // Callback when connection status changes
  void Function(bool)? onConnectionStatusChanged;

  // Track the attempt variations
  int _connectionAttempt = 0;
  
  // Timer for reconnection to prevent multiple overlapping schedules
  Timer? _reconnectTimer;


  /// Connects to the WebSocket server using the token stored in GetStorage
  void connect() {
    if (_isConnected || _isConnecting) {
      log('WebSocket connection attempt skipped: already connected or connecting.');
      return;
    }

    final token = appData.read<String>(kKeyAccessToken);
    if (token == null || token.isEmpty) {
      log('WebSocket connection aborted: Token is null or empty');
      return;
    }

    _isConnecting = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    final baseUrl = url ?? 'http://127.0.0.1:8001';
    final uri = Uri.parse(baseUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final portStr = uri.hasPort ? ':${uri.port}' : '';

    // Define connection variations to try
    final paths = ['/ws/calls/', '/ws/calls'];
    final tokenPrefixes = ['', 'Bearer '];

    final path = paths[(_connectionAttempt ~/ 2) % paths.length];
    final prefix = tokenPrefixes[_connectionAttempt % tokenPrefixes.length];
    final formattedToken = Uri.encodeComponent('$prefix$token');

    final wsUrl = '$wsScheme://${uri.host}$portStr$path?token=$formattedToken';
    log('Connecting to WebSocket (Attempt #$_connectionAttempt): $wsUrl');

    try {
      _channel = IOWebSocketChannel.connect(
        Uri.parse(wsUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      _channel!.ready.then((_) {
        log('WebSocket Connected Successfully (Attempt #$_connectionAttempt)');
        _isConnected = true;
        _isConnecting = false;
        _connectionAttempt = 0; // Reset attempt index on success
        onConnectionStatusChanged?.call(true);
      }).catchError((Object error) {
        log('WebSocket Handshake/Connection Error in ready (Attempt #$_connectionAttempt): $error');
        _isConnecting = false;
        _handleDisconnection();
      });

      _channel!.stream.listen(
        (Object? message) {
          log('WebSocket Message Received: $message');
          try {
            if (message is String) {
              final Map<String, dynamic> data = jsonDecode(message) as Map<String, dynamic>;
              onMessageReceived?.call(data);
            }
          } catch (e) {
            log('Error decoding WebSocket message: $e');
          }
        },
        onError: (Object error) {
          log('WebSocket Error stream (Attempt #$_connectionAttempt): $error');
          _isConnecting = false;
          _handleDisconnection();
        },
        onDone: () {
          log('WebSocket Stream Closed (Attempt #$_connectionAttempt)');
          _isConnecting = false;
          _handleDisconnection();
        },
      );
    } catch (e) {
      log('Failed to connect to WebSocket: $e');
      _isConnecting = false;
      _handleDisconnection();
    }
  }

  /// Sends a call request to matching sellers
  void sendCallRequest({required String product, required List<String> sellerIds}) {
    if (!_isConnected || _channel == null) {
      log('Cannot send call request: WebSocket not connected');
      // Attempt reconnection
      connect();
      return;
    }

    final payload = {
      'type': 'call_request',
      'product': product,
      'seller_ids': sellerIds,
      'buyer_image': appData.read<String>('avatar_path') ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200',
    };

    log('WebSocket Sending Call Request: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  /// Initiates a call with a specific tag ID
  void initiateCall({required String tagId, required String callType}) {
    if (!_isConnected || _channel == null) {
      log('Cannot initiate call: WebSocket not connected');
      connect();
      return;
    }

    final payload = {
      'action': 'initiate_call',
      'tag_id': tagId,
      'call_type': callType,
      'buyer_image': appData.read<String>('avatar_path') ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=200',
    };

    log('WebSocket Sending Initiate Call: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  /// Sends a message to reject or end call
  void endCall() {
    if (!_isConnected || _channel == null) return;
    
    final payload = {
      'type': 'end_call',
    };
    log('WebSocket Sending End Call: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  void acceptCall(String sessionId) {
    if (!_isConnected || _channel == null) return;
    final payload = {
      'action': 'accept_call',
      'session_id': sessionId,
    };
    log('WebSocket Sending Accept Call: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  void declineCall(String sessionId) {
    if (!_isConnected || _channel == null) return;
    final payload = {
      'action': 'decline_call',
      'session_id': sessionId,
    };
    log('WebSocket Sending Decline Call: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  void rejectCall(String sessionId, {String? vendorId}) {
    if (!_isConnected || _channel == null) return;
    final payload = {
      'action': 'reject_call',
      'session_id': sessionId,
      if (vendorId != null) 'vendor_id': vendorId,
    };
    log('WebSocket Sending Reject Call: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  void cancelCall(String sessionId) {
    if (!_isConnected || _channel == null) return;
    final payload = {
      'action': 'cancel_call',
      'session_id': sessionId,
    };
    log('WebSocket Sending Cancel Call: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  void _handleDisconnection() {
    final wasConnected = _isConnected;
    _isConnected = false;
    _isConnecting = false;
    _channel = null;

    if (wasConnected) {
      onConnectionStatusChanged?.call(false);
    }
    
    // Cycle to next connection variation
    _connectionAttempt++;
    
    // Cancel any existing reconnect timer first to avoid multiple concurrent connection loops
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      final token = appData.read<String>(kKeyAccessToken);
      if (token != null && token.isNotEmpty && !_isConnected && !_isConnecting) {
        log('Attempting auto-reconnection...');
        connect();
      }
    });
  }

  void sendCustomEvent(Map<String, dynamic> payload) {
    if (!_isConnected || _channel == null) return;
    log('WebSocket Sending Custom Event: $payload');
    _channel!.sink.add(jsonEncode(payload));
  }

  /// Closes the WebSocket connection
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnecting = false;
    if (_channel != null) {
      _channel!.sink.close();
      _handleDisconnection();
    } else {
      _isConnected = false;
    }
  }
}
