// lib/features/product/presentation/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/common/widgets/auth_bottom_sheet.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import '../widgets/product_card.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

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
                    Image.network(
                      "https://via.placeholder.com/400x300",
                      height: 300,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 300,
                          width: double.infinity,
                          color: context.lightGrey,
                          child: Icon(
                            Icons.image_not_supported,
                            color: context.greyText,
                          ),
                        );
                      },
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
                          _buildCircleBtn(context, Icons.favorite_border, () {
                            _handleAction(context, "Add to favorites");
                          }),
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
                        "Samsung Galaxy S21",
                        style: context.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(
                            context,
                            "Good",
                            context.pillGreen,
                            context.pillText,
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: context.greyText,
                          ),
                          Text(" Piazza", style: context.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text(
                        "32,000 ETB",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: context.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),

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
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: context.cardBackground,
                                  child: Text(
                                    "D",
                                    style: context.textTheme.titleMedium,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Dawit Alemayehu",
                                          style: context.textTheme.titleMedium,
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.check_circle,
                                          color: context.primaryColor,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "⭐ 4.7 • 18 Transactions",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: context.secondaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () =>
                                      _handleAction(context, "View Profile"),
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
                                              "09XXXXXXXX",
                                              style: TextStyle(
                                                color: context.successColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.email_outlined,
                                              size: 14,
                                              color: context.successColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              "seller@email.com",
                                              style: TextStyle(
                                                color: context.successColor,
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
                                                "Sign in to view contact",
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
                            _buildSpecRow(context, "Category", "Mobile"),
                            _buildSpecRow(context, "Brand", "Samsung"),
                            _buildSpecRow(context, "Model", "Galaxy S21"),
                            _buildSpecRow(context, "Storage", "128GB"),
                            _buildSpecRow(context, "RAM", "8GB"),
                            _buildSpecRow(context, "Condition", "Good"),
                            _buildSpecRow(
                              context,
                              "Location",
                              "Piazza",
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Similar Devices
                      Text(
                        "Similar Devices in Piazza",
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 240,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: SizedBox(
                                width: 160,
                                child: ProductCard(
                                  image: "https://via.placeholder.com/150",
                                  title: "iPhone 13 Pro",
                                  price: "50,000",
                                  condition: "Like New",
                                  location: "Bole",
                                  isVerified: true,
                                  isEscrow: true,
                                ),
                              ),
                            );
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
                              _handleAction(context, "Chat");
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
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: context.cardBackground.withValues(alpha: 0.9),
        child: Icon(icon, color: context.darkText, size: 20),
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
