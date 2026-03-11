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

class InboxChatPage extends StatefulWidget {
  final ConversationEntity conversation;

  const InboxChatPage({super.key, required this.conversation});

  @override
  State<InboxChatPage> createState() => _InboxChatPageState();
}

class _InboxChatPageState extends State<InboxChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatBloc>().add(GetMessagesEvent(conversationId: widget.conversation.id));
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
      receiverId: widget.conversation.otherUserId,
      productId: widget.conversation.productId,
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
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              child: Text(
                widget.conversation.otherUserName[0].toUpperCase(),
                style: TextStyle(color: context.primaryColor, fontSize: 14),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.conversation.otherUserName, style: const TextStyle(fontSize: 16)),
                  if (widget.conversation.productTitle != null)
                    Text(widget.conversation.productTitle!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildProductHeader(context),
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading && state is! MessagesLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is MessagesLoaded) {
                  final reversedMessages = state.messages.reversed.toList();
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: reversedMessages.length,
                    itemBuilder: (context, index) {
                      final msg = reversedMessages[index];
                      return _buildMessageBubble(context, msg, msg.senderId == currentUserId);
                    },
                  );
                }
                return const Center(child: Text("No messages yet"));
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    if (widget.conversation.productTitle == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: context.cardBackground,
      child: Row(
        children: [
          if (widget.conversation.productImage != null)
             ClipRRect(
               borderRadius: BorderRadius.circular(4),
               child: Image.network(widget.conversation.productImage!, width: 40, height: 40, fit: BoxFit.cover),
             ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(widget.conversation.productTitle!, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text("Buy Now"),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.cardBackground,
        border: Border(top: BorderSide(color: context.borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("File attachment coming soon"),
                    backgroundColor: context.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: context.lightGrey,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send),
              color: context.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessageEntity msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            decoration: BoxDecoration(
              color: isMe ? context.primaryColor : context.lightGrey.withValues(alpha: 0.8),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 0),
                bottomRight: Radius.circular(isMe ? 0 : 16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              msg.message,
              style: TextStyle(
                color: isMe ? Colors.white : context.textTheme.bodyLarge?.color,
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Text(
              "${msg.createdAt.hour}:${msg.createdAt.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                fontSize: 10,
                color: context.greyText,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
