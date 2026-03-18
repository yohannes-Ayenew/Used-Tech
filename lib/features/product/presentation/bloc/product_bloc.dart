// lib/features/product/presentation/bloc/product_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

export 'product_event.dart';
export 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;
  StreamSubscription? _repositorySubscription;

  // Track last events to allow refreshing
  GetProductsEvent? _lastGetProductsEvent;
  GetHomeDataEvent? _lastGetHomeDataEvent;
  GetProductDetailsEvent? _lastGetProductDetailsEvent;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetHomeDataEvent>(_onGetHomeData);
    on<GetProductDetailsEvent>(_onGetProductDetails);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<UpdateProductStatusEvent>(_onUpdateProductStatus);
    on<RefreshProducts>(_onRefresh);

    // 📡 Listen for global repository updates
    _repositorySubscription = productRepository.productUpdateStream.listen((_) {
      add(RefreshProducts());
    });
  }

  void _onRefresh(RefreshProducts event, Emitter<ProductState> emit) {
    if (_lastGetProductsEvent != null) {
      add(_lastGetProductsEvent!);
    } else if (_lastGetHomeDataEvent != null) {
      add(_lastGetHomeDataEvent!);
    } else if (_lastGetProductDetailsEvent != null) {
      add(_lastGetProductDetailsEvent!);
    }
  }

  Future<void> _onDeleteProduct(DeleteProductEvent event, Emitter<ProductState> emit) async {
    final result = await productRepository.deleteProduct(event.productId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess("Product deleted successfully")),
    );
  }

  Future<void> _onUpdateProductStatus(UpdateProductStatusEvent event, Emitter<ProductState> emit) async {
    final result = await productRepository.updateProductStatus(event.productId, event.status);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (_) => emit(const ProductOperationSuccess("Status updated successfully")),
    );
  }

  Future<void> _onGetProductDetails(GetProductDetailsEvent event, Emitter<ProductState> emit) async {
    _lastGetProductDetailsEvent = event;
    emit(ProductLoading());
    final result = await productRepository.getProductById(event.productId);
    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductDetailsLoaded(product)),
    );
  }

  Future<void> _onGetProducts(GetProductsEvent event, Emitter<ProductState> emit) async {
    _lastGetProductsEvent = event;
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

  Future<void> _onGetHomeData(GetHomeDataEvent event, Emitter<ProductState> emit) async {
    _lastGetHomeDataEvent = event;
    emit(ProductLoading());
    final results = await Future.wait([
      productRepository.getProducts(location: event.location, status: 'ACTIVE', sort: 'trending', limit: 10),
      productRepository.getProducts(location: event.location, status: 'SOLD', sort: 'sold', limit: 10),
      productRepository.getProducts(location: event.location, status: 'ACTIVE', limit: 10),
    ]);

    for (final result in results) {
      if (result.isLeft()) {
        final failure = result.fold((l) => l, (r) => null);
        emit(ProductError(failure?.message ?? "Failed to load home data"));
        return;
      }
    }

    final trending = results[0].getOrElse(() => []);
    final recentlySold = results[1].getOrElse(() => []);
    final recommended = results[2].getOrElse(() => []);

    emit(HomeDataLoaded(
      trending: trending,
      recentlySold: recentlySold,
      recommended: recommended,
    ));
  }

  @override
  Future<void> close() {
    _repositorySubscription?.cancel();
    return super.close();
  }
}
