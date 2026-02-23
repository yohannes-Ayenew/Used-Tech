// lib/features/inbox/presentation/bloc/chat_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;
  final int unreadCount;
  const ConversationsLoaded(this.conversations, {this.unreadCount = 0});

  @override
  List<Object> get props => [conversations, unreadCount];
}

class MessagesLoaded extends ChatState {
  final List<MessageEntity> messages;
  final String conversationId;
  const MessagesLoaded(this.messages, this.conversationId);

  @override
  List<Object> get props => [messages, conversationId];
}

class MessageSent extends ChatState {
  final MessageEntity message;
  const MessageSent(this.message);

  @override
  List<Object> get props => [message];
}

class ConversationStarted extends ChatState {
  final ConversationEntity conversation;
  const ConversationStarted(this.conversation);

  @override
  List<Object> get props => [conversation];
}

class ChatError extends ChatState {
  final String message;
  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}
