import 'package:flutter/material.dart';

// Cleaned up invalid imports

import '../../models/movie_model.dart';
import '../../screens/movie_detail_screen.dart';
import '../../screens/subscription/subscription_screen.dart';

/// Centralized navigation helpers to avoid duplicated route logic.
class AppNavigator {
  AppNavigator._();

  static void openMovieDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  static Future<T?> openSubscription<T>(BuildContext context) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (_) => const SubscriptionScreen(),
      ),
    );
  }
}
