import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../config/app_colors.dart';
import '../models/movie_model.dart';
import '../providers/movie_detail_provider.dart';
import '../widgets/movie_detail/movie_action_bar.dart';
import '../widgets/movie_detail/movie_detail_header.dart';
import '../widgets/movie_detail/movie_episodes_section.dart';
import '../widgets/movie_detail/movie_related_grid.dart';
import '../widgets/state_widgets.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie? movie;
  final dynamic movieParam;

  const MovieDetailScreen({
    super.key,
    this.movie,
    this.movieParam,
  }) : assert(movie != null || movieParam != null, 'Either movie or movieParam must be provided');

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final provider = MovieDetailProvider();
        if (movie != null) {
          provider.initializeWithMovie(movie!);
        } else {
          provider.fetchFullDetails(movieParam);
        }
        return provider;
      },
      child: const _MovieDetailContent(),
    );
  }
}

class _MovieDetailContent extends StatefulWidget {
  const _MovieDetailContent();

  @override
  State<_MovieDetailContent> createState() => _MovieDetailContentState();
}

class _MovieDetailContentState extends State<_MovieDetailContent> {
  YoutubePlayerController? _youtubeController;

  @override
  void dispose() {
    _youtubeController?.close();
    super.dispose();
  }

  void _playTrailer(String? url) {
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

    setState(() {
      _youtubeController?.close();
      _youtubeController = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
        ),
      );
    });
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

  void _handleEpisodeTap(Episode episode) {
    _playTrailer(episode.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieDetailProvider>();

    if (provider.isLoading && provider.movie == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: AppLoading(),
      );
    }

    if (provider.error != null && provider.movie == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background),
        body: AppErrorState(
          message: provider.error!,
          onRetry: () => provider.fetchFullDetails(provider.movie?.id),
        ),
      );
    }

    final movie = provider.movie!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(movie.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_youtubeController != null)
              AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(controller: _youtubeController!),
              )
            else
              MovieDetailHeader(movie: movie),

            MovieActionBar(
              movie: movie,
              onPlayTrailer: () => _playTrailer(movie.trailerUrl),
              onOpenExternalYoutube: () => _openExternalYoutube(movie.trailerUrl ?? ''),
            ),

            MovieEpisodesSection(
              episodes: movie.episodes,
              onSelectEpisode: _handleEpisodeTap,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "រឿងស្រដៀងគ្នា (Related Movies)",
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            MovieRelatedGrid(movies: provider.relatedMovies),
          ],
        ),
      ),
    );
  }
}