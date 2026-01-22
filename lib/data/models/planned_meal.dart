import 'dish.dart';

enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }
}

class PlannedMeal {
  final String id;
  final Dish dish;
  final MealType mealType;
  final DateTime date;
  final int servings;
  final String? notes;

  PlannedMeal({
    required this.id,
    required this.dish,
    required this.mealType,
    required this.date,
    this.servings = 1,
    this.notes,
  });

  /// Get the date without time component (for grouping by day)
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  PlannedMeal copyWith({
    String? id,
    Dish? dish,
    MealType? mealType,
    DateTime? date,
    int? servings,
    String? notes,
  }) {
    return PlannedMeal(
      id: id ?? this.id,
      dish: dish ?? this.dish,
      mealType: mealType ?? this.mealType,
      date: date ?? this.date,
      servings: servings ?? this.servings,
      notes: notes ?? this.notes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedMeal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
