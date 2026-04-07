class Recipe {
  final int id;
  final String title;
  final String image;

  Recipe({required this.id, required this.title, required this.image});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      title: (json['title'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'image': image};
  }
}
