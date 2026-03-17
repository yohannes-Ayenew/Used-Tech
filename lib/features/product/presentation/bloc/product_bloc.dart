// lib/features/product/presentation/bloc/product_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

export 'product_event.dart';
export 'product_state.dart';

// --- BLOC ---
class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetHomeDataEvent>(_onGetHomeData);
    on<GetProductDetailsEvent>(_onGetProductDetails);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateProductStatusEvent>(_onUpdateProductStatus);
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result = await productRepository.deleteProduct(event.productId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) {
        // After deleting, we might want to refresh the list or emit a specific state
        // For now, just a generic success state isn't defined, so we'll rely on the caller to refresh
      },
    );
  }

  Future<void> _onUpdateProductStatus(
    UpdateProductStatusEvent event,
    Emitter<ProductState> emit,
  ) async {
    final result =
        await productRepository.updateProductStatus(event.productId, event.status);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) {
        // Similar to delete, we expect the UI to refresh
      },
    );
  }

  Future<void> _onGetProductDetails(
    GetProductDetailsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await productRepository.getProductById(event.productId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
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
      status: event.status,
      limit: event.limit,
    );

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onGetHomeData(
    GetHomeDataEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());

    // Execute multiple repository calls in parallel for speed!
    final results = await Future.wait([
      productRepository.getProducts(location: event.location, status: 'ACTIVE', sort: 'trending', limit: 10), // Trending
      productRepository.getProducts(location: event.location, status: 'SOLD', sort: 'sold', limit: 10),       // Recently Sold
      productRepository.getProducts(location: event.location, status: 'ACTIVE', limit: 10),                   // Recommended (Generic active for now)
    ]);

    // Check if any failed
    for (final result in results) {
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        emit(ProductError(failure?.message ?? "Failed to load home data"));
        return;
      }
    }

    // Extract successful lists with explicit casting to avoid dynamic type errors
    final trending = results[0].fold((l) => <ProductEntity>[], (r) => r as List<ProductEntity>);
    final recentlySold = results[1].fold((l) => <ProductEntity>[], (r) => r as List<ProductEntity>);
    final recommended = results[2].fold((l) => <ProductEntity>[], (r) => r as List<ProductEntity>);

    emit(HomeDataLoaded(
      trending: trending,
      recentlySold: recentlySold,
      recommended: recommended,
    ));
  }
}
