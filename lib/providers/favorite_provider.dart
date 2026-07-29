import 'package:flutter/material.dart';
import '../models/movie_model.dart'; // Import your model
import '../services/favorite_service.dart';

class FavoriteProvider extends ChangeNotifier {
  FavoriteService _service = FavoriteService();
  List<Movie> _favorites = [];
  bool _isLoading = false;

  List<Movie> get favorites => _favorites;
  bool get isLoading => _isLoading;

  // Method to inject the service if custom instance needed
  void setService(FavoriteService service) {
    _service = service;
  }

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _service.getFavorites();
      final List data = response['data'] is List ? response['data'] : [];
      _favorites = data.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Checks if a movie is favorited.
  /// This method forwards to the existing `isFavorited` method for backward compatibility.
  bool isFavorite(dynamic movieId) {
    return isFavorited(movieId);
  }

  bool isFavorited(dynamic movieId) {
    if (movieId == null) return false;
    return _favorites.any((movie) => movie.id.toString() == movieId.toString());
  }

  Future<void> toggleFavorite(Movie movie) async {
    final dynamic movieId = movie.id;
    final bool exists = isFavorited(movieId);

    if (exists) {
      _favorites.removeWhere((m) => m.id.toString() == movieId.toString());
      notifyListeners();
      try {
        await _service.removeFromFavorites(movieId);
      } catch (e) {
        _favorites.add(movie);
        notifyListeners();
      }
    } else {
      _favorites.insert(0, movie);
      notifyListeners();
      try {
        await _service.addToFavorites(movieId);
      } catch (e) {
        _favorites.removeWhere((m) => m.id.toString() == movieId.toString());
        notifyListeners();
      }
    }
  }
}