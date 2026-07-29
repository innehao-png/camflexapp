import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_colors.dart';
import '../models/movie_model.dart';
import '../providers/favorite_provider.dart';
import '../services/movie_service.dart';
import '../widgets/state_widgets.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import 'subscription/subscription_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  /// Provide a full Movie object if navigating from a list (no extra network call needed)
  final Movie? movie;
  /// Provide an ID or slug only when navigating with partial data
  final dynamic movieParam;

  const MovieDetailScreen({
    super.key,
    this.movie,
    this.movieParam,
  }) : assert(movie != null || movieParam != null, 'Either movie or movieParam must be provided');

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}



class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _movie;
  String? _error;
  int _selectedTabIndex = 0; // 0: ស្រដៀងគ្នា (Similar), 1: ផ្សេងៗ (Others)
  List<Movie> _relatedMovies = [];

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _movie = widget.movie;
      _fetchRelated();
      if (_movie!.episodes.isEmpty) {
        _fetchFullDetails(_movie!.id);
      }
    } else {
      _fetchFullDetails(widget.movieParam);
    }
  }

  Future<void> _fetchFullDetails(dynamic param) async {
    setState(() {
      _error = null;
    });
    try {
      final details = await MovieService.getMovieDetails(param);
      if (mounted) {
        setState(() {
          _movie = details;
        });
        _fetchRelated();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  Future<void> _fetchRelated() async {
    try {
      final categorySlug = _movie?.categories.isNotEmpty == true
          ? _movie!.categories.first.slug
          : null;
      final paginated = await MovieService.getMovies(category: categorySlug);
      if (mounted) {
        setState(() {
          _relatedMovies = paginated.movies.where((m) => m.id.toString() != _movie?.id.toString()).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _openExternalYoutube(String url) async {
    final Uri? uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open trailer link")),
        );
      }
    }
  }

  void _playYoutube(String? url) {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No trailer available")),
      );
      return;
    }

    final videoId = YoutubePlayerController.convertUrlToId(url);
    if (videoId == null) {
      _openExternalYoutube(url);
      return;
    }

    final controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
      ),
    );

    final watchUrl = "https://www.youtube.com/watch?v=$videoId";

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: YoutubePlayer(
                controller: controller,
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _openExternalYoutube(watchUrl);
                    },
                    icon: const Icon(Icons.open_in_new, color: AppColors.primary, size: 18),
                    label: const Text(
                      "ទស្សនាតាម YouTube (Watch on YouTube)",
                      style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_movie == null) return;
    final provider = context.read<FavoriteProvider>();
    await provider.toggleFavorite(_movie!);
    if (mounted) {
      final isNowFav = provider.isFavorited(_movie!.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isNowFav
              ? "បន្ថែមទៅបញ្ជីចង់ទស្សនា (Added to Wishlist)"
              : "បានលុបចេញពីបញ្ជី (Removed from Wishlist)"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareMovie() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ចែករំលែក (Sharing link copied)")),
    );
  }

  void _downloadMovie() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ទាញយក (Downloading movie...)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _error != null && _movie == null
          ? AppErrorState(
        message: _error!,
        onRetry: () => _fetchFullDetails(widget.movie?.id ?? widget.movieParam),
      )
          : _movie == null
          ? const AppLoading()
          : CustomScrollView(
        slivers: [
          // Banner & Header Sliver
          SliverAppBar(
            expandedHeight: 480.0,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black45,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  children: [
                    Text("🇰🇭", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Poster Image Background
                  _buildPosterImage(),

                  // Dark Overlay Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.4),
                          AppColors.background.withOpacity(0.9),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.45, 0.82, 1.0],
                      ),
                    ),
                  ),

                  // Movie Title, Subtitle & Action Buttons
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 12,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          _movie!.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle Metadata Line: R 18+ • Category / Tag • 2026
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "R 18+",
                              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("•", style: TextStyle(color: Colors.white38)),
                            ),
                            Text(
                              _movie!.categories.isNotEmpty ? _movie!.categories.first.name : "រឿងចេញថ្មី",
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text("•", style: TextStyle(color: Colors.white38)),
                            ),
                            const Text(
                              "2026",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Primary SASTRA Subscription Button (Hot Pink)
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.workspace_premium, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "ភ្ជាប់គម្រោង SASTRA ដើម្បីទស្សនា",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Secondary Watch Trailer Button (White)
                        ElevatedButton(
                          onPressed: () => _playYoutube(_movie?.trailerUrl),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(double.infinity, 48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 4,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_arrow, color: Colors.black, size: 24),
                              SizedBox(width: 6),
                              Text(
                                "មើល Trailer",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Body Content Sliver
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action Row: Wishlist | Share | Download
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Consumer<FavoriteProvider>(
                            builder: (context, favProvider, child) {
                              final isFav = _movie != null && favProvider.isFavorited(_movie!.id);
                              return InkWell(
                                onTap: _toggleFavorite,
                                child: Column(
                                  children: [
                                    Icon(
                                      isFav ? Icons.favorite : Icons.favorite_border,
                                      color: isFav ? const Color(0xFFFF007A) : Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      "ចង់ទស្សនា",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Container(width: 1, height: 28, color: Colors.white24),
                        Expanded(
                          child: InkWell(
                            onTap: _shareMovie,
                            child: const Column(
                              children: [
                                Icon(Icons.share_outlined, color: Colors.white, size: 24),
                                SizedBox(height: 6),
                                Text(
                                  "ចែករំលែក",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(width: 1, height: 28, color: Colors.white24),
                        Expanded(
                          child: InkWell(
                            onTap: _downloadMovie,
                            child: const Column(
                              children: [
                                Icon(Icons.cloud_download_outlined, color: Colors.white, size: 24),
                                SizedBox(height: 6),
                                Text(
                                  "ទាញយក",
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 18+ Notice Disclaimer Box
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141720),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0x33FF9800),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error_outline, color: Color(0xFFFF9800), size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "សេចក្តីជូនដំណឹង",
                                style: TextStyle(
                                  color: Color(0xFFFF9800),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                "មាតិកានេះគឺសម្រាប់អ្នកទស្សនាដែលមានអាយុ 18ឆ្នាំឡើងតែប៉ុណ្ណោះ។ ប្រសិនបើអ្នកមានអាយុក្រោម 18ឆ្នាំ សូមចាកចេញពីមាតិកានេះ។",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tabs Header (ស្រដៀងគ្នា / ផ្សេងៗ)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ស្រដៀងគ្នា",
                              style: TextStyle(
                                color: _selectedTabIndex == 0 ? Colors.white : Colors.white54,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_selectedTabIndex == 0)
                              Container(width: 28, height: 3, color: AppColors.primary),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      GestureDetector(
                        onTap: () => setState(() => _selectedTabIndex = 1),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ផ្សេងៗ",
                              style: TextStyle(
                                color: _selectedTabIndex == 1 ? Colors.white : Colors.white54,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (_selectedTabIndex == 1)
                              Container(width: 28, height: 3, color: AppColors.primary),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tab Content View
                  if (_selectedTabIndex == 0)
                    _buildRelatedMoviesSection()
                  else
                    _buildDescriptionAndEpisodesSection(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedMoviesSection() {
    if (_relatedMovies.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text(
          "គ្មានរឿងស្រដៀងគ្នាទេ (No similar titles found)",
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _relatedMovies.length,
        itemBuilder: (context, index) {
          final movie = _relatedMovies[index];
          final poster = movie.posterUrl ?? movie.bannerUrl;

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieDetailScreen(movie: movie),
                ),
              );
            },
            child: Container(
              width: 120,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          poster != null
                              ? Image.network(
                            poster,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.cardBg),
                          )
                              : Container(color: AppColors.cardBg),

                          // Sastra badge
                          Positioned(
                            top: 6,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                "SASTRA",
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movie.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionAndEpisodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_movie!.description != null && _movie!.description!.isNotEmpty) ...[
          const Text(
            "ព័ត៌មានលម្អិត (Description)",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _movie!.description!,
            style: const TextStyle(color: Colors.white70, height: 1.4, fontSize: 13),
          ),
          const SizedBox(height: 16),
        ],

        if (_movie!.episodes.isNotEmpty) ...[
          const Text(
            "ភាគ (Episodes)",
            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ..._movie!.episodes.map((ep) {
            return Card(
              color: const Color(0xFF161922),
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: ListTile(
                leading: const Icon(Icons.play_circle_fill, color: AppColors.primary, size: 28),
                title: Text(ep.title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                trailing: const Icon(Icons.download, color: Colors.white54, size: 20),
                onTap: () => _playYoutube(ep.videoUrl),
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildPosterImage() {
    final url = _movie?.bannerUrl ?? _movie?.posterUrl;
    if (url != null) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: AppColors.cardBg),
      );
    }
    return Container(color: AppColors.cardBg);
  }
}