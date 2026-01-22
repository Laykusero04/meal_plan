import 'package:flutter/foundation.dart';
import '../models/models.dart';

class MealPlanProvider extends ChangeNotifier {
  final List<MealPlan> _mealPlans = [];
  MealPlan? _currentPlan;

  List<MealPlan> get mealPlans => List.unmodifiable(_mealPlans);
  MealPlan? get currentPlan => _currentPlan;

  MealPlanProvider() {
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Get the start of this week (Monday)
    final now = DateTime.now();
    final daysToMonday = now.weekday - 1;
    final weekStart = DateTime(now.year, now.month, now.day - daysToMonday);

    // Sample dishes for planned meals
    final sampleDishes = [
      Dish(
        id: 'sample-1',
        name: 'Scrambled Eggs & Toast',
        ingredients: 'Eggs, Bread, Butter, Salt, Pepper',
        category: 'Breakfast',
        optionalIngredients: ['Pepper'],
      ),
      Dish(
        id: 'sample-2',
        name: 'Grilled Chicken Salad',
        ingredients: 'Chicken Breast, Lettuce, Tomatoes, Olive Oil, Lemon',
        category: 'Lunch',
        optionalIngredients: ['Lemon'],
      ),
      Dish(
        id: 'sample-3',
        name: 'Pasta Carbonara',
        ingredients: 'Pasta, Bacon, Eggs, Parmesan, Pepper',
        category: 'Dinner',
      ),
      Dish(
        id: 'sample-4',
        name: 'Pancakes',
        ingredients: 'Flour, Eggs, Milk, Sugar, Butter',
        category: 'Breakfast',
        optionalIngredients: ['Sugar'],
      ),
      Dish(
        id: 'sample-5',
        name: 'Vegetable Soup',
        ingredients: 'Carrots, Celery, Onion, Tomato, Herbs',
        category: 'Lunch',
        optionalIngredients: ['Herbs'],
      ),
      Dish(
        id: 'sample-6',
        name: 'Beef Stir Fry',
        ingredients: 'Beef, Bell Pepper, Onion, Soy Sauce, Garlic',
        category: 'Dinner',
        optionalIngredients: ['Bell Pepper'],
      ),
    ];

    // Create sample planned meals for this week
    final meals = <PlannedMeal>[];

    // Today
    meals.add(PlannedMeal(
      id: 'pm-1',
      dish: sampleDishes[0],
      mealType: MealType.breakfast,
      date: now,
    ));
    meals.add(PlannedMeal(
      id: 'pm-2',
      dish: sampleDishes[1],
      mealType: MealType.lunch,
      date: now,
    ));
    meals.add(PlannedMeal(
      id: 'pm-3',
      dish: sampleDishes[2],
      mealType: MealType.dinner,
      date: now,
    ));

    // Tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    meals.add(PlannedMeal(
      id: 'pm-4',
      dish: sampleDishes[3],
      mealType: MealType.breakfast,
      date: tomorrow,
    ));
    meals.add(PlannedMeal(
      id: 'pm-5',
      dish: sampleDishes[4],
      mealType: MealType.lunch,
      date: tomorrow,
    ));
    meals.add(PlannedMeal(
      id: 'pm-6',
      dish: sampleDishes[5],
      mealType: MealType.dinner,
      date: tomorrow,
    ));

    // Day after tomorrow
    final dayAfter = now.add(const Duration(days: 2));
    meals.add(PlannedMeal(
      id: 'pm-7',
      dish: sampleDishes[0],
      mealType: MealType.breakfast,
      date: dayAfter,
    ));
    meals.add(PlannedMeal(
      id: 'pm-8',
      dish: sampleDishes[2],
      mealType: MealType.dinner,
      date: dayAfter,
    ));

    // Create current week's plan
    _currentPlan = MealPlan(
      id: 'plan-current',
      name: 'This Week',
      weekStartDate: weekStart,
      meals: meals,
    );
    _mealPlans.add(_currentPlan!);
  }

  /// Get meals for a specific date
  List<PlannedMeal> getMealsForDate(DateTime date) {
    if (_currentPlan == null) return [];
    return _currentPlan!.getMealsForDate(date);
  }

  /// Get meals for a specific date and meal type
  List<PlannedMeal> getMealsForDateAndType(DateTime date, MealType mealType) {
    if (_currentPlan == null) return [];
    return _currentPlan!.getMealsForDateAndType(date, mealType);
  }

  /// Add a meal to the current plan
  void addMealToPlan(Dish dish, MealType mealType, DateTime date) {
    if (_currentPlan == null) {
      // Create a new plan if none exists
      final now = DateTime.now();
      final daysToMonday = now.weekday - 1;
      final weekStart = DateTime(now.year, now.month, now.day - daysToMonday);
      _currentPlan = MealPlan(
        id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
        name: 'This Week',
        weekStartDate: weekStart,
        meals: [],
      );
      _mealPlans.add(_currentPlan!);
    }

    final newMeal = PlannedMeal(
      id: 'pm-${DateTime.now().millisecondsSinceEpoch}',
      dish: dish,
      mealType: mealType,
      date: date,
    );

    _currentPlan = _currentPlan!.copyWith(
      meals: [..._currentPlan!.meals, newMeal],
    );

    // Update in the list
    final index = _mealPlans.indexWhere((p) => p.id == _currentPlan!.id);
    if (index != -1) {
      _mealPlans[index] = _currentPlan!;
    }

    notifyListeners();
  }

  /// Remove a meal from the plan
  void removeMealFromPlan(String mealId) {
    if (_currentPlan == null) return;

    _currentPlan = _currentPlan!.copyWith(
      meals: _currentPlan!.meals.where((m) => m.id != mealId).toList(),
    );

    final index = _mealPlans.indexWhere((p) => p.id == _currentPlan!.id);
    if (index != -1) {
      _mealPlans[index] = _currentPlan!;
    }

    notifyListeners();
  }

  /// Get all ingredients for today
  List<String> getTodaysIngredients() {
    final today = DateTime.now();
    final meals = getMealsForDate(today);
    final ingredients = <String>{};
    for (final meal in meals) {
      ingredients.addAll(meal.dish.ingredientsList);
    }
    return ingredients.toList()..sort();
  }

  /// Get all ingredients for tomorrow
  List<String> getTomorrowsIngredients() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final meals = getMealsForDate(tomorrow);
    final ingredients = <String>{};
    for (final meal in meals) {
      ingredients.addAll(meal.dish.ingredientsList);
    }
    return ingredients.toList()..sort();
  }

  /// Get all ingredients for upcoming days (next 7 days excluding today and tomorrow)
  List<String> getUpcomingIngredients() {
    final ingredients = <String>{};
    final now = DateTime.now();
    for (int i = 2; i <= 7; i++) {
      final date = now.add(Duration(days: i));
      final meals = getMealsForDate(date);
      for (final meal in meals) {
        ingredients.addAll(meal.dish.ingredientsList);
      }
    }
    // Remove ingredients already in today's or tomorrow's list
    final todaysIngredients = getTodaysIngredients().toSet();
    final tomorrowsIngredients = getTomorrowsIngredients().toSet();
    ingredients.removeAll(todaysIngredients);
    ingredients.removeAll(tomorrowsIngredients);
    return ingredients.toList()..sort();
  }

  /// Set current plan
  void setCurrentPlan(MealPlan plan) {
    _currentPlan = plan;
    notifyListeners();
  }

  /// Create a new meal plan
  void createMealPlan(String name, DateTime weekStartDate) {
    final newPlan = MealPlan(
      id: 'plan-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      weekStartDate: weekStartDate,
    );
    _mealPlans.add(newPlan);
    _currentPlan = newPlan;
    notifyListeners();
  }
}
