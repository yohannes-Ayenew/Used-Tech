// lib/features/inbox/presentation/pages/inbox_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/inbox/presentation/pages/inbox_page_with_messages.dart';
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
    // Sample conversations data
    final List<Map<String, dynamic>> conversations = [
      {
        'id': '1',
        'name': 'Dawit Alemayehu',
        'product': 'Samsung Galaxy S21',
        'price': '32,000 ETB',
        'lastMessage':
            'That sounds good! I\'d like to proceed with the purchase.',
        'time': '06:18 PM',
        'unread': true,
        'avatar': 'D',
        'status': 'Completed',
        'statusColor': Colors.green,
      },
      {
        'id': '2',
        'name': 'Abebe Tesfa',
        'product': 'iPhone 13 Pro',
        'price': '50,000 ETB',
        'lastMessage': 'Is it still available?',
        'time': '10:30 AM',
        'unread': false,
        'avatar': 'A',
        'status': 'Escrow Active',
        'statusColor': Colors.blue,
      },
      {
        'id': '3',
        'name': 'Sara Kebede',
        'product': 'MacBook Air M1',
        'price': '85,000 ETB',
        'lastMessage': 'When can we meet?',
        'time': 'Yesterday',
        'unread': false,
        'avatar': 'S',
        'status': null,
        'statusColor': null,
      },
    ];

    final unreadCount = conversations.where((c) => c['unread']).length;

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
                  content: const Text("New message feature coming soon"),
                  backgroundColor: context.primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
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
                    color: unreadCount > 0 ? Colors.blue : context.greyText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  unreadCount > 0
                      ? "$unreadCount unread ${unreadCount == 1 ? 'message' : 'messages'}"
                      : "No unread messages",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: unreadCount > 0 ? Colors.blue : context.greyText,
                    fontWeight: unreadCount > 0
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conv = conversations[index];
          return _buildConversationItem(context, conv);
        },
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    Map<String, dynamic> conv,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InboxChatPage(conversation: conv),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: conv['unread']
              ? context.primaryColor.withValues(alpha: 0.02)
              : context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: conv['unread']
                ? context.primaryColor.withValues(alpha: 0.3)
                : context.borderColor,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  conv['avatar'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: context.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conv['name'],
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: conv['unread']
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(conv['time'], style: context.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${conv['product']} • ${conv['price']}",
                    style: context.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    conv['lastMessage'],
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontWeight: conv['unread']
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: conv['unread']
                          ? context.darkText
                          : context.greyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (conv['status'] != null) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: (conv['statusColor'] ?? Colors.green).withValues(
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            conv['status'] == 'Escrow Active'
                                ? Icons.security
                                : Icons.check_circle,
                            size: 12,
                            color: conv['statusColor'] ?? Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            conv['status'],
                            style: TextStyle(
                              fontSize: 10,
                              color: conv['statusColor'] ?? Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
