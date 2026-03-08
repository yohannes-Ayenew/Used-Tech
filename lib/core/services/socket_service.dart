// lib/core/services/socket_service.dart

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_endpoints.dart';

class SocketService {
  io.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;

  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(ApiEndpoints.socketUrl, 
      io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .build()
    );

    _socket!.onConnect((_) {
      print('✅ Socket Connected');
      _socket!.emit('join', userId);
    });

    _socket!.on('receive_message', (data) {
      print('📩 Socket Message Received: $data');
      _messageController.add(data);
    });

    _socket!.onDisconnect((_) => print('❌ Socket Disconnected'));
    _socket!.onConnectError((err) => print('⚠️ Socket Connect Error: $err'));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }

  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }

  bool get isConnected => _socket?.connected ?? false;
}
