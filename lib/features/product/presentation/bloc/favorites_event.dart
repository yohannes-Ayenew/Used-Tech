import 'package:equatable/equatable.dart';
import '../../domain/entities/product_entity.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavorite extends FavoritesEvent {
  final ProductEntity product;

  const ToggleFavorite(this.product);

  @override
  List<Object?> get props => [product];
}
