import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/movie_service.dart';

class MovieDetailProvider extends ChangeNotifier {
  Movie? _movie;
  List<Movie> _relatedMovies = [];
  bool _isLoading = false;
  String? _error;
  int _selectedTabIndex = 0; // 0: Similar, 1: Others

  Movie? get movie => _movie;
  List<Movie> get relatedMovies => _relatedMovies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedTabIndex => _selectedTabIndex;

  void setSelectedTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  void initializeWithMovie(Movie movie) {
    _movie = movie;
    _error = null;
    fetchRelated();
    if (_movie!.episodes.isEmpty) {
      fetchFullDetails(_movie!.id);
    } else {
      notifyListeners();
    }
  }

  Future<void> fetchFullDetails(dynamic param) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final details = await MovieService.getMovieDetails(param);
      _movie = details;
      _isLoading = false;
      notifyListeners();
      fetchRelated();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchRelated() async {
    if (_movie == null) return;
    try {
      final categorySlug = _movie!.categories.isNotEmpty
          ? _movie!.categories.first.slug
          : null;
      final paginated = await MovieService.getMovies(category: categorySlug);
      _relatedMovies = paginated.movies
          .where((m) => m.id.toString() != _movie?.id.toString())
          .toList();
      notifyListeners();
    } catch (_) {}
  }
}
