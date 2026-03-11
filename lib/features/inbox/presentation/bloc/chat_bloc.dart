import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../../../../core/services/socket_service.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/conversation_entity.dart';
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
    final message = event.message;

    // 1. Update Messages list if we are currently in that chat
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      if (currentState.conversationId == message.conversationId) {
        final updatedMessages = List<MessageEntity>.from(currentState.messages)..add(message);
        emit(MessagesLoaded(updatedMessages, currentState.conversationId));
      }
    }

    // 2. Update Conversations list (even if not active, for background updates)
    // This is tricky because Bloc doesn't easily allow updating a DIFFERENT state.
    // However, if the current state is ConversationsLoaded, we can update it.
    if (state is ConversationsLoaded) {
      final currentState = state as ConversationsLoaded;
      final conversations = List<ConversationEntity>.from(currentState.conversations);
      
      final index = conversations.indexWhere((c) => c.id == message.conversationId);
      
      if (index != -1) {
        final conv = conversations[index];
        conversations[index] = conv.copyWith(
          lastMessage: message.message,
          lastMessageTime: message.createdAt,
          hasUnread: true,
          unreadCount: conv.unreadCount + 1,
        );
        
        // Move to top
        final moved = conversations.removeAt(index);
        conversations.insert(0, moved);
        
        emit(ConversationsLoaded(conversations, unreadCount: currentState.unreadCount + 1));
      } else {
        // Handle new conversation appearing? 
        // For simplicity, we could trigger a refresh.
        add(GetConversationsEvent());
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
        // We need to fetch the conversation entity for the UI to navigate
        // Since the backend creates/returns a message with a conversationId,
        // we can potentially load the conversations to find it or have the repo return it.
        // For now, let's trigger a refresh and maybe a specific state.
        emit(MessageSent(message));
      },
    );
  }
}
