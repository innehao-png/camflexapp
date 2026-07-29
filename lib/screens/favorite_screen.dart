import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/movie_model.dart';
import '../providers/favorite_provider.dart';
import '../widgets/state_widgets.dart';
import 'movie_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoriteProvider>().fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "រឿងដែលពេញចិត្ត (Favorites)",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Consumer<FavoriteProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.favorites.isEmpty) {
            return const AppLoading();
          }

          if (provider.favorites.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => provider.fetchFavorites(),
              color: AppColors.primary,
              child: ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.white24),
                        SizedBox(height: 16),
                        Text(
                          "មិនទាន់មានរឿងក្នុងបញ្ជីនៅឡើយទេ",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "No favorite movies added yet",
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchFavorites(),
            color: AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: provider.favorites.length,
              itemBuilder: (context, index) {
                final Movie movie = provider.favorites[index];
                final poster = movie.posterUrl ?? movie.bannerUrl;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: poster != null && poster.isNotEmpty
                          ? Image.network(
                              poster,
                              width: 55,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.white10,
                                width: 55,
                                height: 80,
                                child: const Icon(Icons.movie, color: Colors.white38),
                              ),
                            )
                          : Container(
                              color: Colors.white10,
                              width: 55,
                              height: 80,
                              child: const Icon(Icons.movie, color: Colors.white38),
                            ),
                    ),
                    title: Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        movie.releaseDate ?? "រឿងភាគ / Movie",
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: AppColors.primary),
                      onPressed: () {
                        provider.toggleFavorite(movie);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("បានលុបចេញពីបញ្ជី (Removed from Wishlist)"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}