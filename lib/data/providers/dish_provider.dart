import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dish.dart';

class DishProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Dish> _myDishes = [];
  final List<Dish> _publicDishes = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Dish> get myDishes => List.unmodifiable(_myDishes);
  List<Dish> get publicDishes => List.unmodifiable(_publicDishes);
  List<Dish> get allDishes => [..._myDishes, ..._publicDishes];

  DishProvider() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        fetchDishes();
        fetchIngredients();
      } else {
        _myDishes.clear();
        _publicDishes.clear();
        _ingredients.clear();
        notifyListeners();
      }
    });
  }

  /// Fetch both user dishes and public dishes from Firestore
  Future<void> fetchDishes() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Fetch my dishes
      final mySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dishes')
          .orderBy('createdAt', descending: true)
          .get();

      _myDishes.clear();
      for (final doc in mySnapshot.docs) {
        _myDishes.add(_dishFromFirestore(doc));
      }

      // Fetch public dishes
      final publicSnapshot = await _firestore
          .collection('public_dishes')
          .orderBy('createdAt', descending: true)
          .get();

      _publicDishes.clear();
      for (final doc in publicSnapshot.docs) {
        _publicDishes.add(_dishFromFirestore(doc));
      }
    } catch (e) {
      debugPrint('Error fetching dishes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Dish _dishFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Handle both old String format and new List format for ingredients
    final rawIngredients = data['ingredients'];
    final List<String> ingredients;
    if (rawIngredients is List) {
      ingredients = List<String>.from(rawIngredients);
    } else if (rawIngredients is String && rawIngredients.isNotEmpty) {
      ingredients = rawIngredients.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    } else {
      ingredients = [];
    }
    return Dish(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      mainIngredient: data['mainIngredient'] ?? '',
      ingredients: ingredients,
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      author: data['author'],
      imageUrl: data['imageUrl'],
      optionalIngredients: List<String>.from(data['optionalIngredients'] ?? []),
      isPublic: data['isPublic'] ?? false,
    );
  }

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
          dish.ingredients.any((i) => i.toLowerCase().contains(searchQuery.toLowerCase()));
      final matchesCategory =
          category == null || category == 'All' || dish.category == category;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Add a new dish to my dishes and save to Firestore
  Future<void> addDish(Dish dish) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final ref = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dishes')
          .doc();

      await ref.set({
        'name': dish.name,
        'description': dish.description,
        'mainIngredient': dish.mainIngredient,
        'ingredients': dish.ingredients,
        'category': dish.category,
        'tags': dish.tags,
        'optionalIngredients': dish.optionalIngredients,
        'isPublic': dish.isPublic,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _myDishes.insert(0, dish.copyWith(id: ref.id));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding dish: $e');
    }
  }

  /// Update an existing dish in Firestore
  Future<void> updateDish(String id, Dish updatedDish) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dishes')
          .doc(id)
          .update({
        'name': updatedDish.name,
        'description': updatedDish.description,
        'mainIngredient': updatedDish.mainIngredient,
        'ingredients': updatedDish.ingredients,
        'category': updatedDish.category,
        'tags': updatedDish.tags,
        'optionalIngredients': updatedDish.optionalIngredients,
        'isPublic': updatedDish.isPublic,
      });

      final index = _myDishes.indexWhere((d) => d.id == id);
      if (index != -1) {
        _myDishes[index] = updatedDish;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating dish: $e');
    }
  }

  /// Delete a dish from Firestore
  Future<void> deleteDish(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('dishes')
          .doc(id)
          .delete();

      _myDishes.removeWhere((d) => d.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting dish: $e');
    }
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

  // ---- Ingredients Management ----

  final List<String> _ingredients = [];
  List<String> get ingredients => List.unmodifiable(_ingredients);

  /// Fetch ingredients from Firestore
  Future<void> fetchIngredients() async {
    try {
      final snapshot = await _firestore
          .collection('ingredients')
          .orderBy('name')
          .get();

      _ingredients.clear();
      for (final doc in snapshot.docs) {
        final name = doc.data()['name'] as String?;
        if (name != null && name.isNotEmpty) {
          _ingredients.add(name);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching ingredients: $e');
    }
  }

}
