// lib/features/product/presentation/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/favorites_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/favorites_event.dart';
import 'package:used_tech_client/features/product/presentation/bloc/favorites_state.dart';
import 'package:used_tech_client/common/widgets/auth_bottom_sheet.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_bloc.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_event.dart';
import 'package:used_tech_client/features/inbox/presentation/bloc/chat_state.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:used_tech_client/features/product/domain/entities/product_entity.dart';
import 'package:used_tech_client/features/product/presentation/widgets/product_card.dart';
import 'package:used_tech_client/features/product/domain/repositories/product_repository.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import 'package:used_tech_client/common/widgets/error_display.dart';
import 'package:used_tech_client/injection_container.dart';
import 'package:used_tech_client/features/profile/presentation/pages/seller_profile_page.dart';
import 'package:used_tech_client/features/inbox/domain/entities/conversation_entity.dart';
import 'package:used_tech_client/features/inbox/presentation/pages/inbox_page_with_messages.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _getDisplayLocation() {
    if (widget.product.sellerLocation != null && widget.product.sellerLocation!.isNotEmpty) {
      return widget.product.sellerLocation!;
    }
    return widget.product.location;
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Header
                Stack(
                  children: [
                    SizedBox(
                      height: 350,
                      child: widget.product.images.isNotEmpty
                          ? PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: widget.product.images.length,
                              itemBuilder: (context, index) {
                                return CachedNetworkImage(
                                  imageUrl: ApiEndpoints.resolveImageUrl(
                                      widget.product.images[index]),
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: context.lightGrey,
                                    child: const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    color: context.lightGrey,
                                    child: Icon(
                                      Icons.image_not_supported,
                                      color: context.greyText,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: context.lightGrey,
                              child: Icon(
                                Icons.image_not_supported,
                                color: context.greyText,
                              ),
                            ),
                    ),
                    // Dots indicator
                    if (widget.product.images.length > 1)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.product.images.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              height: 8,
                              width: _currentPage == index ? 24 : 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index
                                    ? context.primaryColor
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: _buildCircleBtn(
                        context,
                        Icons.arrow_back,
                        () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 16,
                      child: Row(
                        children: [
                          BlocBuilder<FavoritesBloc, FavoritesState>(
                            builder: (context, state) {
                              bool isFavorite = false;
                              if (state is FavoritesLoaded) {
                                isFavorite = state.products
                                    .any((p) => p.id == widget.product.id);
                              }
                              return _buildCircleBtn(
                                context,
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                () {
                                  context
                                      .read<FavoritesBloc>()
                                      .add(ToggleFavorite(widget.product));
                                },
                                iconColor: isFavorite ? Colors.red : null,
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          _buildCircleBtn(context, Icons.share, () {
                            _handleAction(context, "Share");
                          }),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Price
                      Text(
                        widget.product.title,
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(
                            context,
                            widget.product.condition.displayName,
                            widget.product.condition.color.withValues(alpha: 0.1),
                            widget.product.condition.color,
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: context.greyText,
                          ),
                          Text(
                            " ${_getDisplayLocation()}",
                            style: context.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "${widget.product.formattedPrice} ETB",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      if (widget.product.description.isNotEmpty) ...[
                        Text(
                          "Description",
                          style: context.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product.description,
                          style: context.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 25),
                      ],

                      // Escrow Protection
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: context.primaryColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user_outlined,
                              color: context.primaryColor,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Escrow Protection",
                                    style: context.textTheme.titleMedium
                                        ?.copyWith(color: context.primaryColor),
                                  ),
                                  Text(
                                    "Your payment is protected by escrow. Funds are released only after you confirm delivery.",
                                    style: context.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Seller Information
                      Text(
                        "Seller Information",
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: context.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: context.cardBackground,
                                  ),
                                  child: widget.product.sellerProfileImage != null &&
                                          widget.product.sellerProfileImage!.isNotEmpty
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: ApiEndpoints.resolveImageUrl(
                                                widget.product.sellerProfileImage!),
                                            fit: BoxFit.cover,
                                            width: 40,
                                            height: 40,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2),
                                            ),
                                            errorWidget: (context, url,
                                                    error) =>
                                                Center(
                                              child: Text(
                                                _getInitials(widget.product.sellerName),
                                                style: context.textTheme.titleMedium,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Center(
                                          child: Text(
                                            _getInitials(widget.product.sellerName),
                                            style: context.textTheme.titleMedium,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          widget.product.sellerName,
                                          style: context.textTheme.titleMedium,
                                        ),
                                        if (widget.product.isSellerVerified) ...[
                                          const SizedBox(width: 4),
                                          Icon(
                                            Icons.check_circle,
                                            color: context.primaryColor,
                                            size: 14,
                                          ),
                                        ],
                                      ],
                                    ),
                                      Text(
                                        widget.product.isSellerVerified
                                            ? "Verified Seller"
                                            : "Member",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: context.secondaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            size: 10,
                                            color: context.greyText,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getDisplayLocation(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: context.greyText,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SellerProfilePage(
                                          sellerId: widget.product.sellerId,
                                          sellerName: widget.product.sellerName,
                                          isVerified: widget.product.isSellerVerified,
                                          sellerProfileImage: widget.product.sellerProfileImage,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "View Profile",
                                    style: TextStyle(
                                      color: context.primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Contact Info
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isAuthenticated = state is AuthSuccess;

                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAuthenticated
                                        ? context.successColor.withValues(
                                            alpha: 0.1,
                                          )
                                        : context.cardBackground,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isAuthenticated
                                          ? context.successColor.withValues(
                                              alpha: 0.3,
                                            )
                                          : context.borderColor,
                                    ),
                                  ),
                                  child: isAuthenticated
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.phone_in_talk,
                                              size: 14,
                                              color: context.successColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              widget.product.sellerPhone ?? "Contact Verified",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.chat_outlined,
                                              size: 14,
                                              color: context.successColor,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              "Available for Chat",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      : GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (context) =>
                                                  const AuthBottomSheet(),
                                            );
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.lock_outline,
                                                size: 14,
                                                color: context.greyText,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                "Sign in to contact seller",
                                                style: TextStyle(
                                                  color: context.primaryColor,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Device Specifications
                      Text(
                        "Device Specifications",
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildSpecRow(
                              context,
                              "Category",
                              widget.product.category.displayName,
                            ),
                            _buildSpecRow(context, "Brand", widget.product.brand),
                            _buildSpecRow(context, "Model", widget.product.model),
                            if (widget.product.hasStorage)
                              _buildSpecRow(
                                context,
                                "Storage",
                                widget.product.storage!,
                              ),
                            if (widget.product.hasRam)
                              _buildSpecRow(context, "RAM", widget.product.ram!),
                            if (widget.product.processor != null &&
                                widget.product.processor!.isNotEmpty)
                              _buildSpecRow(
                                context,
                                "Processor",
                                widget.product.processor!,
                              ),
                            _buildSpecRow(
                              context,
                              "Condition",
                              widget.product.condition.displayName,
                            ),
                            _buildSpecRow(
                              context,
                              "Location",
                              _getDisplayLocation(),
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      Text(
                        "Similar Devices in ${_getDisplayLocation()}",
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      const SizedBox(height: 10),
                      BlocProvider(
                        create: (context) => ProductBloc(
                          productRepository: sl<ProductRepository>(),
                        )..add(GetProductsEvent(location: widget.product.location)),
                        child: BlocBuilder<ProductBloc, ProductState>(
                          builder: (context, state) {
                            if (state is ProductLoading) {
                              return const SizedBox(
                                height: 280,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            } else if (state is ProductError) {
                              return SizedBox(
                                height: 180,
                                child: ErrorDisplay(
                                  isCompact: true,
                                  onRetry: () {
                                    context.read<ProductBloc>().add(
                                          GetProductsEvent(
                                            location: widget.product.location,
                                          ),
                                        );
                                  },
                                ),
                              );
                            } else if (state is ProductsLoaded) {
                              final similarProducts = state.products
                                  .where((p) => p.id != widget.product.id)
                                  .toList();

                              if (similarProducts.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return SizedBox(
                                height: 280,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: similarProducts.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 12.0),
                                      child: SizedBox(
                                        width: 170,
                                        child: ProductCard(
                                          product: similarProducts[index],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBackground,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isAuthenticated = state is AuthSuccess;

                  return Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: OutlinedButton(
                          onPressed: () {
                            if (isAuthenticated) {
                              final authState = state as AuthSuccess;
                              if (authState.user.id == widget.product.sellerId) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("You cannot chat with yourself")),
                                );
                                return;
                              }
                              
                              final chatBloc = context.read<ChatBloc>();
                              final existingConv = chatBloc.getConversationWithUser(widget.product.sellerId, widget.product.id);
                              
                              final conv = existingConv ?? ConversationEntity(
                                id: "new_${widget.product.sellerId}_${widget.product.id}",
                                otherUserId: widget.product.sellerId,
                                otherUserName: widget.product.sellerName,
                                otherUserAvatar: widget.product.sellerProfileImage ?? "",
                                otherUserIsVerified: widget.product.isSellerVerified,
                                productId: widget.product.id,
                                productTitle: widget.product.title,
                                productImage: ApiEndpoints.resolveImageUrl(widget.product.coverImage),
                                productPrice: widget.product.price,
                                lastMessage: "",
                                lastMessageTime: DateTime.now(),
                                hasUnread: false,
                                unreadCount: 0,
                              );

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InboxChatPage(conversation: conv),
                                ),
                              ).then((_) {
                                if (context.mounted) {
                                  chatBloc.add(GetConversationsEvent());
                                }
                              });
                            } else {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => const AuthBottomSheet(),
                              );
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: context.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Icon(
                            Icons.chat_bubble_outline,
                            color: context.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: ElevatedButton(
                          onPressed: () {
                            if (isAuthenticated) {
                              _handleAction(context, "Buy Now");
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
                            backgroundColor: isAuthenticated
                                ? context.secondaryColor
                                : context.greyText,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            isAuthenticated ? "Buy Now" : "Sign in to Buy",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBtn(
    BuildContext context,
    IconData icon,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: context.cardBackground.withValues(alpha: 0.9),
        child: Icon(icon, color: iconColor ?? context.darkText, size: 20),
      ),
    );
  }

  Widget _buildTag(
    BuildContext context,
    String text,
    Color bg,
    Color txtColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: txtColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSpecRow(
    BuildContext context,
    String key,
    String value, {
    bool isLast = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: context.borderColor)),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: context.textTheme.bodyMedium),
          Text(
            value,
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
