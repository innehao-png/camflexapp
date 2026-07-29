import '../config/api_config.dart';
import 'api_client.dart';

class FavoriteService {
  final String? token;

  FavoriteService([this.token]);

  // GET /favorites
  Future<Map<String, dynamic>> getFavorites({int page = 1}) async {
    final response = await ApiClient.get(
      ApiConfig.favorites,
      queryParams: page > 1 ? {'page': page.toString()} : null,
    );

    if (response is Map<String, dynamic>) {
      return response;
    } else if (response is List) {
      return {'data': response};
    }
    return {'data': []};
  }

  // POST /favorites/{id}
  Future<dynamic> addToFavorites(dynamic movieId) async {
    try {
      return await ApiClient.post("${ApiConfig.favorites}/$movieId");
    } catch (_) {
      // Fallback: try POST /favorites with movie_id body parameter
      return await ApiClient.post(
        ApiConfig.favorites,
        body: {'movie_id': movieId},
      );
    }
  }

  // DELETE /favorites/{id}
  Future<dynamic> removeFromFavorites(dynamic movieId) async {
    try {
      return await ApiClient.delete("${ApiConfig.favorites}/$movieId");
    } catch (_) {
      // Fallback: try DELETE /favorites with movie_id body parameter
      return await ApiClient.delete(
        ApiConfig.favorites,
        body: {'movie_id': movieId},
      );
    }
  }
}