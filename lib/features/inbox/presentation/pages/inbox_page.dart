// lib/features/inbox/presentation/pages/inbox_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/inbox/presentation/pages/inbox_page_with_messages.dart';
import 'package:used_tech_client/features/inbox/domain/entities/conversation_entity.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_bloc.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_event.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<ChatBloc>().add(GetConversationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthBloc>().state is AuthSuccess;

    if (!isAuthenticated) {
      return _buildGuestMode(context);
    }

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocBuilder<ChatBloc, ChatState>(
        buildWhen: (previous, current) =>
            current is ConversationsLoaded ||
            current is ChatLoading ||
            current is ChatError,
        builder: (context, state) {
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, state),
              _buildSearchBox(context),
              _buildContent(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChatState state) {
    int unreadCount = 0;
    if (state is ConversationsLoaded) {
      unreadCount = state.unreadCount;
    }

    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: context.theme.scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "Inbox",
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: context.primaryColor,
              ),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.secondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: _onRefresh,
          icon: Icon(Icons.refresh, color: context.primaryColor),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.more_vert_rounded, color: context.primaryColor),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildSearchBox(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search messages...",
              hintStyle: TextStyle(color: context.greyText),
              prefixIcon: Icon(Icons.search, color: context.greyText),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ChatState state) {
    if (state is ChatLoading) {
      return _buildShimmerLoading();
    }

    if (state is ChatError) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.error_outline_rounded,
                      size: 64, color: Colors.red[300]),
                ),
                const SizedBox(height: 24),
                Text(
                  "Connection Issue",
                  style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(color: context.greyText),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _onRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Try Again"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is ConversationsLoaded) {
      if (state.conversations.isEmpty) {
        return _buildEmptyState(context);
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final conv = state.conversations[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildConversationItem(context, conv),
            );
          },
          childCount: state.conversations.length,
        ),
      );
    }

    // Trigger load if initial or anything else
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (state is ChatInitial) {
        context.read<ChatBloc>().add(GetConversationsEvent());
      }
    });
    
    return _buildShimmerLoading();
  }

  Widget _buildShimmerLoading() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[50]!,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 120, height: 16, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(width: double.infinity, height: 12, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        childCount: 6,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 80,
                color: context.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "No conversations yet",
              style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              "Browse premium tech deals and start\nchatting with sellers.",
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.greyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                 // Navigate to home/browse
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: const Text("Start Browsing", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationItem(BuildContext context, ConversationEntity conv) {
    final hasUnread = conv.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasUnread ? context.primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InboxChatPage(conversation: conv),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildAvatar(context, conv),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                conv.otherUserName,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              conv.lastMessageTimeFormatted,
                              style: context.textTheme.bodySmall?.copyWith(
                                color: hasUnread ? context.primaryColor : context.greyText,
                                fontWeight: hasUnread ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                conv.lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: hasUnread ? context.darkText : context.greyText,
                                  fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (hasUnread)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: context.primaryColor,
                                  shape: BoxShape.circle,
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
                        if (conv.productTitle != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.shopping_bag_outlined, size: 12, color: context.primaryColor),
                              const SizedBox(width: 4),
                              Text(
                                conv.productTitle!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: context.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ConversationEntity conv) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: conv.unreadCount > 0 ? context.primaryColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Hero(
            tag: "avatar_${conv.id}",
            child: CircleAvatar(
              radius: 30,
              backgroundColor: context.primaryColor.withValues(alpha: 0.1),
              // Use cached network image or fallback
              child: conv.otherUserAvatar.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.network(
                        ApiEndpoints.resolveImageUrl(conv.otherUserAvatar),
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                        errorBuilder: (_, __, ___) => _buildAvatarFallback(conv),
                      ),
                    )
                  : _buildAvatarFallback(conv),
            ),
          ),
        ),
        if (conv.otherUserIsVerified)
          Positioned(
            right: 0,
            bottom: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                size: 16,
                color: Colors.blue,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatarFallback(ConversationEntity conv) {
    return Text(
      conv.otherUserName.isNotEmpty ? conv.otherUserName[0].toUpperCase() : "?",
      style: TextStyle(
        color: context.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
    );
  }

  Widget _buildProductBadge(BuildContext context, ConversationEntity conv) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 14, color: context.primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              conv.productTitle!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.primaryColor,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestMode(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Inbox", style: context.textTheme.titleLarge),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: context.lightGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline_rounded,
                  size: 70,
                  color: context.greyText,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Sign in required",
                style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Please sign in to view your messages and start conversations with sellers.",
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(color: context.greyText),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text("Sign In", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}