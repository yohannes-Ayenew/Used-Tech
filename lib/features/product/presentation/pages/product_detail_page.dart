// lib/features/product/presentation/pages/product_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/global_variables.dart';
import '../../../../common/widgets/auth_bottom_sheet.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../widgets/product_card.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  void _handleAction(BuildContext context, String action) {
    final authState = context.read<AuthBloc>().state;

    if (authState is AuthSuccess) {
      // User is logged in - proceed with action
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("$action - Feature coming soon"),
          backgroundColor: GlobalVariables.primaryTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // User is guest - show auth bottom sheet
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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. IMAGE HEADER (With Back/Heart/Share buttons)
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
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: _buildCircleBtn(
                        Icons.arrow_back,
                        () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      right: 16,
                      child: Row(
                        children: [
                          _buildCircleBtn(Icons.favorite_border, () {
                            _handleAction(context, "Add to favorites");
                          }),
                          const SizedBox(width: 10),
                          _buildCircleBtn(Icons.share, () {
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
                      // 2. TITLE & PRICE
                      const Text(
                        "Samsung Galaxy S21",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(
                            "Good",
                            GlobalVariables.pillGreen,
                            GlobalVariables.pillText,
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const Text(
                            " Piazza",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "32,000 ETB",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: GlobalVariables.primaryTeal,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 3. ESCROW TRUST BANNER
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F7FA),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: GlobalVariables.primaryTeal.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: GlobalVariables.primaryTeal,
                              size: 30,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Escrow Protection",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    "Your payment is protected by escrow. Funds are released only after you confirm delivery.",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 4. SELLER INFO CARD
                      const Text(
                        "Seller Information",
                        style: GlobalVariables.headerStyle,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GlobalVariables.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    "D",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Dawit Alemayehu",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.check_circle,
                                          color: GlobalVariables.primaryTeal,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "⭐ 4.7 • 18 Transactions",
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    _handleAction(context, "View Profile");
                                  },
                                  child: const Text(
                                    "View Profile",
                                    style: TextStyle(
                                      color: GlobalVariables.primaryTeal,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Contact Info - Changes based on auth state
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
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isAuthenticated
                                          ? Colors.green.shade200
                                          : Colors.grey.shade300,
                                    ),
                                  ),
                                  child: isAuthenticated
                                      ? const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.phone_in_talk,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "09XXXXXXXX",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(width: 16),
                                            Icon(
                                              Icons.email_outlined,
                                              size: 14,
                                              color: Colors.green,
                                            ),
                                            SizedBox(width: 8),
                                            Text(
                                              "seller@email.com",
                                              style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.lock_outline,
                                              size: 14,
                                              color: Colors.grey,
                                            ),
                                            const SizedBox(width: 5),
                                            GestureDetector(
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
                                              child: const Text(
                                                "Sign in to view contact",
                                                style: TextStyle(
                                                  color: GlobalVariables
                                                      .primaryTeal,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  decoration:
                                                      TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 5. DEVICE SPECIFICATIONS
                      const Text(
                        "Device Specifications",
                        style: GlobalVariables.headerStyle,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: GlobalVariables.lightGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildSpecRow("Category", "Mobile"),
                            _buildSpecRow("Brand", "Samsung"),
                            _buildSpecRow("Model", "Galaxy S21"),
                            _buildSpecRow("Storage", "128GB"),
                            _buildSpecRow("RAM", "8GB"),
                            _buildSpecRow("Condition", "Good"),
                            _buildSpecRow("Location", "Piazza", isLast: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 6. SIMILAR DEVICES
                      const Text(
                        "Similar Devices in Piazza",
                        style: GlobalVariables.headerStyle,
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
                      const SizedBox(height: 20),

                      // 7. SAFETY REMINDER
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: const [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Safety Reminder",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.brown,
                                    ),
                                  ),
                                  Text(
                                    "Do not send money outside the app. Escrow protects you.",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.brown,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 8. STICKY BOTTOM BAR
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                      // Chat Button
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
                            side: const BorderSide(
                              color: GlobalVariables.primaryTeal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Icon(
                            Icons.chat_bubble_outline,
                            color: GlobalVariables.primaryTeal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Buy Button
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
                                ? GlobalVariables.secondaryOrange
                                : Colors.grey,
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

  Widget _buildCircleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white.withOpacity(0.9),
        child: Icon(icon, color: Colors.black87, size: 20),
      ),
    );
  }

  Widget _buildTag(String text, Color bg, Color txtColor) {
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

  Widget _buildSpecRow(String key, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
