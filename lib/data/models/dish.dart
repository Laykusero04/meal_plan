class Dish {
  final String id;
  final String name;
  final String description;
  final String mainIngredient;
  final List<String> ingredients;
  final String category;
  final List<String> tags;
  final String? author;
  final String? imageUrl;
  final List<String> optionalIngredients;
  final bool isPublic;
  final DateTime createdAt;

  Dish({
    required this.id,
    required this.name,
    this.description = '',
    this.mainIngredient = '',
    this.ingredients = const [],
    required this.category,
    this.tags = const [],
    this.author,
    this.imageUrl,
    this.optionalIngredients = const [],
    this.isPublic = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get required (non-optional) ingredients only
  List<String> get requiredIngredients =>
      ingredients.where((i) => !optionalIngredients.contains(i)).toList();

  /// Create a copy with modified fields
  Dish copyWith({
    String? id,
    String? name,
    String? description,
    String? mainIngredient,
    List<String>? ingredients,
    String? category,
    List<String>? tags,
    String? author,
    String? imageUrl,
    List<String>? optionalIngredients,
    bool? isPublic,
    DateTime? createdAt,
  }) {
    return Dish(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      mainIngredient: mainIngredient ?? this.mainIngredient,
      ingredients: ingredients ?? this.ingredients,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      optionalIngredients: optionalIngredients ?? this.optionalIngredients,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Dish && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
