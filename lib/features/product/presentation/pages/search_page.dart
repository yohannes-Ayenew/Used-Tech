// lib/features/product/presentation/pages/search_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_event.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_state.dart';
import '../widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Newest';
  bool _isGridView = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(const GetProductsEvent());
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {}); // Trigger rebuild to filter products
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Search Electronics", style: context.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: context.lightGrey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Search by brand, model...",
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: context.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    onPressed: _showFilterBottomSheet,
                    icon: const Icon(Icons.tune, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductError) {
            return Center(child: Text(state.message));
          } else if (state is ProductsLoaded) {
            final query = _searchController.text.toLowerCase();
            var filteredList = state.products;

            if (query.isNotEmpty) {
              filteredList = filteredList.where((product) {
                return product.title.toLowerCase().contains(query) ||
                        product.condition.toString().toLowerCase().contains(query);
              }).toList();
            }

            return Column(
              children: [
                // Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${filteredList.length} results",
                        style: context.textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: context.borderColor),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  _selectedFilter,
                                  style: context.textTheme.bodySmall,
                                ),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 16,
                                  color: context.greyText,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          _buildViewToggle(context),
                        ],
                      ),
                    ],
                  ),
                ),

                // Results
                Expanded(
                  child: filteredList.isEmpty
                      ? _buildEmptyState(context)
                      : (_isGridView
                          ? _buildGridView(filteredList)
                          : _buildListView(filteredList)),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.borderColor),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => setState(() => _isGridView = true),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _isGridView ? context.primaryColor : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
              child: Icon(
                Icons.grid_view,
                color: _isGridView ? Colors.white : context.greyText,
                size: 18,
              ),
            ),
          ),
          Container(width: 1, height: 30, color: context.borderColor),
          GestureDetector(
            onTap: () => setState(() => _isGridView = false),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: !_isGridView ? context.primaryColor : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
              ),
              child: Icon(
                Icons.list,
                color: !_isGridView ? Colors.white : context.greyText,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView(List products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
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

  Widget _buildListView(List products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final imageUrl = product.images.isNotEmpty ? product.images.first : "https://images.unsplash.com/photo-1621330396173-e41b12717551?q=80&w=200";
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            image: imageUrl,
            title: product.title,
            price: product.price.toStringAsFixed(0),
            condition: product.condition.toString().split('.').last,
            location: product.location,
            isVerified: product.isVerified,
            isEscrow: product.isEscrow,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: context.greyText),
          const SizedBox(height: 16),
          Text('No products found', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: context.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Sort By', style: context.textTheme.titleLarge),
            const SizedBox(height: 20),
            ...[
              'Newest',
              'Price: Low to High',
              'Price: High to Low',
              'Most Popular',
            ].map((option) => _buildFilterOption(option)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String option) {
    return ListTile(
      title: Text(option),
      leading: Radio<String>(
        value: option,
        groupValue: _selectedFilter,
        activeColor: context.primaryColor,
        onChanged: (value) {
          setState(() => _selectedFilter = value!);
          Navigator.pop(context);
        },
      ),
    );
  }
}
