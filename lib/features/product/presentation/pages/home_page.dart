// lib/features/product/presentation/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/common/widgets/auth_bottom_sheet.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:used_tech_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:used_tech_client/features/product/domain/entities/product_entity.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_event.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_state.dart';
import 'product_detail_page.dart';
import '../widgets/product_card.dart';
import '../../../../common/widgets/error_display.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _subCities = [
    'Addis Ketema',
    'Akaky Kaliti',
    'Arada',
    'Bole',
    'Gullele',
    'Kirkos',
    'Kolfe Keranio',
    'Lideta',
    'Nifas Silk-Lafto',
    'Yeka',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch products when Home Page loads
    final authState = context.read<AuthBloc>().state;
    String? location;
    if (authState is AuthSuccess) {
      location = authState.user.location;
    }
    context.read<ProductBloc>().add(GetHomeDataEvent(location: location ?? "Addis Ababa"));
  }

  void _showLocationPicker(BuildContext context, String currentCity) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(color: context.cardBackground),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Select Sub-city",
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _subCities.length,
                  itemBuilder: (context, index) {
                    final city = _subCities[index];
                    final isSelected = city == currentCity;
                    return ListTile(
                      title: Text(
                        city,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: isSelected ? context.primaryColor : null,
                          fontWeight: isSelected ? FontWeight.bold : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: context.primaryColor)
                          : null,
                      onTap: () {
                        // 1. Update local location in AuthBloc
                        context.read<AuthBloc>().add(
                              UpdateLocalLocationEvent(location: city),
                            );
                        
                        // 2. Refresh home data for this location
                        context.read<ProductBloc>().add(
                              GetHomeDataEvent(location: city),
                            );

                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            final authState = context.read<AuthBloc>().state;
            final currentLocation = (authState is AuthSuccess)
                ? (authState.user.location ?? "Addis Ababa")
                : "Addis Ababa";
            _showLocationPicker(context, currentLocation);
          },
          behavior: HitTestBehavior.opaque,
          child: Row(
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
                      return Row(
                        children: [
                          Text(
                            location,
                            style: context.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: context.primaryColor,
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
            icon: Icon(
              Icons.favorite_border,
              color: context.greyText,
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Navigate to Notifications
            },
            icon: Icon(
              Icons.notifications_none_outlined,
              color: context.greyText,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final authState = context.read<AuthBloc>().state;
          String? location;
          if (authState is AuthSuccess) {
            location = authState.user.location;
          }
          context.read<ProductBloc>().add(GetHomeDataEvent(location: location ?? "Addis Ababa"));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Collections Search Bar
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/collections',
                  ),
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
                          "Explore Collections...",
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
                    _buildCategoryItem(
                      context,
                      Icons.phone_android,
                      "Phones",
                      () => Navigator.pushNamed(
                        context,
                        '/collections',
                        arguments: {'category': 'mobile'},
                      ),
                    ),
                    _buildCategoryItem(
                      context,
                      Icons.laptop,
                      "Laptops",
                      () => Navigator.pushNamed(
                        context,
                        '/collections',
                        arguments: {'category': 'laptop'},
                      ),
                    ),
                    _buildCategoryItem(
                      context,
                      Icons.tablet_android,
                      "Tablets",
                      () => Navigator.pushNamed(
                        context,
                        '/collections',
                        arguments: {'category': 'tablet'},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // Hero Banner
                BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    ProductEntity? matchingProduct;
                    if (state is HomeDataLoaded) {
                      try {
                        matchingProduct = state.trending.firstWhere(
                          (p) =>
                              p.title.toLowerCase().contains('iphone 13') ||
                              (p.brand.toLowerCase() == 'apple' &&
                                  p.model.toLowerCase().contains('13')),
                        );
                      } catch (_) {
                        matchingProduct = null;
                      }
                    }

                    return InkWell(
                      onTap: () {
                        if (matchingProduct != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(product: matchingProduct!),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            '/collections',
                            arguments: {'searchQuery': 'Apple iPhone 13'},
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: double.infinity,
                        height: 160,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              context.secondaryColor,
                              context.secondaryColor.withAlpha(204),
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
                                      color: Colors.white.withAlpha(76),
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
                                  Text(
                                    matchingProduct?.title ?? "iPhone 13 Pro",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    matchingProduct != null
                                        ? "${matchingProduct.condition.displayName} - Limited Deal"
                                        : "Refurbished - 10% Off",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    matchingProduct != null
                                        ? "${matchingProduct.formattedPrice} ETB"
                                        : "50,000 ETB",
                                    style: const TextStyle(
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
                    );
                  },
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
                        Navigator.pushNamed(context, '/collections');
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
                  height: 280,
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ProductError) {
                        return ErrorDisplay(
                          isCompact: true,
                          onRetry: () {
                            final authState = context.read<AuthBloc>().state;
                            String? location;
                            if (authState is AuthSuccess) {
                              location = authState.user.location;
                            }
                            context.read<ProductBloc>().add(
                              GetHomeDataEvent(location: location ?? "Addis Ababa"),
                            );
                          },
                        );
                      } else if (state is HomeDataLoaded) {
                        if (state.trending.isEmpty) {
                          return const Center(child: Text("No trending products today"));
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.trending.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            final product = state.trending[index];
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
                  height: 280,
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is HomeDataLoaded) {
                        final soldProducts = state.recentlySold;
                        if (soldProducts.isEmpty) {
                          return const Center(
                              child: Text(
                            "No recently sold products found in this area",
                            style: TextStyle(color: Colors.grey),
                          ));
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

                const SizedBox(height: 30),

                // Recommended Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recommended for You",
                      style: context.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Recommended List
                SizedBox(
                  height: 280,
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is HomeDataLoaded) {
                        final recommendedProducts = state.recommended;
                        if (recommendedProducts.isEmpty) {
                          return const Center(
                              child: Text(
                            "More recommendations coming soon!",
                            style: TextStyle(color: Colors.grey),
                          ));
                        }

                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: recommendedProducts.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 15),
                          itemBuilder: (context, index) {
                            final product = recommendedProducts[index];
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

                // Extra space at bottom
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: context.primaryColor.withAlpha(25),
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
      ),
    );
  }
}
