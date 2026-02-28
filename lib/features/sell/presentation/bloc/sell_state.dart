// lib/features/sell/presentation/bloc/sell_state.dart

import 'package:equatable/equatable.dart';
import '../../domain/entities/listing_entity.dart';
import '../../../product/domain/entities/product_entity.dart';

abstract class SellState extends Equatable {
  final Map<String, dynamic> draftData;

  const SellState({this.draftData = const {}});

  @override
  List<Object> get props => [draftData];
}

class SellInitial extends SellState {
  const SellInitial({super.draftData});
}

class SellDraftUpdated extends SellState {
  const SellDraftUpdated(Map<String, dynamic> draftData) : super(draftData: draftData);
}

class SellLoading extends SellState {
  const SellLoading(Map<String, dynamic> draftData) : super(draftData: draftData);
}

class ListingCreated extends SellState {
  final ProductEntity product;
  
  const ListingCreated(this.product, Map<String, dynamic> draftData) : super(draftData: draftData);

  @override
  List<Object> get props => [product, draftData];
}

class MyListingsLoaded extends SellState {
  final List<ListingEntity> listings;
  const MyListingsLoaded(this.listings, {super.draftData});

  @override
  List<Object> get props => [listings, draftData];
}

class ListingUpdated extends SellState {
  final ListingEntity listing;
  const ListingUpdated(this.listing, {super.draftData});

  @override
  List<Object> get props => [listing, draftData];
}

class ListingDeleted extends SellState {
  final String listingId;
  const ListingDeleted(this.listingId, {super.draftData});

  @override
  List<Object> get props => [listingId, draftData];
}

class SellError extends SellState {
  final String message;
  const SellError(this.message, Map<String, dynamic> draftData) : super(draftData: draftData);

  @override
  List<Object> get props => [message, draftData];
}
