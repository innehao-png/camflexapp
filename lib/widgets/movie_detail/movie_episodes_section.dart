import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/movie_model.dart';

class MovieEpisodesSection extends StatelessWidget {
  final List<Episode> episodes;
  final Function(Episode) onSelectEpisode;

  const MovieEpisodesSection({
    super.key,
    required this.episodes,
    required this.onSelectEpisode,
  });

  @override
  Widget build(BuildContext context) {
    if (episodes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ភាគទាំងអស់ (Episodes)",
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: episodes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final ep = episodes[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    child: Text(
                      '${ep.episodeNumber}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    ep.title,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: const Icon(
                    Icons.play_circle_outline,
                    color: AppColors.primary,
                  ),
                  onTap: () => onSelectEpisode(ep),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
