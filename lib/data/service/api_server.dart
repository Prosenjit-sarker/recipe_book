import 'dart:convert';

import 'package:recipe_book/core/app_strings.dart';
import 'package:recipe_book/data/model/recipe_model.dart';
import 'package:recipe_book/domain/entities/recipe.dart';
import 'package:recipe_book/domain/entities/recipe_details.dart';
import 'package:http/http.dart' as http;

import '../model/recipe_details_model.dart';

class ApiService {
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    final url = category == 'All'
        ? '${AppStrings.baseUrl}/complexSearch?apiKey=${AppStrings.apiKey}'
        : '${AppStrings.baseUrl}/complexSearch?apiKey=${AppStrings.apiKey}&cuisine=$category';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((e) => RecipeModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  Future<List<Recipe>> searchRecipes(String query) async {
    final response = await http.get(
      Uri.parse(
        '${AppStrings.baseUrl}/complexSearch?apiKey=${AppStrings.apiKey}&query=$query',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['results'];
      return results.map((e) => RecipeModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to search recipes');
    }
  }

  Future<List<Recipe>> getWeeklyRecipes() async {
    final response = await http.get(
      Uri.parse(
        '${AppStrings.baseUrl}/random?apiKey=${AppStrings.apiKey}&number=10',
      ),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List results = json['recipes'];
      return results.map((e) => RecipeModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load weekly recipes');
    }
  }

  Future<RecipeDetails> getRecipeDetails(int recipeId) async {
    final response = await http.get(
      Uri.parse(
        '${AppStrings.baseUrl}/$recipeId/information?apiKey=${AppStrings.apiKey}&includeNutrition=true',
      ),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      RecipeDetails details = RecipeDetailsModel.fromJson(json);

      if (details.ingredients.isEmpty) {
        final ingredients = await _getRecipeIngredients(recipeId);
        if (ingredients.isNotEmpty) {
          details = details.copyWith(ingredients: ingredients);
        }
      }

      if (details.description.isEmpty) {
        final description = await _getRecipeSummary(recipeId);
        if (description.isNotEmpty) {
          details = details.copyWith(description: description);
        }
      }

      return details;
    } else {
      throw Exception('Failed to load recipe details');
    }
  }

  Future<List<String>> _getRecipeIngredients(int recipeId) async {
    final response = await http.get(
      Uri.parse(
        '${AppStrings.baseUrl}/$recipeId/ingredientWidget.json?apiKey=${AppStrings.apiKey}',
      ),
    );

    if (response.statusCode != 200) {
      return [];
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final ingredients = (json['ingredients'] as List<dynamic>? ?? [])
        .map((item) {
          final ingredient = item as Map<String, dynamic>?;
          final name = (ingredient?['name'] ?? '').toString().trim();
          final amount = (ingredient?['amount']?['metric']?['value'] ?? '')
              .toString()
              .trim();
          final unit = (ingredient?['amount']?['metric']?['unit'] ?? '')
              .toString()
              .trim();

          final prefix =
              [amount, unit].where((value) => value.isNotEmpty).join(' ');
          return [prefix, name].where((value) => value.isNotEmpty).join(' ');
        })
        .where((item) => item.isNotEmpty)
        .toList();

    return ingredients;
  }

  Future<String> _getRecipeSummary(int recipeId) async {
    final response = await http.get(
      Uri.parse(
        '${AppStrings.baseUrl}/$recipeId/summary?apiKey=${AppStrings.apiKey}',
      ),
    );

    if (response.statusCode != 200) {
      return '';
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return RecipeDetailsModel.sanitizeText((json['summary'] ?? '').toString());
  }
}
