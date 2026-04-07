class RecipeDetails {
  final int id;
  final String title;
  final String image;
  final double rating;
  final int videoTime;
  final int quality;
  final double calories;
  final List<String> ingredients;
  final String description;
  final String videoUrl;

  RecipeDetails({
    required this.id,
    required this.title,
    required this.image,
    required this.rating,
    required this.videoTime,
    required this.quality,
    required this.calories,
    required this.ingredients,
    required this.description,
    required this.videoUrl,
  });

  RecipeDetails copyWith({
    int? id,
    String? title,
    String? image,
    double? rating,
    int? videoTime,
    int? quality,
    double? calories,
    List<String>? ingredients,
    String? description,
    String? videoUrl,
  }) {
    return RecipeDetails(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      rating: rating ?? this.rating,
      videoTime: videoTime ?? this.videoTime,
      quality: quality ?? this.quality,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
    );
  }
}
