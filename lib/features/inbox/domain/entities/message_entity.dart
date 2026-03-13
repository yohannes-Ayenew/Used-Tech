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
  final String? tempId; // For optimistic UI tracking
  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String message;
  final String type;
  final DateTime createdAt;
  final bool isRead;
  final MessageStatus status;

  const MessageEntity({
    required this.id,
    this.tempId,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.status = MessageStatus.sent,
  });

  bool get isImage => type == 'image';

  @override
  List<Object?> get props => [
    id,
    tempId,
    conversationId,
    senderId,
    message,
    type,
    createdAt,
    isRead,
    status,
  ];

  MessageEntity copyWith({
    String? id,
    String? tempId,
    MessageStatus? status,
    bool? isRead,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      tempId: tempId ?? this.tempId,
      conversationId: conversationId,
      senderId: senderId,
      senderName: senderName,
      senderAvatar: senderAvatar,
      message: message,
      type: type,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
    );
  }
}
