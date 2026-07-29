import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/state_widgets.dart';
import '../movie_detail_screen.dart';

class ComingSoonTab extends StatefulWidget {
  const ComingSoonTab({super.key});

  @override
  State<ComingSoonTab> createState() => _ComingSoonTabState();
}

class _ComingSoonTabState extends State<ComingSoonTab> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchComingSoon();
  }

  Future<void> _fetchComingSoon() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await MovieService.getMovies(type: 'upcoming');
      if (mounted) {
        setState(() {
          _movies = result.movies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          "មកដល់ឆាប់ៗនេះ (Coming Soon)",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const AppLoading()
          : _error != null
              ? AppErrorState(message: _error!, onRetry: _fetchComingSoon)
              : _movies.isEmpty
                  ? const AppEmptyState(message: "No upcoming movies at the moment")
                  : RefreshIndicator(
                      onRefresh: _fetchComingSoon,
                      color: AppColors.primary,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(
                            movie: _movies[index],
                            width: double.infinity,
                            height: 220,
                            onTap: () => _openMovieDetail(_movies[index]),
                          );
                        },
                      ),
                    ),
    );
  }
}
