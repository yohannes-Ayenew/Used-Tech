// lib/features/product/presentation/bloc/product_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// --- EVENTS ---
abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object> get props => [];
}

class GetProductsEvent extends ProductEvent {
  final String? category;
  final String? searchQuery;
  final String? location;
  final String? sellerId;

  const GetProductsEvent({
    this.category,
    this.searchQuery,
    this.location,
    this.sellerId,
  });

  @override
  List<Object> get props => [
        category ?? '',
        searchQuery ?? '',
        location ?? '',
        sellerId ?? '',
      ];
}

// --- STATES ---
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

class ProductError extends ProductState {
  final String message;
  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BLOC ---
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    final result = await productRepository.getProducts(
      category: event.category,
      searchQuery: event.searchQuery,
      location: event.location,
      sellerId: event.sellerId,
    );

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }
}
