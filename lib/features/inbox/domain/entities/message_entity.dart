// lib/features/inbox/domain/entities/message_entity.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed;

  IconData get icon {
    switch (this) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.done;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color get color {
    switch (this) {
      case MessageStatus.sending:
        return Colors.grey;
      case MessageStatus.sent:
        return Colors.grey;
      case MessageStatus.delivered:
        return Colors.grey;
      case MessageStatus.read:
        return Colors.blue;
      case MessageStatus.failed:
        return Colors.red;
    }
  }
}

class MessageEntity extends Equatable {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;

  const MessageEntity({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
  });

  bool get isImage => type == 'image';

  @override
  List<Object?> get props => [
    id,
    conversationId,
    senderId,
    message,
    type,
    createdAt,
    isRead,
  ];
}
