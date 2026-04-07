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
  bool _isSearching = false;

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
        title: _isSearching
            ? TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: true,
                onChanged: (value) {
                  setState(() {
                    _query = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search saved recipes...',
                  border: InputBorder.none,
                ),
              )
            : const Text('Saved Recipes'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _query = '';
                  _searchFocusNode.unfocus();
                }
              });

              if (_isSearching) {
                _searchFocusNode.requestFocus();
              }
            },
            icon: Icon(_isSearching ? Icons.close : Icons.search),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                              recipe: filteredRecipes[index],
                              openSavedScreenOnSave: false,
                            );
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
