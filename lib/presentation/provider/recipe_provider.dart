import 'package:flutter/material.dart';
import 'package:recipe_book/domain/entities/recipe.dart';

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

  bool get isLoading =>
      _isCategoryLoading || _isSearchLoading || _isWeeklyLoading;

  Future<void> fetchRecipesByCategory(String category) async {
    _isCategoryLoading = true;
    notifyListeners();
    try {
      _categoryRecipes = await _apiService.getRecipesByCategory(category);
      print(
        'Fetched ${_categoryRecipes.length} recipes for category: $category',
      );
    } catch (e) {
      print('Error fetching recipes: $e');
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
      print('Error searching recipes: $e');
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
      print('Error fetching weekly recipes: $e');
    } finally {
      _isWeeklyLoading = false;
      notifyListeners();
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
