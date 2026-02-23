// lib/features/product/presentation/bloc/product_event.dart

import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class GetProductsEvent extends ProductEvent {
  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
  final String? searchQuery;

  const GetProductsEvent({
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
    this.searchQuery,
  });

  @override
  List<Object> get props => [
        if (category != null) category!,
        if (brand != null) brand!,
        if (minPrice != null) minPrice!,
        if (maxPrice != null) maxPrice!,
        if (searchQuery != null) searchQuery!,
      ];
}

class GetProductDetailsEvent extends ProductEvent {
  final String productId;
  const GetProductDetailsEvent({required this.productId});

  @override
  List<Object> get props => [productId];
}

class GetRecommendedProductsEvent extends ProductEvent {
  final String? category;
  final String? location;
  const GetRecommendedProductsEvent({this.category, this.location});

  @override
  List<Object> get props => [
        if (category != null) category!,
        if (location != null) location!,
      ];
}

class SearchProductsEvent extends ProductEvent {
  final String query;
  const SearchProductsEvent({required this.query});

  @override
  List<Object> get props => [query];
}
