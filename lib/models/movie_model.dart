import 'category_model.dart';
import 'pagination_meta.dart';

class Episode {
  final dynamic id;
  final String title;
  final int episodeNumber;
  final String? videoUrl;

  Episode({
    required this.id,
    required this.title,
    required this.episodeNumber,
    this.videoUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      title: json['title']?.toString() ?? 'Episode ${json['episode_number'] ?? ''}',
      episodeNumber: json['episode_number'] is int ? json['episode_number'] : 1,
      videoUrl: json['video_url']?.toString() ?? json['url']?.toString(),
    );
  }
}

class Movie {
  final dynamic id;
  final String title;
  final String? slug;
  final String? posterUrl;
  final String? bannerUrl;
  final String? trailerUrl;
  final String? description;
  final String? releaseDate;
  final String? type;
  final bool isFavorited;
  final List<Category> categories;
  final List<Episode> episodes;

  Movie({
    required this.id,
    required this.title,
    this.slug,
    this.posterUrl,
    this.bannerUrl,
    this.trailerUrl,
    this.description,
    this.releaseDate,
    this.type,
    this.isFavorited = false,
    this.categories = const [],
    this.episodes = const [],
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title']?.toString() ?? 'Untitled Movie',
      slug: json['slug']?.toString(),
      posterUrl: json['poster_url']?.toString() ?? json['poster']?.toString() ?? json['image_url']?.toString() ?? json['image']?.toString(),
      bannerUrl: json['banner_url']?.toString() ?? json['banner']?.toString() ?? json['poster_url']?.toString(),
      trailerUrl: json['trailer_url']?.toString(),
      description: json['description']?.toString() ?? json['synopsis']?.toString(),
      type: json['type']?.toString(),
      releaseDate: json['cambodia_release_date']?.toString(),
      isFavorited: json['is_favorited'] == true || json['is_favorited'] == 1,
      categories: json['categories'] is List
          ? (json['categories'] as List).map((c) => Category.fromJson(c)).toList()
          : [],
      episodes: json['episodes'] is List
          ? (json['episodes'] as List).map((e) => Episode.fromJson(e)).toList()
          : [],
    );
  }
}

class PaginatedMovies {
  final List<Movie> movies;
  final PaginationMeta meta;

  PaginatedMovies({
    required this.movies,
    required this.meta,
  });
}
