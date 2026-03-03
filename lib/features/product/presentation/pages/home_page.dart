// lib/features/product/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/common/widgets/auth_bottom_sheet.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import '../widgets/product_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Fetch products when Home Page loads
    context.read<ProductBloc>().add(const GetProductsEvent());
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.location_on_outlined, size: 20, color: context.greyText),
            const SizedBox(width: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Delivering to", style: context.textTheme.bodySmall),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final location = (state is AuthSuccess)
                        ? (state.user.location ?? "Addis Ababa")
                        : "Addis Ababa";
                    return Text(
                      location,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.primaryColor.withValues(alpha: 0.1),
                    ),
                    child: Center(
                      child: Text(
                        _getInitials(state.user.name),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: context.primaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const AuthBottomSheet(),
                    );
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      color: context.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProductBloc>().add(const GetProductsEvent());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/search',
                  ), // Make sure this route exists in main.dart or use push
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: context.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Icon(Icons.search, color: context.greyText),
                        const SizedBox(width: 8),
                        Text(
                          "Search iPhone, Mac...",
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCategoryItem(context, Icons.phone_android, "Phones"),
                    _buildCategoryItem(context, Icons.laptop, "Laptops"),
                    _buildCategoryItem(
                      context,
                      Icons.tablet_android,
                      "Tablets",
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Hero Banner
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        context.secondaryColor,
                        context.secondaryColor.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 20,
                        top: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "DEAL OF THE DAY",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "iPhone 13 Pro",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Refurbished - 10% Off",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "50,000 ETB",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Trending Near You Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Trending Near You",
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            final location = (state is AuthSuccess)
                                ? (state.user.location ?? "Addis Ababa")
                                : "Addis Ababa";
                            return Text(
                              "Most viewed devices in $location",
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.greyText,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        // TODO: Navigate to All Products or Trending
                      },
                      child: Row(
                        children: [
                          Text(
                            "See All",
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 20,
                            color: context.greyText,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Trending Products Horizontal List
                SizedBox(
                  height: 250,
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ProductError) {
                        return Center(child: Text('Error: ${state.message}'));
                      } else if (state is ProductsLoaded) {
                        if (state.products.isEmpty) {
                          return const Center(child: Text("No products found"));
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.products.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            return SizedBox(
                              width: 160,
                              child: ProductCard(
                                product: product,
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Recently Sold Header
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final location = (state is AuthSuccess)
                        ? (state.user.location ?? "Addis Ababa")
                        : "Addis Ababa";
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Recently Sold in $location",
                          style: context.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 15),

                // Recently Sold Horizontal List
                SizedBox(
                  height: 250,
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductsLoaded) {
                        // For demo purposes, we'll just show the same products but marked as sold
                        // In a real app, this would be a separate BLoC event/state
                        final soldProducts =
                            state.products.reversed.take(5).toList();
                        if (soldProducts.isEmpty) {
                          return const Center(child: Text("No sold products"));
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: soldProducts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            final product = soldProducts[index];
                            return SizedBox(
                              width: 160,
                              child: ProductCard(
                                product: product,
                                isSold: true,
                              ),
                            );
                          },
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),

                // Extra space at bottom
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: context.primaryColor.withValues(alpha: 0.1),
          child: Icon(icon, color: context.primaryColor),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
