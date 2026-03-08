// lib/features/product/presentation/pages/collections_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:used_tech_client/core/theme/theme_extensions.dart';
import 'package:used_tech_client/features/product/domain/entities/product_entity.dart';
import 'package:used_tech_client/features/product/presentation/bloc/product_bloc.dart';
import '../widgets/product_card.dart';
import '../../../../common/widgets/error_display.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Newest';
  bool _isGridView = true;

  String? _activeCategory;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    
    // Defer the event dispatch until after the first frame to allow context.read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        setState(() {
          _activeCategory = args['category'];
          if (args.containsKey('searchQuery')) {
            _searchController.text = args['searchQuery'];
          }
        });
        context.read<ProductBloc>().add(GetProductsEvent(
              category: _activeCategory,
              searchQuery: _searchController.text.isNotEmpty
                  ? _searchController.text
                  : null,
            ));
      } else {
        context.read<ProductBloc>().add(GetProductsEvent());
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Trigger UI rebuild to filter the list locally
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Explore Collections", style: context.textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_activeCategory != null ? 100 : 60),
          child: Column(
            children: [
              Padding(
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
                            hintText: "Find in collections...",
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
              if (_activeCategory != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: Row(
                    children: [
                      Chip(
                        label: Text(
                          "Category: ${_activeCategory![0].toUpperCase()}${_activeCategory!.substring(1)}",
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: context.primaryColor,
                        deleteIcon: const Icon(Icons.close, size: 14, color: Colors.white),
                        onDeleted: () {
                          setState(() {
                            _activeCategory = null;
                          });
                          context.read<ProductBloc>().add(GetProductsEvent());
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductError) {
            return ErrorDisplay(
              onRetry: () {
                context.read<ProductBloc>().add(GetProductsEvent());
              },
            );
          } else if (state is ProductsLoaded) {
            final query = _searchController.text.toLowerCase();

            // Client-side filtering logic
            final filteredList = state.products.where((product) {
              final titleMatch = product.title.toLowerCase().contains(query);
              final brandMatch = product.brand.toLowerCase().contains(query);
              final modelMatch = product.model.toLowerCase().contains(query);
              return titleMatch || brandMatch || modelMatch;
            }).toList();

            return Column(
              children: [
                // Filter Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10,
                  ),
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

                // Results List
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

  Widget _buildGridView(List<ProductEntity> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.55,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
        );
      },
    );
  }

  Widget _buildListView(List<ProductEntity> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: product,
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
          Icon(Icons.collections_bookmark_outlined, size: 64, color: context.greyText),
          const SizedBox(height: 16),
          Text('No collections found', style: context.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords to explore collections',
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
