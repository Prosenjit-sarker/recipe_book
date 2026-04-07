import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/core/app_color.dart';
import 'package:recipe_book/data/service/api_server.dart';
import 'package:recipe_book/domain/entities/recipe.dart';
import 'package:recipe_book/domain/entities/recipe_details.dart';
import 'package:recipe_book/presentation/provider/recipe_provider.dart';
import 'package:recipe_book/presentation/screens/saved_recipes_screen.dart';
import 'package:recipe_book/presentation/widgets/responsive_scaffold_body.dart';
import 'package:url_launcher/url_launcher.dart';

class RecipeDetailsScreen extends StatefulWidget {
  const RecipeDetailsScreen({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late final Future<RecipeDetails> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = ApiService().getRecipeDetails(widget.recipe.id);
  }

  @override
  Widget build(BuildContext context) {
    final isSaved =
        context.watch<RecipeProvider>().isRecipeSaved(widget.recipe.id);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Recipe Details'),
        actions: [
          IconButton(
            onPressed: () async {
              final didSave = await context
                  .read<RecipeProvider>()
                  .toggleSavedRecipe(widget.recipe);
              if (!context.mounted) return;
              if (didSave) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedRecipesScreen(),
                  ),
                );
              }
            },
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
            ),
          ),
        ],
      ),
      body: ResponsiveScaffoldBody(
        child: FutureBuilder<RecipeDetails>(
          future: _detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final details = snapshot.data ?? _fallbackDetails();
            return _buildContent(
              details: details,
              showApiWarning: snapshot.hasError || !snapshot.hasData,
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent({
    required RecipeDetails details,
    required bool showApiWarning,
  }) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CachedNetworkImage(
                imageUrl: details.image.isNotEmpty
                    ? details.image
                    : widget.recipe.image,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 280,
                  color: AppColors.grey200,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.broken_image,
                    color: AppColors.grey,
                    size: 42,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: -70,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              details.title.isNotEmpty
                                  ? details.title
                                  : widget.recipe.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.starColor,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            details.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildMetaItem(
                            icon: Icons.play_circle_fill_rounded,
                            value: '${details.videoTime} min',
                          ),
                          const SizedBox(width: 12),
                          _buildMetaItem(
                            icon: Icons.workspace_premium_rounded,
                            value: 'Quality ${details.quality}',
                          ),
                          const SizedBox(width: 12),
                          _buildMetaItem(
                            icon: Icons.local_fire_department_rounded,
                            value:
                                '${details.calories.toStringAsFixed(0)} kcal',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 72),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showApiWarning)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'API details ekhono load hoyni. Basic recipe info dekhano hocche.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                const Text(
                  'Ingredients',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (details.ingredients.isEmpty)
                  const Text(
                    'Ingredients not available',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  ...details.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              ingredient,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  details.description.isNotEmpty
                      ? details.description
                      : 'Description not available',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _openVideo(details),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text(
                      'Watch videos',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ],
      ),
    );
  }

  RecipeDetails _fallbackDetails() {
    return RecipeDetails(
      id: widget.recipe.id,
      title: widget.recipe.title,
      image: widget.recipe.image,
      rating: 4.5,
      videoTime: 0,
      quality: 0,
      calories: 0,
      ingredients: const [],
      description: 'Recipe details are not available right now.',
      videoUrl: '',
    );
  }

  Future<void> _openVideo(RecipeDetails details) async {
    if (details.videoUrl.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video URL not available')),
      );
      return;
    }

    final uri = Uri.tryParse(details.videoUrl);
    if (uri == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid video URL')));
      return;
    }

    final didLaunch = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!didLaunch && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open video link')),
      );
    }
  }

  Widget _buildMetaItem({required IconData icon, required String value}) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
