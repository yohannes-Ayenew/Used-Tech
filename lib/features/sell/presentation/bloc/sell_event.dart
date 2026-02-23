// lib/features/sell/presentation/bloc/sell_event.dart

import 'package:equatable/equatable.dart';
import 'dart:io';

abstract class SellEvent extends Equatable {
  const SellEvent();

  @override
  List<Object> get props => [];
}

class CreateListingEvent extends SellEvent {
  final String category;
  final String brand;
  final String model;
  final String condition;
  final String? storage;
  final String? ram;
  final String? processor;
  final int price;
  final String description;
  final List<File> images;

  const CreateListingEvent({
    required this.category,
    required this.brand,
    required this.model,
    required this.condition,
    this.storage,
    this.ram,
    this.processor,
    required this.price,
    required this.description,
    required this.images,
  });

  @override
  List<Object> get props => [
        category,
        brand,
        model,
        condition,
        if (storage != null) storage!,
        if (ram != null) ram!,
        if (processor != null) processor!,
        price,
        description,
        ...images,
      ];
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
