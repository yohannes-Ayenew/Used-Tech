// lib/features/sell/presentation/bloc/sell_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';

abstract class SellState extends Equatable {
  const SellState();

  @override
  List<Object> get props => [];
}

class SellInitial extends SellState {}

class SellLoading extends SellState {}

class ListingCreated extends SellState {
  final ListingEntity listing;
  const ListingCreated(this.listing);

  @override
  List<Object> get props => [listing];
}

class MyListingsLoaded extends SellState {
  final List<ListingEntity> listings;
  const MyListingsLoaded(this.listings);

  @override
  List<Object> get props => [listings];
}

class ListingUpdated extends SellState {
  final ListingEntity listing;
  const ListingUpdated(this.listing);

  @override
  List<Object> get props => [listing];
}

class ListingDeleted extends SellState {
  final String listingId;
  const ListingDeleted(this.listingId);

  @override
  List<Object> get props => [listingId];
}

class SellError extends SellState {
  final String message;
  const SellError(this.message);

  @override
  List<Object> get props => [message];
}
