// lib/features/sell/presentation/bloc/sell_bloc.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:used_tech_client/features/product/domain/usecases/create_product.dart';
import 'package:used_tech_client/features/product/domain/usecases/update_product.dart';
import 'package:used_tech_client/features/product/domain/entities/product_entity.dart';

// --- EVENTS ---
abstract class SellEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateSellDataEvent extends SellEvent {
  final Map<String, dynamic> data;
  UpdateSellDataEvent(this.data);
  @override
  List<Object?> get props => [data];
}

class AddImagesEvent extends SellEvent {
  final List<File> images;
  AddImagesEvent(this.images);
  @override
  List<Object?> get props => [images];
}

class SubmitListingEvent extends SellEvent {}

class InitEditProductEvent extends SellEvent {
  final ProductEntity product;
  InitEditProductEvent(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateProductEvent extends SellEvent {}

// --- STATES ---
abstract class SellState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SellInitial extends SellState {}
class SellLoading extends SellState {}
class SellSuccess extends SellState {}
class SellFailure extends SellState {
  final String message;
  SellFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLOC ---
class SellBloc extends Bloc<SellEvent, SellState> {
  final CreateProduct createProductUseCase;
  final UpdateProduct updateProductUseCase;

  // Draft Data
  final Map<String, dynamic> _listingData = {};
  List<File> _images = [];
  String? _editingProductId;
  bool _isEditing = false;

  SellBloc({
    required this.createProductUseCase,
    required this.updateProductUseCase,
  }) : super(SellInitial()) {
    on<UpdateSellDataEvent>(_onUpdateData);
    on<AddImagesEvent>(_onAddImages);
    on<SubmitListingEvent>(_onSubmit);
    on<InitEditProductEvent>(_onInitEdit);
    on<UpdateProductEvent>(_onUpdateProduct);
  }

  void _onUpdateData(UpdateSellDataEvent event, Emitter<SellState> emit) {
    _listingData.addAll(event.data);
    print("📦 Updated Draft Data: $_listingData");
  }

  void _onAddImages(AddImagesEvent event, Emitter<SellState> emit) {
    _images = event.images;
    print("📸 Images Updated: ${_images.length}");
  }

  void _onInitEdit(InitEditProductEvent event, Emitter<SellState> emit) {
    _isEditing = true;
    _editingProductId = event.product.id;
    _listingData.clear();
    _listingData.addAll({
      'category': event.product.category.name,
      'brand': event.product.brand,
      'model': event.product.model,
      'condition': event.product.condition.name,
      'price': event.product.price,
      'description': event.product.description,
      'location': event.product.location,
      'specs': {
        'storage': event.product.storage,
        'ram': event.product.ram,
        'processor': event.product.processor,
      }
    });
    // Images are tricky as they are URLs now, not Files
    // For now, we assume editing focuses on textual data
    _images = []; 
    emit(SellInitial());
  }

  Future<void> _onSubmit(SubmitListingEvent event, Emitter<SellState> emit) async {
    emit(SellLoading());

    if (_images.length < 3) {
      emit(SellFailure("Please upload at least 3 images"));
      return;
    }

    if (_listingData['title'] == null || _listingData['title'].toString().isEmpty) {
      final brand = _listingData['brand'] ?? '';
      final model = _listingData['model'] ?? '';
      _listingData['title'] = "$brand $model".trim();
    }

    final result = await createProductUseCase(
      productData: _listingData,
      images: _images,
    );

    result.fold(
      (failure) => emit(SellFailure(failure.message)),
      (_) {
        _listingData.clear();
        _images = [];
        emit(SellSuccess());
      },
    );
  }

  Future<void> _onUpdateProduct(UpdateProductEvent event, Emitter<SellState> emit) async {
    if (!_isEditing || _editingProductId == null) return;
    
    emit(SellLoading());

    final result = await updateProductUseCase(
      _editingProductId!,
      _listingData,
      images: _images.isNotEmpty ? _images : null,
    );

    result.fold(
      (failure) => emit(SellFailure(failure.message)),
      (_) {
        _isEditing = false;
        _editingProductId = null;
        _listingData.clear();
        emit(SellSuccess());
      },
    );
  }
}
