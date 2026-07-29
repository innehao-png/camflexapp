import '../config/api_config.dart';
import '../models/category_model.dart';
import '../models/movie_model.dart';
import '../models/pagination_meta.dart';
import 'api_client.dart';

class MovieService {
  /// Get categories list: GET /categories
  static Future<List<Category>> getCategories() async {
    try {
      final response = await ApiClient.get(ApiConfig.categories);
      List rawList = [];
      if (response is List) {
        rawList = response;
      } else if (response is Map && response.containsKey('data')) {
        rawList = response['data'] as List;
      }
      return rawList.map((json) => Category.fromJson(json)).toList();
    } catch (e) {
      throw ApiException("Failed to load categories: $e");
    }
  }

  /// Get movies list with filters & pagination: GET /movies
  static Future<PaginatedMovies> getMovies({
    String? category,
    String? type,
    String? search,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (page > 1) {
        queryParams['page'] = page.toString();
      }

      final response = await ApiClient.get(
        ApiConfig.movies,
        queryParams: queryParams,
      );

      List<Movie> movies = [];
      PaginationMeta meta = PaginationMeta(
        currentPage: 1,
        lastPage: 1,
        perPage: 15,
        total: 0,
      );

      if (response is Map<String, dynamic>) {
        if (response['data'] is List) {
          movies = (response['data'] as List)
              .map((json) => Movie.fromJson(json))
              .toList();
        }
        if (response['meta'] is Map<String, dynamic>) {
          meta = PaginationMeta.fromJson(response['meta']);
        }
      } else if (response is List) {
        movies = response.map((json) => Movie.fromJson(json)).toList();
      }

      return PaginatedMovies(movies: movies, meta: meta);
    } catch (e) {
      throw ApiException("Failed to load movies: $e");
    }
  }

  /// Get movie details: GET /movies/{idOrSlug}
  static Future<Movie> getMovieDetails(dynamic movieParam) async {
    try {
      final response = await ApiClient.get("${ApiConfig.movies}/$movieParam");
      Map<String, dynamic> jsonMap = {};
      if (response is Map<String, dynamic>) {
        if (response.containsKey('data') && response['data'] is Map) {
          jsonMap = response['data'] as Map<String, dynamic>;
        } else {
          jsonMap = response;
        }
      }
      return Movie.fromJson(jsonMap);
    } catch (e) {
      throw ApiException("Failed to load movie details: $e");
    }
  }
}
