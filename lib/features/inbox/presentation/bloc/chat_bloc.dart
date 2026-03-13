import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_event.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_state.dart';
import 'package:used_tech_client/core/services/socket_service.dart';
import 'package:used_tech_client/features/inbox/domain/repositories/chat_repository.dart';
import 'package:used_tech_client/features/inbox/domain/entities/conversation_entity.dart';
import 'package:used_tech_client/features/inbox/domain/entities/message_entity.dart';
import 'package:used_tech_client/features/inbox/data/models/message_model.dart';

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
    on<LoadMoreMessagesEvent>(_onLoadMoreMessages);
    on<UpdateMessageStatusEvent>(_onUpdateMessageStatus);

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
    if (state is! ConversationsLoaded) {
      emit(ChatLoading());
    }
    final result = await chatRepository.getConversations();
    result.fold(
      (failure) => emit(ChatError(failure.message)),
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
    if (state is! MessagesLoaded || (state as MessagesLoaded).conversationId != event.conversationId) {
      emit(ChatLoading());
    }
    final result = await chatRepository.getChatHistory(event.conversationId, page: 1);
    result.fold(
      (failure) => emit(ChatError("Failed to load messages")),
      (messages) => emit(MessagesLoaded(
        messages, 
        event.conversationId,
        hasReachedMax: messages.length < 20, // Assuming 20 is the limit
        currentPage: 1,
      )),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    final tempId = DateTime.now().millisecondsSinceEpoch.toString();
    
    // 1. Optimistic Update
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      final optimisticMsg = MessageEntity(
        id: tempId,
        tempId: tempId,
        conversationId: currentState.conversationId,
        senderId: "ME", // Dummy for UI to recognize
        senderName: "Me",
        message: event.message,
        type: event.type,
        createdAt: DateTime.now(),
        isRead: false,
        status: MessageStatus.sending,
      );
      
      final updatedMessages = List<MessageEntity>.from(currentState.messages)..add(optimisticMsg);
      emit(currentState.copyWith(messages: updatedMessages));
    }

    final result = await chatRepository.sendMessage(
      receiverId: event.receiverId,
      productId: event.productId,
      message: event.message,
    );

    result.fold(
      (failure) {
        add(UpdateMessageStatusEvent(tempId: tempId, status: MessageStatus.failed));
      },
      (message) {
        add(UpdateMessageStatusEvent(tempId: tempId, status: MessageStatus.sent, finalMessage: message));
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
        // Prevent duplicate if we already have it (from optimistic or direct send)
        final alreadyExists = currentState.messages.any((m) => m.id == message.id);
        if (!alreadyExists) {
          final updatedMessages = List<MessageEntity>.from(currentState.messages)..add(message);
          emit(currentState.copyWith(messages: updatedMessages));
        }
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

  Future<void> _onLoadMoreMessages(
    LoadMoreMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    if (state is! MessagesLoaded) return;
    final currentState = state as MessagesLoaded;
    if (currentState.hasReachedMax || currentState.isPaginationLoading) return;

    emit(currentState.copyWith(isPaginationLoading: true));

    final nextPage = currentState.currentPage + 1;
    final result = await chatRepository.getChatHistory(event.conversationId, page: nextPage);

    result.fold(
      (failure) => emit(currentState.copyWith(isPaginationLoading: false)),
      (newMessages) {
        if (newMessages.isEmpty) {
          emit(currentState.copyWith(hasReachedMax: true, isPaginationLoading: false));
        } else {
          final updatedMessages = List<MessageEntity>.from(newMessages)..addAll(currentState.messages);
          emit(currentState.copyWith(
            messages: updatedMessages,
            currentPage: nextPage,
            isPaginationLoading: false,
            hasReachedMax: newMessages.length < 20,
          ));
        }
      },
    );
  }

  void _onUpdateMessageStatus(
    UpdateMessageStatusEvent event,
    Emitter<ChatState> emit,
  ) {
    if (state is MessagesLoaded) {
      final currentState = state as MessagesLoaded;
      final messages = List<MessageEntity>.from(currentState.messages);
      final index = messages.indexWhere((m) => m.tempId == event.tempId);

      if (index != -1) {
        if (event.status == MessageStatus.sent && event.finalMessage != null) {
          messages[index] = event.finalMessage!;
        } else {
          messages[index] = messages[index].copyWith(status: event.status);
        }
        emit(currentState.copyWith(messages: messages));
      }
    }
  }
}
