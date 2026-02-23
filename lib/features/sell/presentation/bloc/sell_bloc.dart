// lib/features/sell/presentation/bloc/sell_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'sell_event.dart';
import 'sell_state.dart';

class SellBloc extends Bloc<SellEvent, SellState> {
  SellBloc() : super(SellInitial()) {
    on<CreateListingEvent>(_onCreateListing);
    on<UpdateListingEvent>(_onUpdateListing);
    on<DeleteListingEvent>(_onDeleteListing);
    on<GetMyListingsEvent>(_onGetMyListings);
  }

  Future<void> _onCreateListing(
    CreateListingEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading());
    try {
      // TODO: Implement create listing
      // final listing = await sellRepository.createListing(
      //   category: event.category,
      //   brand: event.brand,
      //   model: event.model,
      //   condition: event.condition,
      //   storage: event.storage,
      //   ram: event.ram,
      //   processor: event.processor,
      //   price: event.price,
      //   description: event.description,
      //   images: event.images,
      // );
      // emit(ListingCreated(listing));
    } catch (e) {
      emit(SellError(e.toString()));
    }
  }

  Future<void> _onUpdateListing(
    UpdateListingEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading());
    try {
      // TODO: Implement update listing
      // final listing = await sellRepository.updateListing(
      //   listingId: event.listingId,
      //   updates: event.updates,
      // );
      // emit(ListingUpdated(listing));
    } catch (e) {
      emit(SellError(e.toString()));
    }
  }

  Future<void> _onDeleteListing(
    DeleteListingEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading());
    try {
      // TODO: Implement delete listing
      // await sellRepository.deleteListing(event.listingId);
      emit(ListingDeleted(event.listingId));
    } catch (e) {
      emit(SellError(e.toString()));
    }
  }

  Future<void> _onGetMyListings(
    GetMyListingsEvent event,
    Emitter<SellState> emit,
  ) async {
    emit(SellLoading());
    try {
      // TODO: Implement get my listings
      // final listings = await sellRepository.getMyListings();
      emit(const MyListingsLoaded([]));
    } catch (e) {
      emit(SellError(e.toString()));
    }
  }
}
