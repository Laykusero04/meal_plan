import 'package:flutter/foundation.dart';
import '../models/dish.dart';

class DishProvider extends ChangeNotifier {
  final List<Dish> _myDishes = [
    Dish(
      id: 'my-1',
      name: 'Chicken Adobo',
      ingredients: 'Chicken, Soy Sauce, Vinegar, Garlic, Bay Leaves',
      category: 'Lunch',
      tags: [],
      optionalIngredients: ['Bay Leaves'],
    ),
    Dish(
      id: 'my-2',
      name: 'Veggie Omelette',
      ingredients: 'Egg, Bell Pepper, Onion, Cheese, Salt',
      category: 'Breakfast',
      tags: ['Vegetarian'],
      optionalIngredients: ['Cheese'],
    ),
    Dish(
      id: 'my-3',
      name: 'Beef Steak',
      ingredients: 'Beef, Garlic, Butter, Rosemary, Salt, Pepper',
      category: 'Dinner',
      tags: ['Low-carb'],
      optionalIngredients: ['Rosemary'],
    ),
    Dish(
      id: 'my-4',
      name: 'Fried Rice',
      ingredients: 'Rice, Egg, Vegetables, Soy Sauce, Garlic',
      category: 'Lunch',
      tags: [],
      optionalIngredients: ['Vegetables'],
    ),
    Dish(
      id: 'my-5',
      name: 'Scrambled Eggs & Toast',
      ingredients: 'Eggs, Bread, Butter, Salt, Pepper',
      category: 'Breakfast',
      optionalIngredients: ['Pepper'],
    ),
    Dish(
      id: 'my-6',
      name: 'Pancakes',
      ingredients: 'Flour, Eggs, Milk, Sugar, Butter',
      category: 'Breakfast',
      optionalIngredients: ['Sugar'],
    ),
    Dish(
      id: 'my-7',
      name: 'Grilled Chicken Salad',
      ingredients: 'Chicken Breast, Lettuce, Tomatoes, Olive Oil, Lemon',
      category: 'Lunch',
      optionalIngredients: ['Lemon'],
    ),
    Dish(
      id: 'my-8',
      name: 'Pasta Carbonara',
      ingredients: 'Pasta, Bacon, Eggs, Parmesan, Pepper',
      category: 'Dinner',
    ),
    Dish(
      id: 'my-9',
      name: 'Beef Stir Fry',
      ingredients: 'Beef, Bell Pepper, Onion, Soy Sauce, Garlic',
      category: 'Dinner',
      optionalIngredients: ['Bell Pepper'],
    ),
    Dish(
      id: 'my-10',
      name: 'Vegetable Soup',
      ingredients: 'Carrots, Celery, Onion, Tomato, Herbs',
      category: 'Lunch',
      optionalIngredients: ['Herbs'],
    ),
    Dish(
      id: 'my-11',
      name: 'Oatmeal with Fruits',
      ingredients: 'Oats, Milk, Banana, Honey',
      category: 'Breakfast',
      optionalIngredients: ['Honey'],
    ),
  ];

  final List<Dish> _publicDishes = [
    Dish(
      id: 'pub-1',
      name: 'Avocado Toast',
      ingredients: 'Avocado, Bread, Lemon, Salt, Red Pepper Flakes',
      category: 'Breakfast',
      tags: ['Vegetarian'],
      author: 'Chef Maria',
      optionalIngredients: ['Red Pepper Flakes', 'Lemon'],
      isPublic: true,
    ),
    Dish(
      id: 'pub-2',
      name: 'Caesar Salad',
      ingredients: 'Lettuce, Croutons, Parmesan, Dressing, Chicken',
      category: 'Lunch',
      tags: [],
      author: 'FoodLover99',
      optionalIngredients: ['Chicken'],
      isPublic: true,
    ),
    Dish(
      id: 'pub-3',
      name: 'Spaghetti Bolognese',
      ingredients: 'Pasta, Beef, Tomato, Onion, Garlic, Parmesan',
      category: 'Dinner',
      tags: [],
      author: 'ItalianNonna',
      optionalIngredients: ['Parmesan'],
      isPublic: true,
    ),
    Dish(
      id: 'pub-4',
      name: 'Pancakes',
      ingredients: 'Flour, Eggs, Milk, Sugar, Butter, Maple Syrup',
      category: 'Breakfast',
      tags: ['Vegetarian'],
      author: 'BreakfastKing',
      optionalIngredients: ['Maple Syrup'],
      isPublic: true,
    ),
    Dish(
      id: 'pub-5',
      name: 'Grilled Salmon',
      ingredients: 'Salmon, Lemon, Herbs, Olive Oil, Salt',
      category: 'Dinner',
      tags: ['Low-carb'],
      author: 'SeafoodChef',
      optionalIngredients: ['Herbs'],
      isPublic: true,
    ),
    Dish(
      id: 'pub-6',
      name: 'Chicken Teriyaki',
      ingredients: 'Chicken, Soy Sauce, Mirin, Ginger, Garlic',
      category: 'Dinner',
      author: 'AsianCuisine',
      isPublic: true,
    ),
    Dish(
      id: 'pub-7',
      name: 'Greek Yogurt Parfait',
      ingredients: 'Greek Yogurt, Granola, Berries, Honey',
      category: 'Breakfast',
      author: 'HealthyEats',
      optionalIngredients: ['Honey', 'Granola'],
      isPublic: true,
    ),
    Dish(
      id: 'pub-8',
      name: 'Fish Tacos',
      ingredients: 'Fish, Tortillas, Cabbage, Lime, Cilantro',
      category: 'Lunch',
      author: 'MexicanChef',
      optionalIngredients: ['Cilantro'],
      isPublic: true,
    ),
    Dish(
      id: 'pub-9',
      name: 'Vegetable Curry',
      ingredients: 'Mixed Vegetables, Coconut Milk, Curry Paste, Rice',
      category: 'Dinner',
      author: 'SpiceMaster',
      isPublic: true,
    ),
  ];

  List<Dish> get myDishes => List.unmodifiable(_myDishes);
  List<Dish> get publicDishes => List.unmodifiable(_publicDishes);
  List<Dish> get allDishes => [..._myDishes, ..._publicDishes];

  /// Filter dishes by category and search query
  List<Dish> filterDishes(
    List<Dish> dishes, {
    String? searchQuery,
    String? category,
  }) {
    return dishes.where((dish) {
      final matchesSearch = searchQuery == null ||
          searchQuery.isEmpty ||
          dish.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          dish.ingredients.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          category == null || category == 'All' || dish.category == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Add a new dish to my dishes
  void addDish(Dish dish) {
    _myDishes.add(dish);
    notifyListeners();
  }

  /// Update an existing dish
  void updateDish(String id, Dish updatedDish) {
    final index = _myDishes.indexWhere((d) => d.id == id);
    if (index != -1) {
      _myDishes[index] = updatedDish;
      notifyListeners();
    }
  }

  /// Delete a dish
  void deleteDish(String id) {
    _myDishes.removeWhere((d) => d.id == id);
    notifyListeners();
  }

  /// Get dish by ID
  Dish? getDishById(String id) {
    try {
      return allDishes.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Generate a unique ID for new dishes
  String generateId() {
    return 'my-${DateTime.now().millisecondsSinceEpoch}';
  }
}
