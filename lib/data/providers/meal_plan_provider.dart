import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import 'dish_provider.dart';

class MealPlanProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<MealPlan> _mealPlans = [];
  MealPlan? _currentPlan;
  DishProvider? _dishProvider;
  StreamSubscription<QuerySnapshot>? _mealsSubscription;
  StreamSubscription<User?>? _authSubscription;

  List<MealPlan> get mealPlans => List.unmodifiable(_mealPlans);
  MealPlan? get currentPlan => _currentPlan;

  MealPlanProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToMeals();
      } else {
        _mealsSubscription?.cancel();
        _mealPlans.clear();
        _currentPlan = null;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _mealsSubscription?.cancel();
    super.dispose();
  }

  /// Called by ProxyProvider when DishProvider updates
  void update(DishProvider dishProvider) {
    final hadProvider = _dishProvider != null;
    _dishProvider = dishProvider;
    // If DishProvider just loaded dishes, rebuild meal plans
    if (!hadProvider || dishProvider.allDishes.isNotEmpty) {
      _rebuildFromCache();
    }
  }

  // Cache the raw Firestore data so we can rebuild when DishProvider updates
  List<Map<String, dynamic>> _rawMealsCache = [];

  void _listenToMeals() {
    final user = _auth.currentUser;
    if (user == null) return;

    _mealsSubscription?.cancel();
    _mealsSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planned_meals')
        .snapshots()
        .listen((snapshot) {
      _rawMealsCache = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
      _rebuildFromCache();
    });
  }

  void _rebuildFromCache() {
    final meals = <PlannedMeal>[];

    for (final data in _rawMealsCache) {
      final dishName = data['dishName'] as String?;
      final dishId = data['dishId'] as String?;
      final mealTypeStr = data['mealType'] as String?;
      final date = data['date'] as Timestamp?;
      final id = data['id'] as String?;

      if (dishName == null || mealTypeStr == null || date == null || id == null) continue;

      final mealType = _parseMealType(mealTypeStr);
      final dish = _resolveDish(dishName, dishId: dishId);

      meals.add(PlannedMeal(
        id: id,
        dish: dish,
        mealType: mealType,
        date: date.toDate(),
      ));
    }

    // Build a single MealPlan containing all meals
    final now = DateTime.now();
    final daysToMonday = now.weekday - 1;
    final weekStart = DateTime(now.year, now.month, now.day - daysToMonday);

    _currentPlan = MealPlan(
      id: 'synced-plan',
      name: 'Current Plan',
      weekStartDate: weekStart,
      meals: meals,
    );

    _mealPlans.clear();
    _mealPlans.add(_currentPlan!);
    notifyListeners();
  }

  MealType _parseMealType(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return MealType.breakfast;
      case 'lunch':
        return MealType.lunch;
      case 'dinner':
        return MealType.dinner;
      case 'snack':
        return MealType.snack;
      default:
        return MealType.dinner;
    }
  }

  Dish _resolveDish(String dishName, {String? dishId}) {
    if (_dishProvider != null) {
      // Prefer ID-based lookup (stable across renames)
      if (dishId != null) {
        final match = _dishProvider!.allDishes.where((d) => d.id == dishId);
        if (match.isNotEmpty) return match.first;
      }
      // Fallback to name-based lookup (for old data without dishId)
      final matches = _dishProvider!.allDishes.where((d) => d.name == dishName);
      if (matches.isNotEmpty) return matches.first;
    }
    // Fallback: stub dish with just the name
    return Dish(
      id: dishId ?? 'stub-${dishName.hashCode}',
      name: dishName,
      category: '',
    );
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

  /// Get a map of mealType -> dishName for a specific date
  /// Returns null if no meals are planned for that date.
  Map<String, String>? getMealMapForDate(DateTime date) {
    if (_currentPlan == null) return null;
    final meals = _currentPlan!.getMealsForDate(date);
    if (meals.isEmpty) return null;
    final map = <String, String>{};
    for (final meal in meals) {
      map[meal.mealType.name] = meal.dish.name;
    }
    return map;
  }

  /// Get a map of mealType -> PlannedMeal for a specific date.
  /// Use this when you need full dish data (ingredients, category, etc.).
  Map<String, PlannedMeal>? getPlannedMealsMapForDate(DateTime date) {
    if (_currentPlan == null) return null;
    final meals = _currentPlan!.getMealsForDate(date);
    if (meals.isEmpty) return null;
    final map = <String, PlannedMeal>{};
    for (final meal in meals) {
      map[meal.mealType.name] = meal;
    }
    return map;
  }

  /// Save a meal to Firestore (replaces any existing meal for the same date+type).
  /// The snapshot listener will automatically update local state.
  Future<void> saveMeal(DateTime date, String mealType, String dishName, {String? dishId}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final collection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planned_meals');

    // Delete existing meal for same date + mealType
    final existing = await collection
        .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
        .where('mealType', isEqualTo: mealType.toLowerCase())
        .get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }

    // Save new meal
    await collection.add({
      'dishName': dishName,
      if (dishId != null) 'dishId': dishId,
      'mealType': mealType.toLowerCase(),
      'date': Timestamp.fromDate(dateOnly),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove a meal from Firestore by date and meal type.
  /// The snapshot listener will automatically update local state.
  Future<void> removeMeal(DateTime date, String mealType) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final collection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planned_meals');

    final existing = await collection
        .where('date', isEqualTo: Timestamp.fromDate(dateOnly))
        .where('mealType', isEqualTo: mealType.toLowerCase())
        .get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }
  }

  /// Get all ingredients for today
  List<String> getTodaysIngredients() {
    final today = DateTime.now();
    final meals = getMealsForDate(today);
    final ingredients = <String>{};
    for (final meal in meals) {
      ingredients.addAll(meal.dish.ingredients);
    }
    return ingredients.toList()..sort();
  }

  /// Get all ingredients for tomorrow
  List<String> getTomorrowsIngredients() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final meals = getMealsForDate(tomorrow);
    final ingredients = <String>{};
    for (final meal in meals) {
      ingredients.addAll(meal.dish.ingredients);
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
        ingredients.addAll(meal.dish.ingredients);
      }
    }
    // Remove ingredients already in today's or tomorrow's list
    final todaysIngredients = getTodaysIngredients().toSet();
    final tomorrowsIngredients = getTomorrowsIngredients().toSet();
    ingredients.removeAll(todaysIngredients);
    ingredients.removeAll(tomorrowsIngredients);
    return ingredients.toList()..sort();
  }

}
