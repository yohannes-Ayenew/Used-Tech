// lib/features/product/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/common/widgets/auth_bottom_sheet.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_event.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_state.dart';
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
                Text(
                  "Bole",
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/search'),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryItem(context, Icons.phone_android, "Phones"),
                  _buildCategoryItem(context, Icons.laptop, "Laptops"),
                  _buildCategoryItem(context, Icons.tablet_android, "Tablets"),
                  _buildCategoryItem(context, Icons.gamepad, "Consoles"),
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

              // Fresh Recommendations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Fresh Recommendations",
                    style: context.textTheme.titleLarge,
                  ),
                  Icon(Icons.tune, color: context.greyText),
                ],
              ),
              const SizedBox(height: 15),

              // Product Grid
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductError) {
                    return Center(child: Text(state.message));
                  } else if (state is ProductsLoaded) {
                    final products = state.products;
                    if (products.isEmpty) {
                      return const Center(child: Text("No products found"));
                    }
                    return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: products.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        final imageUrl = product.images.isNotEmpty ? product.images.first : "https://images.unsplash.com/photo-1621330396173-e41b12717551?q=80&w=200";
                        return ProductCard(
                          image: imageUrl,
                          title: product.title,
                          price: product.price.toStringAsFixed(0),
                          condition: product.condition.toString().split('.').last,
                          location: product.location,
                          isVerified: product.isVerified,
                          isEscrow: product.isEscrow,
                        );
                      },
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
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
