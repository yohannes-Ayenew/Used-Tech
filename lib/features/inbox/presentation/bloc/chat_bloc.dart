import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../../core/services/socket_service.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/message_entity.dart';
import '../../data/models/message_model.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;
  final SocketService socketService;
  StreamSubscription? _socketSubscription;

  ChatBloc({
    required this.chatRepository,
    required this.socketService,
  }) : super(ChatInitial()) {
    on<GetConversationsEvent>(_onGetConversations);
    on<GetMessagesEvent>(_onGetMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<MarkAsReadEvent>(_onMarkAsRead);
    on<StartNewConversationEvent>(_onStartNewConversation);
    on<ReceiveSocketMessageEvent>(_onReceiveSocketMessage);

    // Listen to Socket messages
    _socketSubscription = socketService.messageStream.listen((data) {
      final message = MessageModel.fromJson(data);
      add(ReceiveSocketMessageEvent(message));
    });
  }

  @override
  Future<void> close() {
    _socketSubscription?.cancel();
    return super.close();
  }

  Future<void> _onGetConversations(
    GetConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await chatRepository.getConversations();
    result.fold(
      (failure) => emit(ChatError("Failed to load conversations")),
      (conversations) {
        final unread = conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);
        emit(ConversationsLoaded(conversations, unreadCount: unread));
      },
    );
  }

  Future<void> _onGetMessages(
    GetMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await chatRepository.getChatHistory(event.conversationId);
    result.fold(
      (failure) => emit(ChatError("Failed to load messages")),
      (messages) => emit(MessagesLoaded(messages, event.conversationId)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    // Optimistic UI update or wait for result
    // For now, let's wait for the repository result which includes the populated message
    final result = await chatRepository.sendMessage(
      receiverId: event.receiverId,
      productId: event.productId,
      message: event.message,
    );

    result.fold(
      (failure) => emit(ChatError("Failed to send message")),
      (message) {
        // State will be updated via socket listener if connected, 
        // but we emit MessageSent for immediate feedback if needed.
        emit(MessageSent(message));
      },
    );
  }

  void _onReceiveSocketMessage(
    ReceiveSocketMessageEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      if (currentState.conversationId == event.message.conversationId) {
        final updatedMessages = List<MessageEntity>.from(currentState.messages)..add(event.message);
        emit(MessagesLoaded(updatedMessages, currentState.conversationId));
      }
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    // No-op or update local unread state
  }

  Future<void> _onStartNewConversation(
    StartNewConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    final result = await chatRepository.sendMessage(
      receiverId: event.sellerId,
      productId: event.productId,
      message: event.initialMessage,
    );

    result.fold(
      (failure) => emit(ChatError("Failed to start conversation")),
      (message) {
        emit(MessageSent(message));
        // Navigation should be handled in UI
      },
    );
  }
}
