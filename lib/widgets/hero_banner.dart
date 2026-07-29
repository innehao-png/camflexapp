import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/movie_model.dart';

class HeroBanner extends StatefulWidget {
  final List<Movie> featuredMovies;
  final VoidCallback? onSubscribeTap;
  final Function(Movie movie)? onMovieTap;

  const HeroBanner({
    super.key,
    this.featuredMovies = const [],
    this.onSubscribeTap,
    this.onMovieTap,
  });

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banners = widget.featuredMovies.isNotEmpty
        ? widget.featuredMovies
        : List.generate(3, (i) => Movie(id: i, title: 'Featured Movie'));

    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final movie = banners[index];
              return GestureDetector(
                onTap: () => widget.onMovieTap?.call(movie),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    movie.bannerUrl != null || movie.posterUrl != null
                        ? Image.network(
                            (movie.bannerUrl ?? movie.posterUrl)!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.6),
                            Colors.black.withOpacity(0.95),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Content Overlay
          Positioned(
            bottom: 16,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ភ្ជាប់កញ្ចប់\nដើម្បីមើលរឿងដោយសេរី!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: widget.onSubscribeTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textPrimary,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 4,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "ភ្ជាប់កញ្ចប់ SASTRA ដើម្បីទស្សនា",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Pagination Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    banners.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: _currentIndex == index ? 8 : 6,
                      height: _currentIndex == index ? 8 : 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index ? Colors.white : Colors.white38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.cardBg,
      child: const Center(child: Icon(Icons.movie, size: 80, color: Colors.white24)),
    );
  }
}
