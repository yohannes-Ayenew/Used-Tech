// lib/features/profile/presentation/pages/authenticated_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/core/constants/api_endpoints.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/features/profile/presentation/widgets/verification_badge.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'verification_page.dart';
import 'settings_page.dart';
import 'my_listings_page.dart';

class AuthenticatedProfilePage extends StatelessWidget {
  const AuthenticatedProfilePage({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout", style: context.textTheme.titleLarge),
        content: Text(
          "Are you sure you want to logout?",
          style: context.textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.greyText,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequestedEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Logged out successfully"),
                  backgroundColor: context.successColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(
              "Logout",
              style: context.textTheme.bodyLarge?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatWalletBalance(double balance) {
    return balance
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Profile", style: context.textTheme.titleLarge),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthSuccess) {
            return Center(
              child: Text(
                "User not authenticated",
                style: context.textTheme.bodyLarge,
              ),
            );
          }

          final user = state.user;
          final initials = _getInitials(user.name);
          final formattedBalance = _formatWalletBalance(user.walletBalance);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.primaryColor.withValues(
                                alpha: 0.1,
                              ),
                            ),
                            child: user.profileImage != null && user.profileImage!.isNotEmpty
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                      imageUrl: ApiEndpoints.resolveImageUrl(user.profileImage!),
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 70,
                                      placeholder: (context, url) => const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) => Center(
                                        child: Text(
                                          initials,
                                          style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: context.primaryColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: context.primaryColor,
                                      ),
                                    ),
                                  ),
                          ),
                            if (user.isVerifiedSeller)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: VerificationBadge(
                                isVerified: true,
                                size: 24,  
                                color: user.kycStatus.color,  
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: context.textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: context.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.kycStatus.color.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: user.kycStatus.color.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    user.kycStatus.icon,
                                    size: 14,
                                    color: user.kycStatus.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    user.kycStatus.displayName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: user.kycStatus.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Stats Cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formattedBalance,
                                style: context.textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "ETB Available",
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: context.lightGrey,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "3",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Active Orders",
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Menu Items
                _buildMenuItem(
                  context,
                  icon: Icons.inventory,
                  title: "My Listings",
                  subtitle: "Manage your active & sold items",
                  showViewAll: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MyListingsPage()),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.shopping_bag,
                  title: "Orders",
                  subtitle: "Buying & Selling",
                  onTap: () => Navigator.pushNamed(context, '/active-orders'),
                ),


                _buildMenuItem(
                  context,
                  icon: Icons.account_balance_wallet,
                  title: "Wallet",
                  subtitle: "Available: $formattedBalance ETB",
                  onTap: () => _showComingSoon(context, "Wallet"),
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.verified,
                  title: "Verification Status",
                  subtitle: user.kycStatus.displayName,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: user.kycStatus.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          user.kycStatus.icon,
                          size: 14,
                          color: user.kycStatus.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Completed ✓",
                          style: TextStyle(
                            fontSize: 12,
                            color: user.kycStatus.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VerificationPage(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.settings,
                  title: "Settings",
                  subtitle: "App preferences and account",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),

                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: "Logout",
                  subtitle: "Sign out of your account",
                  isLogout: true,
                  onTap: () => _showLogoutDialog(context),
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showViewAll = false,
    bool isLogout = false,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isLogout
                    ? Colors.red.withValues(alpha: 0.1)
                    : context.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isLogout ? Colors.red : context.greyText,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      color: isLogout ? Colors.red : context.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: isLogout
                          ? Colors.red.withValues(alpha: 0.7)
                          : context.greyText,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing
            else if (showViewAll)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "View All",
                  style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else if (!isLogout)
              Icon(Icons.arrow_forward_ios, size: 14, color: context.greyText),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$feature page coming soon"),
        backgroundColor: context.primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
