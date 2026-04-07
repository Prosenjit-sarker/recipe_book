import 'package:recipe_book/domain/entities/recipe_details.dart';

class RecipeDetailsModel extends RecipeDetails {
  RecipeDetailsModel({
    required super.id,
    required super.title,
    required super.image,
    required super.rating,
    required super.videoTime,
    required super.quality,
    required super.calories,
    required super.ingredients,
    required super.description,
    required super.videoUrl,
  });

  factory RecipeDetailsModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> ingredientsJson =
        (json['extendedIngredients'] as List<dynamic>?) ?? [];
    final ingredients = ingredientsJson
        .map((item) => _parseIngredient(item as Map<String, dynamic>?))
        .where((item) => item.isNotEmpty)
        .toList();

    final List<dynamic> nutrients =
        (json['nutrition']?['nutrients'] as List<dynamic>?) ?? [];
    final caloriesData = nutrients.cast<Map<String, dynamic>?>().firstWhere(
          (item) =>
              (item?['name'] ?? '').toString().toLowerCase() == 'calories',
          orElse: () => null,
        );
    final calories =
        double.tryParse((caloriesData?['amount'] ?? 0).toString()) ?? 0;

    final spoonacularScore =
        double.tryParse((json['spoonacularScore'] ?? 0).toString()) ?? 0;
    final rating = ((spoonacularScore / 20).clamp(0, 5)).toDouble();
    final description = _parseDescription(json);

    return RecipeDetailsModel(
      id: json['id'] ?? 0,
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      rating: rating,
      videoTime: json['readyInMinutes'] ?? 0,
      quality: json['healthScore'] ?? 0,
      calories: calories,
      ingredients: ingredients,
      description: description,
      videoUrl:
          (json['sourceUrl'] ?? json['spoonacularSourceUrl'] ?? '').toString(),
    );
  }

  static String _parseIngredient(Map<String, dynamic>? item) {
    if (item == null) return '';

    final candidates = [
      item['original'],
      item['originalName'],
      item['nameClean'],
      item['name'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  static String _parseDescription(Map<String, dynamic> json) {
    final summary = sanitizeText((json['summary'] ?? '').toString());
    if (summary.isNotEmpty) {
      return summary;
    }

    final instructions = sanitizeText((json['instructions'] ?? '').toString());
    if (instructions.isNotEmpty) {
      return instructions;
    }

    final analyzedInstructions =
        (json['analyzedInstructions'] as List<dynamic>?) ?? [];
    for (final instruction in analyzedInstructions) {
      final steps =
          (instruction as Map<String, dynamic>?)?['steps'] as List<dynamic>?;
      if (steps == null) continue;

      final stepTexts = steps
          .map((step) => ((step as Map<String, dynamic>?)?['step'] ?? '')
              .toString()
              .trim())
          .where((step) => step.isNotEmpty)
          .toList();

      if (stepTexts.isNotEmpty) {
        return stepTexts.join(' ');
      }
    }

    return '';
  }

  static String sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
