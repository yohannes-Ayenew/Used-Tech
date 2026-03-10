// lib/features/inbox/presentation/pages/inbox_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/inbox/presentation/pages/inbox_page_with_messages.dart';
import 'package:used_tech_client/features/inbox/domain/entities/conversation_entity.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_bloc.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_event.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthBloc>().state is AuthSuccess;

    if (!isAuthenticated) {
      return _buildGuestMode(context);
    }

    return _buildAuthenticatedInbox(context);
  }

  Widget _buildGuestMode(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Inbox", style: context.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Please sign in to send messages"),
                  backgroundColor: context.primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 60,
                color: context.greyText,
              ),
            ),
            const SizedBox(height: 24),
            Text("No messages yet", style: context.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              "When you start conversations with buyers\nor sellers, they'll appear here",
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text("Browse products to start chatting"),
                    backgroundColor: context.primaryColor,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.search),
              label: const Text("Browse Products"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedInbox(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) => current is ConversationsLoaded || current is ChatLoading || current is ChatError,
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (state is ChatError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }

        if (state is ConversationsLoaded) {
          if (state.conversations.isEmpty) {
            return _buildEmptyState(context);
          }

          return Scaffold(
            backgroundColor: context.theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text("Inbox", style: context.textTheme.titleLarge),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: state.unreadCount > 0 ? Colors.blue : context.greyText,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.unreadCount > 0
                            ? "${state.unreadCount} unread ${state.unreadCount == 1 ? 'message' : 'messages'}"
                            : "No unread messages",
                        style: context.textTheme.bodySmall?.copyWith(
                          color: state.unreadCount > 0 ? Colors.blue : context.greyText,
                          fontWeight: state.unreadCount > 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(GetConversationsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.conversations.length,
                itemBuilder: (context, index) {
                  final conv = state.conversations[index];
                  return _buildConversationItem(context, conv);
                },
              ),
            ),
          );
        }

        // Trigger load if initial
        context.read<ChatBloc>().add(GetConversationsEvent());
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inbox")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text("No conversations yet"),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    ConversationEntity conv,
  ) {
    final hasUnread = conv.unreadCount > 0;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InboxChatPage(conversation: conv),
          ),
        );
      },
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.primaryColor.withValues(alpha: 0.1),
            child: Text(
              conv.otherUserName.isNotEmpty ? conv.otherUserName[0].toUpperCase() : "?",
              style: TextStyle(
                color: context.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          if (conv.otherUserIsVerified)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified,
                  size: 14,
                  color: Colors.blue,
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              conv.otherUserName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: hasUnread ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            conv.lastMessageTimeFormatted,
            style: context.textTheme.bodySmall?.copyWith(
              color: hasUnread ? Colors.blue : context.greyText,
              fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conv.lastMessage,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: hasUnread ? context.textTheme.bodyLarge?.color : context.greyText,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          if (hasUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                conv.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}