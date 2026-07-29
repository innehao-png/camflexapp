import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/category_model.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';
import '../../widgets/app_header.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/state_widgets.dart';
import '../movie_detail_screen.dart';
import '../subscription/subscription_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Category> _categories = [];
  List<Movie> _movies = [];
  List<Movie> _featuredMovies = [];
  String? _selectedCategory;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        MovieService.getCategories(),
        MovieService.getMovies(category: _selectedCategory),
      ]);

      _categories = results[0] as List<Category>;
      final paginatedMovies = results[1] as PaginatedMovies;
      _movies = paginatedMovies.movies;
      _featuredMovies = _movies.take(5).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onCategorySelected(String? slug) {
    setState(() => _selectedCategory = slug);
    _loadData();
  }

  void _openMovieDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategoryChanged: _onCategorySelected,
            ),
            Expanded(
              child: _isLoading
                  ? const AppLoading()
                  : _error != null
                      ? AppErrorState(message: _error!, onRetry: _loadData)
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          color: AppColors.primary,
                          backgroundColor: AppColors.background,
                          child: ListView(
                            padding: const EdgeInsets.only(bottom: 24),
                            children: [
                              HeroBanner(
                                featuredMovies: _featuredMovies,
                                onSubscribeTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SubscriptionScreen(),
                                    ),
                                  );
                                },
                                onMovieTap: _openMovieDetail,
                              ),
                              const SizedBox(height: 24),
                              _buildSectionHeader("មានតែលើ App", onSeeMoreTap: () {}),
                              const SizedBox(height: 12),
                              _buildHorizontalList(_movies),
                              const SizedBox(height: 24),
                              _buildSectionHeader("រឿងភាគ / Latest Movies", onSeeMoreTap: () {}),
                              const SizedBox(height: 12),
                              _buildHorizontalList(_movies.reversed.toList()),
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalList(List<Movie> movies) {
    if (movies.isEmpty) {
      return const AppEmptyState(message: "No movies available");
    }
    return SizedBox(
      height: 240,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return MovieCard(
            movie: movies[index],
            onTap: () => _openMovieDetail(movies[index]),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeMoreTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onSeeMoreTap,
            child: const Text(
              "មើលបន្ថែម",
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
