import 'package:flutter/material.dart';
import 'package:recipe_book/domain/entities/recipe.dart';
import 'package:recipe_book/domain/entities/recipe_details.dart';

import '../../data/service/api_server.dart';

class RecipeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Recipe> _categoryRecipes = [];
  List<Recipe> get categoryRecipes => _categoryRecipes;

  List<Recipe> _searchResults = [];
  List<Recipe> get searchResults => _searchResults;

  List<Recipe> _weeklyRecipes = [];
  List<Recipe> get weeklyRecipes => _weeklyRecipes;

  bool _isCategoryLoading = false;
  bool get isCategoryLoading => _isCategoryLoading;

  bool _isSearchLoading = false;
  bool get isSearchLoading => _isSearchLoading;

  bool _isWeeklyLoading = false;
  bool get isWeeklyLoading => _isWeeklyLoading;

  bool _isRecipeDetailsLoading = false;
  bool get isRecipeDetailsLoading => _isRecipeDetailsLoading;

  RecipeDetails? _selectedRecipeDetails;
  RecipeDetails? get selectedRecipeDetails => _selectedRecipeDetails;

  String? _recipeDetailsError;
  String? get recipeDetailsError => _recipeDetailsError;

  bool get isLoading =>
      _isCategoryLoading ||
      _isSearchLoading ||
      _isWeeklyLoading ||
      _isRecipeDetailsLoading;

  Future<void> fetchRecipesByCategory(String category) async {
    _isCategoryLoading = true;
    notifyListeners();
    try {
      _categoryRecipes = await _apiService.getRecipesByCategory(category);
      debugPrint(
        'Fetched ${_categoryRecipes.length} recipes for category: $category',
      );
    } catch (e) {
      debugPrint('Error fetching recipes: $e');
    } finally {
      _isCategoryLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRecipes(String query) async {
    _isSearchLoading = true;
    notifyListeners();
    try {
      _searchResults = await _apiService.searchRecipes(query);
    } catch (e) {
      debugPrint('Error searching recipes: $e');
    } finally {
      _isSearchLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeeklyRecipes() async {
    _isWeeklyLoading = true;
    notifyListeners();
    try {
      _weeklyRecipes = await _apiService.getWeeklyRecipes();
    } catch (e) {
      debugPrint('Error fetching weekly recipes: $e');
    } finally {
      _isWeeklyLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecipeDetails(int recipeId) async {
    _isRecipeDetailsLoading = true;
    _recipeDetailsError = null;
    _selectedRecipeDetails = null;
    notifyListeners();

    try {
      _selectedRecipeDetails = await _apiService.getRecipeDetails(recipeId);
    } catch (e) {
      _recipeDetailsError = 'Failed to load recipe details';
      debugPrint('Error fetching recipe details: $e');
    } finally {
      _isRecipeDetailsLoading = false;
      notifyListeners();
    }
  }

  void clearRecipeDetails() {
    _selectedRecipeDetails = null;
    _recipeDetailsError = null;
    _isRecipeDetailsLoading = false;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
