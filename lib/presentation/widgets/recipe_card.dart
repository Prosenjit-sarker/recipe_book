import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/domain/entities/recipe.dart';
import 'package:recipe_book/presentation/provider/recipe_provider.dart';
import 'package:recipe_book/presentation/screens/recipe_details_screen.dart';
import 'package:recipe_book/presentation/screens/saved_recipes_screen.dart';

import '../../core/app_color.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final isSaved = provider.isRecipeSaved(recipe.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailsScreen(recipe: recipe),
          ),
        );
      },
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: SizedBox(
            width: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CachedNetworkImage(
                        imageUrl: recipe.image,
                        height: 180,
                        width: 170,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.customOverlay,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: AppColors.starColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '4.5',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: GestureDetector(
                        onTap: () async {
                          await context
                              .read<RecipeProvider>()
                              .saveRecipe(recipe);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SavedRecipesScreen(),
                            ),
                          );
                        },
                        child: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 170,
                  child: Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
