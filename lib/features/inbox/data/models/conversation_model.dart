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
      if (product == null) return null;
      if (product is! Map) return 'Unknown Product'; // It's likely just an ID string
      
      final brand = product['brand'];
      final model = product['model'];
      final title = product['title'];
      final name = product['name'];
      
      if (brand != null && model != null && brand.toString().isNotEmpty && model.toString().isNotEmpty) {
        return "$brand $model";
      }
      return title ?? name ?? brand ?? model ?? 'Unknown Product';
    }

    String? extractProductId(dynamic product) {
      if (product == null) return null;
      if (product is String) return product;
      if (product is Map) {
        return product['_id'] ?? product['id'] ?? product['productId'];
      }
      return null;
    }

    final prodId = extractProductId(product);

    return ConversationModel(
      id: json['conversationId'] ?? '',
      otherUserId: other['_id'] ?? '',
      otherUserName: other['name'] ?? 'Unknown',
      otherUserAvatar: ApiEndpoints.resolveImageUrl(other['profileImage'] ?? ''),
      otherUserIsVerified: (other['role'] == 'VERIFIED_SELLER'),
      productId: prodId,
      productTitle: prodId != null ? parseTitle(product) : null,
      productImage: (product is Map && product['images'] != null && product['images'] is List && product['images'].isNotEmpty) 
          ? ApiEndpoints.resolveImageUrl(product['images'][0]) 
          : (product is Map && product['image'] != null && product['image'].toString().isNotEmpty ? ApiEndpoints.resolveImageUrl(product['image']) : null),
      productPrice: (product is Map) ? (product['price'] ?? product['amount'])?.toDouble() : null,
      lastMessage: lastMsg['type'] == 'image' ? '📷 Photo' : (lastMsg['message'] ?? ''),
      lastMessageTime: DateTime.parse(lastMsg['createdAt'] ?? DateTime.now().toIso8601String()),
      hasUnread: (json['unreadCount'] ?? 0) > 0,
      unreadCount: json['unreadCount'] ?? 0,
    );

  }
}
