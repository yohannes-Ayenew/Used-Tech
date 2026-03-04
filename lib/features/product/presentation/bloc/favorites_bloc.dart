import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';
import '../../domain/entities/product_entity.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final List<ProductEntity> _favorites = [];

  FavoritesBloc() : super(FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  void _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) {
    emit(FavoritesLoading());
    // In a real app, this might fetch from local storage or API
    emit(FavoritesLoaded(List.from(_favorites)));
  }

  void _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) {
    final product = event.product;
    final isFavorite = _favorites.any((p) => p.id == product.id);

    if (isFavorite) {
      _favorites.removeWhere((p) => p.id == product.id);
    } else {
      _favorites.add(product);
    }

    emit(FavoritesLoaded(List.from(_favorites)));
  }
}
