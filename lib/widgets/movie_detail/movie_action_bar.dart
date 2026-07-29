import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/movie_model.dart';
import '../../providers/favorite_provider.dart';

class MovieActionBar extends StatelessWidget {
  final Movie movie;
  final VoidCallback onPlayTrailer;
  final VoidCallback onOpenExternalYoutube;

  const MovieActionBar({
    super.key,
    required this.movie,
    required this.onPlayTrailer,
    required this.onOpenExternalYoutube,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = context.watch<FavoriteProvider>();
    final isFavorite = favoriteProvider.isFavorite(movie.id);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onPlayTrailer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.play_arrow),
              label: const Text(
                "ទស្សនា Trailer",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: () => favoriteProvider.toggleFavorite(movie),
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.primary : Colors.white,
            ),
            tooltip: isFavorite ? 'Remove Favorite' : 'Add Favorite',
          ),
          if (movie.trailerUrl != null && movie.trailerUrl!.isNotEmpty)
            IconButton(
              onPressed: onOpenExternalYoutube,
              icon: const Icon(Icons.open_in_new, color: Colors.white),
              tooltip: 'Open in YouTube',
            ),
        ],
      ),
    );
  }
}
