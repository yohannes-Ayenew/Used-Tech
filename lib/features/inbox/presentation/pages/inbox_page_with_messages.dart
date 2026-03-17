// lib/features/inbox/presentation/pages/inbox_page_with_messages.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/features/inbox/domain/entities/conversation_entity.dart';
import 'package:used_tech_client/features/inbox/domain/entities/message_entity.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_bloc.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_event.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_state.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_event.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_state.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../injection_container.dart';

class InboxChatPage extends StatefulWidget {
  final ConversationEntity conversation;

  const InboxChatPage({super.key, required this.conversation});

  @override
  State<InboxChatPage> createState() => _InboxChatPageState();
}

class _InboxChatPageState extends State<InboxChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ConversationEntity _currentConversation;

  @override
  void initState() {
    super.initState();
    _currentConversation = widget.conversation;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(GetMessagesEvent(
        conversationId: _currentConversation.id,
        productId: _currentConversation.productId,
      ));

      // 📩 Mark as read immediately
      context.read<ChatBloc>().add(MarkAsReadEvent(conversationId: _currentConversation.id));

      // 🔍 Fetch missing product details if needed
      if (_currentConversation.productId != null && 
          (_currentConversation.productTitle == 'Unknown Product' || 
           _currentConversation.productPrice == null)) {
        context.read<ProductBloc>().add(GetProductDetailsEvent(productId: _currentConversation.productId!));
      }
    });
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.9) {
        final state = context.read<ChatBloc>().state;
        if (state is MessagesLoaded && !state.hasReachedMax && !state.isPaginationLoading) {
          context.read<ChatBloc>().add(LoadMoreMessagesEvent(
            conversationId: _currentConversation.id,
            productId: _currentConversation.productId,
          ));
        }
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    context.read<ChatBloc>().add(SendMessageEvent(
      receiverId: _currentConversation.otherUserId,
      productId: _currentConversation.productId,
      message: _messageController.text,
    ));

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    // With reverse: true, we don't need manual scrolling for new messages
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = (authState is AuthSuccess) ? authState.user.id : "";

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: context.cardBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Hero(
              tag: "avatar_${_currentConversation.id}",
              child: CircleAvatar(
                radius: 18,
                backgroundColor: context.primaryColor.withValues(alpha: 0.1),
                child: _currentConversation.otherUserAvatar.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.network(
                          ApiEndpoints.resolveImageUrl(_currentConversation.otherUserAvatar),
                          fit: BoxFit.cover,
                          width: 36,
                          height: 36,
                        ),
                      )
                    : Text(
                        _currentConversation.otherUserName[0].toUpperCase(),
                        style: TextStyle(color: context.primaryColor, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentConversation.otherUserName,
                    style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Online", // Simulated for now
                    style: TextStyle(fontSize: 11, color: context.successColor, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: context.primaryColor),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, color: context.primaryColor),
            onPressed: () {},
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: context.primaryColor),
            color: context.cardBackground,
            onSelected: (value) {
              if (value == 'delete') {
                if (_currentConversation.id.startsWith('new_') || _currentConversation.id.isEmpty) {
                  Navigator.pop(context);
                } else {
                  context.read<ChatBloc>().add(DeleteConversationEvent(conversationId: _currentConversation.id));
                }
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text("Delete Chat", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ];
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ChatBloc, ChatState>(
            listenWhen: (previous, current) => current is ConversationDeleted || (current is ChatError && current.message.contains('delete')),
            listener: (context, state) {
              if (state is ConversationDeleted && state.conversationId == _currentConversation.id) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Chat deleted successfully'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                Navigator.pop(context);
              } else if (state is ChatError && state.message.contains('delete')) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),
          BlocListener<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductDetailsLoaded && state.product.id == _currentConversation.productId) {
                setState(() {
                  _currentConversation = _currentConversation.copyWith(
                    productTitle: state.product.title,
                    productPrice: state.product.price,
                    productImage: state.product.images.isNotEmpty ? state.product.images.first : null,
                  );
                });
              }
            },
          ),
        ],
        child: Column(
          children: [
            StreamBuilder<ConnectivityStatus>(
              stream: sl<ConnectivityService>().statusStream,
              initialData: sl<ConnectivityService>().currentStatus,
              builder: (context, snapshot) {
                if (snapshot.data == ConnectivityStatus.offline) {
                  return Container(
                    width: double.infinity,
                    color: Colors.red.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "No Internet Connection. Offline mode coming soon.",
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          _buildProductHeader(context),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.scaffoldBackgroundColor,
                image: DecorationImage(
                  image: const NetworkImage("https://www.transparenttextures.com/patterns/cubes.png"), // Subtle pattern
                  opacity: 0.03,
                  repeat: ImageRepeat.repeat,
                ),
              ),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading && state is! MessagesLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MessagesLoaded) {
                    final reversedMessages = state.messages.reversed.toList();
                    return Column(
                      children: [
                        if (state.isPaginationLoading)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        Expanded(
                          child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            itemCount: reversedMessages.length,
                            itemBuilder: (context, index) {
                              final msg = reversedMessages[index];
                              final bool isMe = msg.senderId == currentUserId || msg.senderId == "ME";
                              return _buildMessageBubble(context, msg, isMe);
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 48, color: context.greyText.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text("No messages yet", style: TextStyle(color: context.greyText)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
      )
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    if (_currentConversation.productTitle == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentConversation.productImage != null && _currentConversation.productImage!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                ApiEndpoints.resolveImageUrl(_currentConversation.productImage!), 
                width: 50, 
                height: 50, 
                fit: BoxFit.cover
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentConversation.productTitle!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _currentConversation.productPrice != null 
                    ? "${_currentConversation.productPrice!.toStringAsFixed(0)} ETB"
                    : "Discussing this item",
                  style: TextStyle(fontSize: 12, color: context.primaryColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/product-detail', arguments: _currentConversation.productId),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("View Item", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.add_rounded, color: context.primaryColor),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: context.greyText, fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: context.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: context.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessageEntity msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text(
                _currentConversation.otherUserName,
                style: TextStyle(fontSize: 10, color: context.greyText, fontWeight: FontWeight.bold),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? context.primaryColor : context.cardBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: const Radius.circular(20),
                bottomRight: const Radius.circular(20),
                topLeft: Radius.circular(isMe ? 20 : 4),
                topRight: Radius.circular(isMe ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              msg.message,
              style: TextStyle(
                color: isMe ? Colors.white : context.darkText,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(fontSize: 10, color: context.greyText),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  if (msg.status == MessageStatus.sending)
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.blue),
                    )
                  else if (msg.status == MessageStatus.failed)
                    const Icon(Icons.error_outline_rounded, size: 14, color: Colors.red)
                  else
                    Icon(
                      msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                      size: 14, 
                      color: msg.isRead ? Colors.blue : context.greyText,
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
