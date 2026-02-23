// lib/features/inbox/presentation/bloc/chat_event.dart

import 'package:equatable/equatable.dart';
import 'dart:io';

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
  final String conversationId;
  final String message;
  final File? imageFile;
  const SendMessageEvent({
    required this.conversationId,
    required this.message,
    this.imageFile,
  });

  @override
  List<Object> get props => [
        conversationId,
        message,
        if (imageFile != null) imageFile!,
      ];
}

class MarkAsReadEvent extends ChatEvent {
  final String conversationId;
  const MarkAsReadEvent({required this.conversationId});

  @override
  List<Object> get props => [conversationId];
}

class StartNewConversationEvent extends ChatEvent {
  final String productId;
  final String sellerId;
  final String initialMessage;
  const StartNewConversationEvent({
    required this.productId,
    required this.sellerId,
    required this.initialMessage,
  });

  @override
  List<Object> get props => [productId, sellerId, initialMessage];
}
