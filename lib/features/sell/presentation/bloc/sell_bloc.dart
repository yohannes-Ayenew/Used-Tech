// lib/features/sell/presentation/bloc/sell_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../product/domain/usecases/create_product.dart';
import 'sell_event.dart';
import 'sell_state.dart';

class SellBloc extends Bloc<SellEvent, SellState> {
  final CreateProduct createProduct;

  SellBloc({required this.createProduct}) : super(const SellInitial()) {
    on<CacheDraftListingEvent>(_onCacheDraftListing);
    on<SubmitListingEvent>(_onSubmitListing);
    on<UpdateListingEvent>(_onUpdateListing);
    on<DeleteListingEvent>(_onDeleteListing);
    on<GetMyListingsEvent>(_onGetMyListings);
  }

  void _onCacheDraftListing(
    CacheDraftListingEvent event,
    Emitter<SellState> emit,
  ) {
    final updatedData = Map<String, dynamic>.from(state.draftData)
      ..addAll(event.draftData);
    emit(SellDraftUpdated(updatedData));
  }

  Future<void> _onSubmitListing(
    SubmitListingEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading(state.draftData));
    
    try {
      final draft = state.draftData;
      
      // Extract XFile list
      final List<XFile> images = List<XFile>.from(draft['images'] ?? []);
      
      final params = CreateProductParams(
        category: draft['category'] ?? '',
        brand: draft['brand'] ?? '',
        model: draft['model'] ?? '',
        condition: draft['condition'] ?? '',
        title: "${draft['brand']} ${draft['model']}", 
        description: draft['description'] ?? '',
        price: draft['price'] is String ? double.tryParse(draft['price']) ?? 0.0 : (draft['price'] ?? 0.0),
        location: 'Not specified', // Temporarily hardcoded until location is added to UI
        storage: draft['storage'],
        ram: draft['ram'],
        processor: draft['processor'],
        images: images,
      );

      final result = await createProduct(params);

      result.fold(
        (failure) => emit(SellError(failure.message, state.draftData)),
        (product) {
          // Clear draft data upon successful creation
          emit(ListingCreated(product, const {}));
        },
      );
    } catch (e) {
      emit(SellError(e.toString(), state.draftData));
    }
  }

  Future<void> _onUpdateListing(
    UpdateListingEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading(state.draftData));
    try {
      // TODO: Implement update listing
    } catch (e) {
      emit(SellError(e.toString(), state.draftData));
    }
  }

  Future<void> _onDeleteListing(
    DeleteListingEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading(state.draftData));
    try {
      // TODO: Implement delete listing
      emit(ListingDeleted(event.listingId, draftData: state.draftData));
    } catch (e) {
      emit(SellError(e.toString(), state.draftData));
    }
  }

  Future<void> _onGetMyListings(
    GetMyListingsEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading(state.draftData));
    try {
      // TODO: Implement get my listings
      emit(MyListingsLoaded(const [], draftData: state.draftData));
    } catch (e) {
      emit(SellError(e.toString(), state.draftData));
    }
  }
}
