// lib/features/product/presentation/bloc/product_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';

import '../../domain/repositories/product_repository.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(ProductInitial()) {
    on<GetProductsEvent>(_onGetProducts);
    on<GetProductDetailsEvent>(_onGetProductDetails);
    on<GetRecommendedProductsEvent>(_onGetRecommendedProducts);
    on<SearchProductsEvent>(_onSearchProducts);
    on<CreateProductEvent>(_onCreateProduct);
  }

  Future<void> _onGetProducts(
    GetProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    final result = await productRepository.getProducts();

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (products) {
        // Here we could add logic to filter products if filters are provided in the event
        var filteredProducts = products;
        if (event.category != null) {
          filteredProducts = filteredProducts.where((p) => p.category.toString().split('.').last.toLowerCase() == event.category!.toLowerCase()).toList();
        }
        if (event.brand != null) {
          filteredProducts = filteredProducts.where((p) => p.brand.toLowerCase() == event.brand!.toLowerCase()).toList();
        }
        if (event.minPrice != null) {
          filteredProducts = filteredProducts.where((p) => p.price >= event.minPrice!).toList();
        }
        if (event.maxPrice != null) {
          filteredProducts = filteredProducts.where((p) => p.price <= event.maxPrice!).toList();
        }
        
        emit(ProductsLoaded(filteredProducts));
      },
    );
  }

  Future<void> _onGetProductDetails(
    GetProductDetailsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      // TODO: Implement get product details
      // final product = await productRepository.getProductById(event.productId);
      // emit(ProductDetailsLoaded(product));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onGetRecommendedProducts(
    GetRecommendedProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      // TODO: Implement get recommended products
      // final products = await productRepository.getRecommendedProducts(
      //   category: event.category,
      //   location: event.location,
      // );
      emit(const RecommendedProductsLoaded([]));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductLoading());
    try {
      // TODO: Implement search products
      // final results = await productRepository.searchProducts(event.query);
      emit(SearchResultsLoaded([], event.query));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductCreating());
    final result = await productRepository.createProduct(
      category: event.category,
      brand: event.brand,
      model: event.model,
      condition: event.condition,
      title: event.title,
      description: event.description,
      price: event.price,
      location: event.location,
      images: event.images,
      storage: event.storage,
      ram: event.ram,
      processor: event.processor,
    );

    result.fold(
      (failure) => emit(ProductError(failure.message)),
      (product) => emit(ProductCreated(product)),
    );
  }
}
