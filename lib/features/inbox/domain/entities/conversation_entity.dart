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

  @override
  List<Object?> get props => [
    id,
    otherUserId,
    otherUserName,
    lastMessage,
    lastMessageTime,
    hasUnread,
    unreadCount,
  ];
}
