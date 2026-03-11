// lib/core/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/inbox/domain/repositories/chat_repository.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ChatRepository chatRepository;

  NotificationService({required this.chatRepository});

  Future<void> init() async {
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
        print('🔔 Notification Received: ${message.notification?.title}');
      });

      print('✅ Notification Service fully initialized');
    } catch (e) {
      print('❌ Error initializing Notification Service: $e');
    }
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🌘 Background Message: ${message.messageId}");
}
