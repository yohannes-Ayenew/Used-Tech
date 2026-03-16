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
    super.productPrice,
    required super.lastMessage,
    required super.lastMessageTime,
    required super.hasUnread,
    required super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    final other = json['otherPerson'] ?? {};
    final product = json['product'];
    final lastMsg = json['lastMessage'] ?? {};

    String? parseTitle(dynamic product) {
      if (product is! Map) return null;
      final brand = product['brand'];
      final model = product['model'];
      final title = product['title'];
      final name = product['name'];
      
      if (brand != null && model != null && brand.toString().isNotEmpty && model.toString().isNotEmpty) {
        return "$brand $model";
      }
      return title ?? name ?? brand ?? model ?? 'Unknown Product';
    }

    return ConversationModel(
      id: json['conversationId'] ?? '',
      otherUserId: other['_id'] ?? '',
      otherUserName: other['name'] ?? 'Unknown',
      otherUserAvatar: ApiEndpoints.resolveImageUrl(other['profileImage'] ?? ''),
      otherUserIsVerified: (other['role'] == 'VERIFIED_SELLER'),
      productId: (product is Map) ? product['_id'] : null,
      productTitle: parseTitle(product),
      productImage: (product is Map && product['images'] != null && product['images'] is List && product['images'].isNotEmpty) 
          ? ApiEndpoints.resolveImageUrl(product['images'][0]) 
          : (product is Map && product['image'] != null ? ApiEndpoints.resolveImageUrl(product['image']) : null),
      productPrice: (product is Map) ? (product['price'] ?? product['amount'] ?? 0).toDouble() : null,
      lastMessage: lastMsg['type'] == 'image' ? '📷 Photo' : (lastMsg['message'] ?? ''),
      lastMessageTime: DateTime.parse(lastMsg['createdAt'] ?? DateTime.now().toIso8601String()),
      hasUnread: (json['unreadCount'] ?? 0) > 0,
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
}
