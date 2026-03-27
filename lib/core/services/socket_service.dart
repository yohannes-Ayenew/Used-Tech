// lib/core/services/socket_service.dart

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/api_endpoints.dart';

class SocketService {
  io.Socket? _socket;
  final _messageController = StreamController<Map<String, dynamic>>.broadcast();
  final _statusController = StreamController<bool>.broadcast();

  Stream<Map<String, dynamic>> get messageStream => _messageController.stream;
  Stream<bool> get statusStream => _statusController.stream;

  void connect(String userId) {
    if (_socket != null && _socket!.connected) return;

    _socket = io.io(ApiEndpoints.socketUrl, 
      io.OptionBuilder()
        .setTransports(['websocket'])
        .enableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(10)
        .setReconnectionDelay(2000)
        .build()
    );

    _socket!.onConnect((_) {
      print('✅ Socket Connected');
      _statusController.add(true);
      _socket!.emit('join_user_room', userId);
    });

    _socket!.on('receive_message', (data) {
      print('📩 Socket Message Received: $data');
      _messageController.add(data);
    });

    _socket!.on('order_update', (data) {
      print('📦 Socket Order Update: $data');
      _messageController.add({
        ...Map<String, dynamic>.from(data),
        'socket_event': 'order_update',
      });
    });

    _socket!.on('payment_status', (data) {
      print('💰 Socket Payment Status: $data');
      _messageController.add({
        ...Map<String, dynamic>.from(data),
        'socket_event': 'payment_status',
      });
    });

    _socket!.onDisconnect((_) {
      print('❌ Socket Disconnected');
      _statusController.add(false);
    });

    _socket!.onConnectError((err) {
      print('⚠️ Socket Connect Error: $err');
      _statusController.add(false);
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _statusController.add(false);
  }

  void emit(String event, dynamic data) {
    if (_socket?.connected ?? false) {
      _socket?.emit(event, data);
    } else {
      print('⚠️ Socket not connected, cannot emit $event');
    }
  }

  bool get isConnected => _socket?.connected ?? false;
}
