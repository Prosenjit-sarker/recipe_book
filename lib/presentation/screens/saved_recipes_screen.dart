import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/core/app_color.dart';
import 'package:recipe_book/presentation/provider/recipe_provider.dart';
import 'package:recipe_book/presentation/widgets/responsive_scaffold_body.dart';
import 'package:recipe_book/presentation/widgets/search_recipe_card.dart';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  State<SavedRecipesScreen> createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Saved Recipes'),
        actions: [
          IconButton(
            onPressed: () {
              _searchFocusNode.requestFocus();
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: ResponsiveScaffoldBody(
        child: Consumer<RecipeProvider>(
          builder: (context, provider, child) {
            if (provider.isSavedRecipesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final filteredRecipes = provider.savedRecipes.where((recipe) {
              final query = _query.trim().toLowerCase();
              if (query.isEmpty) return true;
              return recipe.title.toLowerCase().contains(query);
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (value) {
                      setState(() {
                        _query = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search saved recipes...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                });
                              },
                              icon: const Icon(Icons.close),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF8F8F8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filteredRecipes.isEmpty
                      ? Center(
                          child: Text(
                            provider.savedRecipes.isEmpty
                                ? 'No saved recipes yet'
                                : 'No saved recipe matches your search',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredRecipes.length,
                          itemBuilder: (context, index) {
                            return SearchRecipeCard(
                                recipe: filteredRecipes[index]);
                          },
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
