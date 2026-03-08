// lib/features/inbox/data/models/message_model.dart

import '../../domain/entities/message_entity.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.message,
    required super.type,
    required super.createdAt,
    required super.isRead,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    // Handle nested sender population
    final sender = json['senderId'];
    final senderName = (sender is Map) ? sender['name'] : 'Unknown';
    final senderAvatar = (sender is Map) ? sender['profileImage'] : null;

    return MessageModel(
      id: json['_id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      senderId: (sender is Map) ? sender['_id'] : (sender ?? ''),
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: json['message'] ?? '',
      type: json['type'] ?? 'text',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      isRead: json['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverId': id, // Used when sending
      'conversationId': conversationId,
      'message': message,
      'type': type,
    };
  }
}
