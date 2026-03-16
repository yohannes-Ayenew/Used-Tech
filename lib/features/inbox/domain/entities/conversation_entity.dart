// lib/features/inbox/domain/entities/conversation_entity.dart

import 'package:equatable/equatable.dart';

class ConversationEntity extends Equatable {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;
  final bool otherUserIsVerified;
  final String? productId;
  final String? productTitle;
  final String? productImage;
  final double? productPrice;
  final String lastMessage;
  final DateTime lastMessageTime;
  final bool hasUnread;
  final int unreadCount;

  const ConversationEntity({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUserAvatar,
    required this.otherUserIsVerified,
    this.productId,
    this.productTitle,
    this.productImage,
    this.productPrice,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.hasUnread,
    required this.unreadCount,
  });

  String get lastMessageTimeFormatted {
    final now = DateTime.now();
    final difference = now.difference(lastMessageTime);

    if (difference.inDays > 7) {
      return '${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  bool get isImage => lastMessage.startsWith('📷'); // Simple heuristic for now

  ConversationEntity copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? hasUnread,
    int? unreadCount,
  }) {
    return ConversationEntity(
      id: id,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatar: otherUserAvatar,
      otherUserIsVerified: otherUserIsVerified,
      productId: productId,
      productTitle: productTitle,
      productImage: productImage,
      productPrice: productPrice,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      hasUnread: hasUnread ?? this.hasUnread,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        otherUserId,
        otherUserName,
        productId,
        productTitle,
        productImage,
        productPrice,
        lastMessage,
        lastMessageTime,
        unreadCount,
        hasUnread,
      ];
}
