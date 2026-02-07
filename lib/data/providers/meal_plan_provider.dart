import 'package:flutter/foundation.dart';
import '../models/models.dart';

class MealPlanProvider extends ChangeNotifier {
  final List<MealPlan> _mealPlans = [];
  MealPlan? _currentPlan;

  List<MealPlan> get mealPlans => List.unmodifiable(_mealPlans);
  MealPlan? get currentPlan => _currentPlan;

  MealPlanProvider();

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
