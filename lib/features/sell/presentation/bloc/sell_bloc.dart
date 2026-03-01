// lib/features/sell/presentation/bloc/sell_bloc.dart

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:used_tech_client/features/product/domain/usecases/create_product.dart';

// --- EVENTS ---
abstract class SellEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class UpdateSellDataEvent extends SellEvent {
  final Map<String, dynamic> data;
  UpdateSellDataEvent(this.data);
}

class AddImagesEvent extends SellEvent {
  final List<File> images;
  AddImagesEvent(this.images);
}

class SubmitListingEvent extends SellEvent {}

// --- STATES ---
abstract class SellState extends Equatable {
  @override
  List<Object> get props => [];
}

class SellInitial extends SellState {}

class SellLoading extends SellState {}

class SellSuccess extends SellState {}

class SellFailure extends SellState {
  final String message;
  SellFailure(this.message);
}

// --- BLOC ---
class SellBloc extends Bloc<SellEvent, SellState> {
  final CreateProduct createProductUseCase; // ✅ Use Domain UseCase

  // Draft Data
  final Map<String, dynamic> _listingData = {};
  List<File> _images = [];

  SellBloc({
    required this.createProductUseCase,
  }) : super(SellInitial()) {
    on<UpdateSellDataEvent>(_onUpdateData);
    on<AddImagesEvent>(_onAddImages);
    on<SubmitListingEvent>(_onSubmit);
  }

  void _onUpdateData(UpdateSellDataEvent event, Emitter<SellState> emit) {
    _listingData.addAll(event.data);
    print("📦 Updated Draft Data: $_listingData");
  }

  void _onAddImages(AddImagesEvent event, Emitter<SellState> emit) {
    _images = event.images;
    print("📸 Images Updated: ${_images.length}");
  }

  Future<void> _onSubmit(
    SubmitListingEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading());

    if (_images.length < 3) {
      emit(SellFailure("Please upload at least 3 images"));
      return;
    }

    // 🚀 Auto-generate Title if missing
    if (_listingData['title'] == null || _listingData['title'].toString().isEmpty) {
      final brand = _listingData['brand'] ?? '';
      final model = _listingData['model'] ?? '';
      _listingData['title'] = "$brand $model".trim();
    }

    print("🚀 Submitting Product: ${_listingData['title']}");

    final result = await createProductUseCase(
      productData: _listingData,
      images: _images,
    );

    result.fold(
      (failure) {
        print("❌ Submission Failed: ${failure.message}");
        emit(SellFailure(failure.message));
      },
      (_) {
        print("✅ Submission Successful");
        _listingData.clear();
        _images = [];
        emit(SellSuccess());
      },
    );
  }
}
