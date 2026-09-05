import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:bd_shope_combined/networks/endpoints.dart' as api;

class CallWebSocketService {
  WebSocket? _webSocket;
  
  // Callbacks
  Function(Map<String, dynamic>)? onMessageReceived;
  Function()? onConnected;
  Function(dynamic)? onDisconnected;

  bool _isConnecting = false;
  bool _shouldReconnect = true;
  String? _cachedToken;
  Timer? _reconnectTimer;
  int _connectionAttempt = 0;

  bool get isConnected => _webSocket != null && _webSocket!.readyState == WebSocket.open;

  Future<void> connect(String token) async {
    if (_isConnecting || isConnected) return;
    
    _cachedToken = token;
    _shouldReconnect = true;
    _isConnecting = true;
    
    final baseUrl = api.url ?? 'http://127.0.0.1:8001';
    final uri = Uri.parse(baseUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final portStr = uri.hasPort ? ':${uri.port}' : '';
    
    // Define connection variations to try
    final paths = ['/ws/calls/', '/ws/calls'];
    final tokenPrefixes = ['', 'Bearer '];

    final path = paths[(_connectionAttempt ~/ 2) % paths.length];
    final prefix = tokenPrefixes[_connectionAttempt % tokenPrefixes.length];
    final formattedToken = Uri.encodeComponent('$prefix$token');

    final connectionUrl = '$wsScheme://${uri.host}$portStr$path?token=$formattedToken';
    log('Connecting to WebSocket (Attempt #$_connectionAttempt): $connectionUrl');

    try {
      _webSocket = await WebSocket.connect(connectionUrl).timeout(const Duration(seconds: 10));
      _isConnecting = false;
      _connectionAttempt = 0; // Reset attempt index on success
      log('WebSocket connected successfully.');
      onConnected?.call();

      _webSocket!.listen(
        (data) {
          log('WebSocket raw message: $data');
          print('!!! Raw WebSocket Message Received !!!: $data');
          if (data is String) {
            try {
              final Map<String, dynamic> decoded = jsonDecode(data);
              onMessageReceived?.call(decoded);
            } catch (e) {
              log('Error decoding WebSocket JSON data: $e');
            }
          }
        },
        onError: (err) {
          log('WebSocket error occurred: $err');
          _handleDisconnect(err);
        },
        onDone: () {
          log('WebSocket connection closed by server.');
          _handleDisconnect(null);
        },
        cancelOnError: true,
      );
    } catch (e) {
      _isConnecting = false;
      log('WebSocket connection error: $e');
      _handleDisconnect(e);
    }
  }

  void disconnect() {
    log('Disconnecting WebSocket explicitly.');
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _webSocket?.close();
    _webSocket = null;
  }

  void send(Map<String, dynamic> message) {
    if (isConnected) {
      final jsonStr = jsonEncode(message);
      log('WebSocket sending: $jsonStr');
      _webSocket!.add(jsonStr);
    } else {
      log('WebSocket not connected. Failed to send: $message');
    }
  }

  void _handleDisconnect(dynamic error) {
    _webSocket = null;
    onDisconnected?.call(error);
    
    _connectionAttempt++;

    if (_shouldReconnect && _cachedToken != null) {
      log('WebSocket reconnecting in 5 seconds...');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () {
        if (_cachedToken != null) {
          connect(_cachedToken!);
        }
      });
    }
  }
}
