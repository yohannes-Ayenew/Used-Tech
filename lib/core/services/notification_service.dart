// lib/core/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/inbox/domain/repositories/chat_repository.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ChatRepository chatRepository;

  NotificationService({required this.chatRepository});
  
  ScaffoldMessengerState? get _messenger => _messengerKey?.currentState;
  GlobalKey<ScaffoldMessengerState>? _messengerKey;

  Future<void> init({GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey}) async {
    _messengerKey = scaffoldMessengerKey;
    try {
      // Request permission (iOS/Web)
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('🔔 User granted notification permission');
        
        // Get token and save to backend
        // Use a timeout for getToken especially on Web to prevent hanging
        String? token;
        try {
          token = await _fcm.getToken().timeout(const Duration(seconds: 10));
        } catch (e) {
          print('⚠️ FCM Token retrieval timed out or failed: $e');
        }

        if (token != null) {
          print("📱 FCM Token: $token");
          await chatRepository.updateFcmToken(token);
        }
      } else {
        print('❌ User declined or has not accepted notification permission');
      }

      // Handle token refresh
      _fcm.onTokenRefresh.listen((token) {
        chatRepository.updateFcmToken(token);
      });

      // Handle background notifications
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      print('✅ Notification Service fully initialized');
    } catch (e) {
      print('❌ Error initializing Notification Service: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 Notification Received: ${message.notification?.title}');
    
    final title = message.notification?.title ?? "Notification";
    final body = message.notification?.body ?? "";
    
    // Check for escrow related keywords to provide specific styling
    bool isEscrow = title.contains("Funds") || title.contains("Escrow") || body.contains("Funds") || body.contains("secured");
    bool isDelivery = title.contains("Delivered") || body.contains("delivered");

    if (_messenger != null) {
      _messenger!.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isEscrow ? Icons.security : (isDelivery ? Icons.check_circle : Icons.notifications),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (body.isNotEmpty)
                      Text(body, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: isEscrow ? Colors.blue : (isDelivery ? Colors.green : Colors.black87),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "VIEW",
            textColor: Colors.white,
            onPressed: () {
              // Implementation for navigation can be added here using navigatorKey
            },
          ),
        ),
      );
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🌘 Background Message: ${message.messageId}");
}
