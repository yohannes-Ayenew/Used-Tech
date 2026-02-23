// lib/features/inbox/presentation/bloc/chat_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<GetConversationsEvent>(_onGetConversations);
    on<GetMessagesEvent>(_onGetMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<StartNewConversationEvent>(_onStartNewConversation);
  }

  Future<void> _onGetConversations(
    GetConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      // TODO: Implement get conversations
      // final conversations = await chatRepository.getConversations();
      // final unreadCount = conversations.where((c) => c.hasUnread).length;
      emit(const ConversationsLoaded([], unreadCount: 0));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onGetMessages(
    GetMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      // TODO: Implement get messages
      // final messages = await chatRepository.getMessages(event.conversationId);
      emit(MessagesLoaded([], event.conversationId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // TODO: Implement send message
      // final message = await chatRepository.sendMessage(
      //   conversationId: event.conversationId,
      //   message: event.message,
      //   imageFile: event.imageFile,
      // );
      // emit(MessageSent(message));

      // Refresh messages after sending
      add(GetMessagesEvent(conversationId: event.conversationId));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // TODO: Implement mark as read
      // await chatRepository.markAsRead(event.conversationId);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onStartNewConversation(
    StartNewConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    try {
      // TODO: Implement start new conversation
      // final conversation = await chatRepository.startConversation(
      //   productId: event.productId,
      //   sellerId: event.sellerId,
      //   initialMessage: event.initialMessage,
      // );
      // emit(ConversationStarted(conversation));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
