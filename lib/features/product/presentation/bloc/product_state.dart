// lib/features/product/presentation/bloc/product_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  const ProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class HomeDataLoaded extends ProductState {
  final List<ProductEntity> trending;
  final List<ProductEntity> recentlySold;
  final List<ProductEntity> recommended;

  const HomeDataLoaded({
    required this.trending,
    required this.recentlySold,
    required this.recommended,
  });

  @override
  List<Object> get props => [trending, recentlySold, recommended];
}

class ProductDetailsLoaded extends ProductState {
  final ProductEntity product;
  const ProductDetailsLoaded(this.product);

  @override
  List<Object> get props => [product];
}

class RecommendedProductsLoaded extends ProductState {
  final List<ProductEntity> products;
  const RecommendedProductsLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class SearchResultsLoaded extends ProductState {
  final List<ProductEntity> results;
  final String query;
  const SearchResultsLoaded(this.results, this.query);

  @override
  List<Object> get props => [results, query];
}

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

class ProductCreating extends ProductState {}

class ProductCreated extends ProductState {
  final ProductEntity product;
  const ProductCreated(this.product);

  @override
  List<Object> get props => [product];
}

class ProductOperationSuccess extends ProductState {
  final String message;
  const ProductOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
