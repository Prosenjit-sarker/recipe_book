import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/core/app_strings.dart';
import 'package:recipe_book/domain/entities/recipe.dart';
import 'package:recipe_book/presentation/provider/recipe_provider.dart';
import 'package:recipe_book/presentation/screens/search_screen.dart';

import '../../core/app_color.dart';
import '../widgets/recipe_card.dart';
import '../widgets/search_recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> categories = [
    'All',
    'Italian',
    'Chinese',
    'Mexican',
    'Indian',
    'French',
    'Thai',
  ];

  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecipeProvider>();
      provider.fetchRecipesByCategory(_selectedCategory);
      provider.fetchWeeklyRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              AppStrings.welcomeBack,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            Text(
              'Prosenjit Sarker',
              style: TextStyle(
                color: AppColors.black,
                fontSize: 16,
                fontWeight: .w600,
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(6.0),
          child: ClipRRect(
            borderRadius: .circular(100),
            child: Image.network(AppStrings.profileImageUrl),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
            icon: Icon(Icons.search),
          ),
          SizedBox(width: 20),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications),
          ),
        ],
      ),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.categories,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: .w600,
                  ),
                ),
                _buildCategoryList(),
                const SizedBox(height: 8),
                _buildRecipeSection(
                  title: 'Popular Recipes',
                  isLoading: provider.isCategoryLoading,
                  recipes: provider.categoryRecipes,
                  emptyMessage: 'No recipes found for this category.',
                ),
                const SizedBox(height: 24),
                _buildWeeklyRecipeSection(
                  title: 'Recipes of the Week',
                  isLoading: provider.isWeeklyLoading,
                  recipes: provider.weeklyRecipes,
                  emptyMessage: 'No weekly recipes available right now.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecipeSection({
    required String title,
    required bool isLoading,
    required List<Recipe> recipes,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: .w700,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: isLoading
              ? Center(child: CircularProgressIndicator())
              : recipes.isEmpty
              ? Center(child: Text(emptyMessage))
              : ListView.builder(
                  padding: EdgeInsets.zero,
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeCard(recipe: recipes[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWeeklyRecipeSection({
    required String title,
    required bool isLoading,
    required List<Recipe> recipes,
    required String emptyMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: .w700,
          ),
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (recipes.isEmpty)
          SizedBox(
            height: 120,
            child: Center(child: Text(emptyMessage)),
          )
        else
          ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: recipes.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return SearchRecipeCard(recipe: recipes[index]);
            },
          ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
              onTap: () {
                if (_selectedCategory == category) return;

                setState(() {
                  _selectedCategory = category;
                  context.read<RecipeProvider>().fetchRecipesByCategory(
                    _selectedCategory,
                  );
                });
              },
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.grey200,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    categories[index],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: .w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
