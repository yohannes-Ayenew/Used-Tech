// lib/core/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import '../../features/inbox/domain/repositories/chat_repository.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ChatRepository chatRepository;

  NotificationService({required this.chatRepository});

  Future<void> init() async {
    // Request permission (iOS/Web)
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token and save to backend
    String? token = await _fcm.getToken();
    if (token != null) {
      print("📱 FCM Token: $token");
      await chatRepository.updateFcmToken(token);
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
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🌘 Background Message: ${message.messageId}");
}
