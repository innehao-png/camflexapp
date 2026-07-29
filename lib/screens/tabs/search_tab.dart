import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/category_model.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';
import '../../widgets/movie_card.dart';
import '../../widgets/state_widgets.dart';
import '../movie_detail_screen.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Movie> _results = [];
  List<Category> _categories = [];
  String? _selectedCategory;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _search('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await MovieService.getCategories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {}
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final result = await MovieService.getMovies(
        search: query.isEmpty ? null : query,
        category: _selectedCategory,
      );
      if (mounted) {
        setState(() {
          _results = result.movies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openMovieDetail(Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: "ស្វែងរកចំណងជើងរឿង... (Search movies)",
              hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _search('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Category Filter Chips
          if (_categories.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final isSelected = _selectedCategory == null;
                    return _buildChip("ទាំងអស់ (All)", isSelected, () {
                      setState(() => _selectedCategory = null);
                      _search(_searchController.text);
                    });
                  }
                  final cat = _categories[index - 1];
                  final isSelected = _selectedCategory == cat.slug;
                  return _buildChip(cat.name, isSelected, () {
                    setState(() => _selectedCategory = isSelected ? null : cat.slug);
                    _search(_searchController.text);
                  });
                },
              ),
            ),

          // Results Grid
          Expanded(
            child: _isLoading
                ? const AppLoading()
                : _error != null
                    ? AppErrorState(
                        message: _error!,
                        onRetry: () => _search(_searchController.text),
                      )
                    : _results.isEmpty
                        ? const AppEmptyState(
                            message: "រកមិនឃើញរឿង\nNo movies found",
                            icon: Icons.search_off,
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              return MovieCard(
                                movie: _results[index],
                                width: double.infinity,
                                height: 220,
                                onTap: () => _openMovieDetail(_results[index]),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
          fontSize: 12,
        ),
        selectedColor: AppColors.primary,
        backgroundColor: AppColors.cardBg,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
