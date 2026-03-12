// lib/features/profile/presentation/pages/seller_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import 'package:used_tech_client/features/product/domain/repositories/product_repository.dart';
import 'package:used_tech_client/injection_container.dart';
import 'package:used_tech_client/common/widgets/auth_bottom_sheet.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_bloc.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_event.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_state.dart';
import 'package:used_tech_client/features/inbox/domain/entities/conversation_entity.dart';
import 'package:used_tech_client/features/inbox/presentation/pages/inbox_page_with_messages.dart';
import 'package:used_tech_client/features/profile/presentation/widgets/verification_badge.dart';
import 'package:used_tech_client/features/product/presentation/widgets/product_card.dart';
import 'package:used_tech_client/common/widgets/error_display.dart';

class SellerProfilePage extends StatefulWidget {
  final String sellerId;
  final String sellerName;
  final bool isVerified;
  final String? sellerProfileImage;
  // In a real app, these would come from the API payload
  // For now, we mock them to match the design perfectly
  final String joinDateMock = "Jan 2023";
  final double ratingMock = 4.8;
  final int itemsSoldMock = 24;
  final String responseTimeMock = "< 1 hr";

  const SellerProfilePage({
    super.key,
    required this.sellerId,
    required this.sellerName,
    this.isVerified = false,
    this.sellerProfileImage,
  });

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleAction(BuildContext context, String action) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$action - Feature coming soon"),
          backgroundColor: context.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const AuthBottomSheet(),
      );
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Seller Profile",
          style: context.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: context.theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: context.cardBackground.withValues(alpha: 0.9),
              child: Icon(Icons.arrow_back, color: context.darkText, size: 20),
            ),
          ),
        ),
        iconTheme: IconThemeData(color: context.darkText),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildStatsCard(),
                    const SizedBox(height: 16),
                    _buildTrustVerification(),
                    const SizedBox(height: 24),
                    _buildActionButtons(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: context.primaryColor,
                  unselectedLabelColor: context.greyText,
                  indicatorColor: context.primaryColor,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: "Active Listings"),
                    Tab(text: "Reviews (6)"),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActiveListingsTab(),
            _buildReviewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = _getInitials(widget.sellerName);

    return Row(
      children: [
        Stack(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primaryColor.withValues(alpha: 0.1),
              ),
              child: widget.sellerProfileImage != null &&
                      widget.sellerProfileImage!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: ApiEndpoints.resolveImageUrl(
                            widget.sellerProfileImage!),
                        fit: BoxFit.cover,
                        width: 80,
                        height: 80,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: context.primaryColor,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: TextStyle(
                          color: context.primaryColor,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            if (widget.isVerified)
              const Positioned(
                bottom: 0,
                right: 0,
                child: VerificationBadge(
                  isVerified: true,
                  size: 24,
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.sellerName,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Member since ${widget.joinDateMock}",
              style: TextStyle(
                color: context.secondaryColor,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  "Active 5m ago",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
              Icons.star, Colors.orange, "${widget.ratingMock}", "Rating"),
          Container(height: 40, width: 1, color: context.borderColor),
          _buildStatItem(
              null, null, "${widget.itemsSoldMock}", "Items Sold"),
          Container(height: 40, width: 1, color: context.borderColor),
          _buildStatItem(
              Icons.access_time, context.greyText, widget.responseTimeMock, "Response"),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData? icon, Color? iconColor, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 4),
            ],
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: context.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTrustVerification() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined,
                  size: 18, color: context.successColor),
              const SizedBox(width: 8),
              Text(
                "Trust & Verification",
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildTrustBadge(Icons.verified_user_outlined, "ID Verified"),
              _buildTrustBadge(Icons.phone_outlined, "Phone Verified"),
              _buildTrustBadge(Icons.health_and_safety_outlined, "Escrow Accepted"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.successColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.successColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BlocListener<ChatBloc, ChatState>(
            listenWhen: (previous, current) => current is MessageSent || current is ChatError,
            listener: (context, state) {
              if (state is MessageSent) {
                final conv = ConversationEntity(
                  id: state.message.conversationId,
                  otherUserId: widget.sellerId,
                  otherUserName: widget.sellerName,
                  otherUserAvatar: widget.sellerProfileImage ?? "",
                  otherUserIsVerified: widget.isVerified,
                  lastMessage: state.message.message,
                  lastMessageTime: state.message.createdAt,
                  hasUnread: false,
                  unreadCount: 0,
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InboxChatPage(conversation: conv),
                  ),
                );
              } else if (state is ChatError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
            child: ElevatedButton(
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthSuccess) {
                  context.read<ChatBloc>().add(StartNewConversationEvent(
                        sellerId: widget.sellerId,
                        initialMessage: "Hi ${widget.sellerName}, I'm interested in your listings!",
                      ));
                } else {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const AuthBottomSheet(),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading) {
                    return const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    );
                  }
                  return const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 20, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        "Chat with Seller",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _handleAction(context, "Follow"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: context.borderColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 20, color: context.primaryColor),
                const SizedBox(width: 8),
                Text(
                  "Following",
                  style: TextStyle(
                    color: context.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveListingsTab() {
    return BlocProvider(
      create: (context) => ProductBloc(
        productRepository: sl<ProductRepository>(),
      )..add(GetProductsEvent(sellerId: widget.sellerId)),
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductError) {
            return ErrorDisplay(
              onRetry: () {
                context.read<ProductBloc>().add(
                      GetProductsEvent(sellerId: widget.sellerId),
                    );
              },
            );
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return Center(
                child: Text(
                  "No active listings found.",
                  style: TextStyle(color: context.greyText),
                ),
              );
            }
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemBuilder: (context, index) {
                return ProductCard(product: state.products[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildReviewsTab() {
    // Mocking reviews to match design
    final reviews = [
      {
        "initial": "D",
        "name": "Dawit M.",
        "date": "2 days ago",
        "text": "Phone was exactly as described! Fast shipping and great communication. Highly recommended seller.",
        "stars": 5,
      },
      {
        "initial": "S",
        "name": "Sara K.",
        "date": "1 week ago",
        "text": "Professional seller. Item arrived in perfect condition with original box.",
        "stars": 5,
      },
      {
        "initial": "Y",
        "name": "Yonas T.",
        "date": "2 weeks ago",
        "text": "Good experience overall. Minor scratches not mentioned but price was fair.",
        "stars": 4,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: context.lightGrey,
                    child: Text(
                      review["initial"] as String,
                      style: TextStyle(
                        color: context.secondaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          review["name"] as String,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          review["date"] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: context.secondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: List.generate(5, (starIndex) {
                      return Icon(
                        starIndex < (review["stars"] as int)
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.orange,
                        size: 16,
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                review["text"] as String,
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
