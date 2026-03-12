// lib/features/inbox/presentation/bloc/chat_event.dart

import 'package:equatable/equatable.dart';
import 'package:used_tech_client/features/inbox/domain/entities/message_entity.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class GetConversationsEvent extends ChatEvent {}

class GetMessagesEvent extends ChatEvent {
  final String conversationId;
  const GetMessagesEvent({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class SendMessageEvent extends ChatEvent {
  final String receiverId;
  final String? productId;
  final String message;
  final String type;
  
  const SendMessageEvent({
    required this.receiverId,
    this.productId,
    required this.message,
    this.type = 'text',
  });

  @override
  List<Object> get props => [
        receiverId,
        message,
        type,
        if (productId != null) productId!,
      ];
}

class MarkAsReadEvent extends ChatEvent {
  final String conversationId;
  const MarkAsReadEvent({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class StartNewConversationEvent extends ChatEvent {
  final String? productId;
  final String sellerId;
  final String initialMessage;
  const StartNewConversationEvent({
    this.productId,
    required this.sellerId,
    required this.initialMessage,
  });

  @override
  List<Object> get props => [
        if (productId != null) productId!,
        sellerId,
        initialMessage,
      ];
}

class ReceiveSocketMessageEvent extends ChatEvent {
  final MessageEntity message;
  const ReceiveSocketMessageEvent(this.message);

  @override
  List<Object> get props => [message];
}
