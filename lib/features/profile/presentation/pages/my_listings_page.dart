import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/global_variables.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/theme/theme_extensions.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../../product/domain/entities/product_entity.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  @override
  void initState() {
    super.initState();
    _fetchListings();
  }

  void _fetchListings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess) {
      context.read<ProductBloc>().add(GetProductsEvent(
            sellerId: authState.user.id,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: context.successColor),
            );
            _fetchListings(); // Refresh list on success
          } else if (state is ProductError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: BlocBuilder<ProductBloc, ProductState>(
          builder: (context, state) {
          List<ProductEntity> activeProducts = [];
          List<ProductEntity> soldProducts = [];
          int totalViews = 0;

          if (state is ProductsLoaded) {
            activeProducts = state.products.where((p) => p.status == 'ACTIVE').toList();
            soldProducts = state.products.where((p) => p.status == 'SOLD').toList();
          }

          return Column(
            children: [
              // --- 1. TOP TEAL HEADER & STATS ---
              Container(
                color: context.primaryColor,
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Bar Area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
                          ),
                        ),
                        const Text(
                          "My Listings",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 32),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard("Active", activeProducts.length.toString()),
                        _buildStatCard("Sold", soldProducts.length.toString()),
                        _buildStatCard("Total Views", totalViews.toString()),
                      ],
                    ),
                  ],
                ),
              ),

              // --- 2. MAIN SCROLLABLE BODY ---
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    _fetchListings();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ADD NEW LISTING BUTTON
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: context.secondaryColor.withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, '/sell');
                            },
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                            label: const Text(
                              "Add New Listing",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.secondaryColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        if (state is ProductLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (state is ProductError)
                          Center(child: Text(state.message, style: TextStyle(color: context.greyText)))
                        else ...[
                          // --- ACTIVE LISTINGS SECTION ---
                          Text(
                            "Active Listings",
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (activeProducts.isEmpty)
                            Text("No active listings", style: TextStyle(color: context.greyText))
                          else
                            ...activeProducts.map((product) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildActiveCard(product),
                                )),
                          const SizedBox(height: 25),

                          // --- SOLD SECTION ---
                          Text(
                            "Sold",
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          if (soldProducts.isEmpty)
                            Text("No sold items", style: TextStyle(color: context.greyText))
                          else
                            ...soldProducts.map((product) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: _buildSoldCard(product),
                                )),
                          const SizedBox(height: 25),

                          // --- OTHER SECTION ---
                          Text(
                            "Other",
                            style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text("No pending disputes", style: TextStyle(color: context.greyText)),
                          const SizedBox(height: 40),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
}

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildStatCard(String label, String count) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(ProductEntity product) {
    final imageUrl = product.images.isNotEmpty ? ApiEndpoints.resolveImageUrl(product.images[0]) : '';

    return Container(
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 70,
                    width: 70,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: context.lightGrey),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${product.price.toStringAsFixed(0)} ETB",
                        style: TextStyle(color: context.primaryColor, fontWeight: FontWeight.w900, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.visibility_outlined, size: 14, color: context.greyText),
                          const SizedBox(width: 4),
                          Text("0 views", style: TextStyle(color: context.greyText, fontSize: 11)),
                          const SizedBox(width: 10),
                          Text("Posted", style: TextStyle(color: context.greyText, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.successColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline, color: context.successColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        "Active",
                        style: TextStyle(color: context.successColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.borderColor),
          IntrinsicHeight(
            child: Row(
              children: [
                _buildActionButton(Icons.edit_outlined, "Edit", Colors.blue, () async {
                  final result = await Navigator.pushNamed(
                    context,
                    '/edit-product',
                    arguments: product,
                  );
                  if (result == true) {
                    _fetchListings(); // Refresh on success
                  }
                }),
                VerticalDivider(width: 1, color: context.borderColor),
                _buildActionButton(Icons.check_circle_outline, "Sold", context.successColor, () {
                  context.read<ProductBloc>().add(UpdateProductStatusEvent(
                        productId: product.id,
                        status: 'SOLD',
                      ));
                }),
                VerticalDivider(width: 1, color: context.borderColor),
                _buildActionButton(Icons.delete_outline, "Delete", Colors.red, () {
                  _showDeleteConfirmDialog(product);
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSoldCard(ProductEntity product) {
    final imageUrl = product.images.isNotEmpty ? ApiEndpoints.resolveImageUrl(product.images[0]) : '';

    return Opacity(
      opacity: 0.7,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 70,
                width: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: context.lightGrey),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${product.price.toStringAsFixed(0)} ETB",
                    style: TextStyle(color: context.greyText, fontWeight: FontWeight.w900, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 14, color: context.greyText),
                      const SizedBox(width: 4),
                      Text("0 views", style: TextStyle(color: context.greyText, fontSize: 11)),
                      const SizedBox(width: 10),
                      Text("Sold", style: TextStyle(color: context.greyText, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: const [
                  Icon(Icons.check_circle_outline, color: Colors.blue, size: 12),
                  SizedBox(width: 4),
                  Text("Sold", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Listing"),
        content: Text("Are you sure you want to delete '${product.title}'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              context.read<ProductBloc>().add(DeleteProductEvent(productId: product.id));
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
