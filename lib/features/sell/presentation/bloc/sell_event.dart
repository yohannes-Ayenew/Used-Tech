// lib/features/sell/presentation/bloc/sell_event.dart

import 'package:equatable/equatable.dart';

abstract class SellEvent extends Equatable {
  const SellEvent();

  @override
  List<Object> get props => [];
}

class CacheDraftListingEvent extends SellEvent {
  final Map<String, dynamic> draftData;

  const CacheDraftListingEvent(this.draftData);

  @override
  List<Object> get props => [draftData];
}

class SubmitListingEvent extends SellEvent {
  const SubmitListingEvent();
}

class UpdateListingEvent extends SellEvent {
  final String listingId;
  final Map<String, dynamic> updates;

  const UpdateListingEvent({required this.listingId, required this.updates});

  @override
  List<Object> get props => [listingId, updates];
}

class DeleteListingEvent extends SellEvent {
  final String listingId;
  const DeleteListingEvent({required this.listingId});

  @override
  List<Object> get props => [listingId];
}

class GetMyListingsEvent extends SellEvent {}
