// lib/features/inbox/data/models/conversation_model.dart

import 'package:used_tech_client/core/constants/api_endpoints.dart';
import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.otherUserId,
    required super.otherUserName,
    required super.otherUserAvatar,
    required super.otherUserIsVerified,
    super.productId,
    super.productTitle,
    super.productImage,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.hasUnread,
    required super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final other = json['otherPerson'] ?? {};
    final product = json['product'];
    final lastMsg = json['lastMessage'] ?? {};

    return ConversationModel(
      id: json['conversationId'] ?? '',
      otherUserId: other['_id'] ?? '',
      otherUserName: other['name'] ?? 'Unknown',
      otherUserAvatar: ApiEndpoints.resolveImageUrl(other['profileImage'] ?? ''),
      otherUserIsVerified: (other['role'] == 'VERIFIED_SELLER'),
      productId: (product is Map) ? product['_id'] : null,
      productTitle: (product is Map) ? "${product['brand']} ${product['model']}" : null,
      productImage: (product is Map && product['images'] != null && product['images'].isNotEmpty) 
          ? ApiEndpoints.resolveImageUrl(product['images'][0]) 
          : null,
      lastMessage: lastMsg['type'] == 'image' ? '📷 Photo' : (lastMsg['message'] ?? ''),
      lastMessageTime: DateTime.parse(lastMsg['createdAt'] ?? DateTime.now().toIso8601String()),
      hasUnread: (json['unreadCount'] ?? 0) > 0,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
