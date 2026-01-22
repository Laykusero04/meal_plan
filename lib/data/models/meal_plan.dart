import 'planned_meal.dart';

class MealPlan {
  final String id;
  final String name;
  final DateTime weekStartDate;
  final List<PlannedMeal> meals;
  final DateTime createdAt;

  MealPlan({
    required this.id,
    required this.name,
    required this.weekStartDate,
    this.meals = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Get the week end date
  DateTime get weekEndDate => weekStartDate.add(const Duration(days: 6));

  /// Get meals for a specific day
  List<PlannedMeal> getMealsForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return meals.where((m) => m.dateOnly == dateOnly).toList();
  }

  /// Get meals for a specific meal type on a specific day
  List<PlannedMeal> getMealsForDateAndType(DateTime date, MealType mealType) {
    return getMealsForDate(date).where((m) => m.mealType == mealType).toList();
  }

  /// Get all unique ingredients needed for this meal plan
  List<String> get allIngredients {
    final ingredients = <String>{};
    for (final meal in meals) {
      ingredients.addAll(meal.dish.ingredientsList);
    }
    return ingredients.toList()..sort();
  }

  /// Get all required (non-optional) ingredients
  List<String> get requiredIngredients {
    final ingredients = <String>{};
    for (final meal in meals) {
      ingredients.addAll(meal.dish.requiredIngredients);
    }
    return ingredients.toList()..sort();
  }

  MealPlan copyWith({
    String? id,
    String? name,
    DateTime? weekStartDate,
    List<PlannedMeal>? meals,
    DateTime? createdAt,
  }) {
    return MealPlan(
      id: id ?? this.id,
      name: name ?? this.name,
      weekStartDate: weekStartDate ?? this.weekStartDate,
      meals: meals ?? this.meals,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlan && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
