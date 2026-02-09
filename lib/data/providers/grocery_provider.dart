import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroceryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  /// Items the user has in their pantry
  final Set<String> _pantryItems = {};

  /// Items that have been checked off the grocery list
  final Map<String, bool> _checkedItems = {};

  /// Items that are skipped/unavailable
  final Set<String> _skippedItems = {};

  /// Whether to show pantry items in the grocery list
  bool _showPantryItems = false;

  Set<String> get pantryItems => Set.unmodifiable(_pantryItems);
  Map<String, bool> get checkedItems => Map.unmodifiable(_checkedItems);
  Set<String> get skippedItems => Set.unmodifiable(_skippedItems);
  bool get showPantryItems => _showPantryItems;

  GroceryProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadState();
      } else {
        _pantryItems.clear();
        _checkedItems.clear();
        _skippedItems.clear();
        _showPantryItems = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Load grocery state from Firestore
  Future<void> _loadState() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('grocery_state')
          .doc('state')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _pantryItems.clear();
        _pantryItems.addAll(List<String>.from(data['pantryItems'] ?? []));

        _checkedItems.clear();
        final checkedMap = data['checkedItems'] as Map<String, dynamic>?;
        if (checkedMap != null) {
          for (final entry in checkedMap.entries) {
            _checkedItems[entry.key] = entry.value as bool;
          }
        }

        _skippedItems.clear();
        _skippedItems.addAll(List<String>.from(data['skippedItems'] ?? []));

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading grocery state: $e');
    }
  }

  /// Save grocery state to Firestore
  Future<void> _saveState() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('grocery_state')
          .doc('state')
          .set({
        'pantryItems': _pantryItems.toList(),
        'checkedItems': _checkedItems,
        'skippedItems': _skippedItems.toList(),
      });
    } catch (e) {
      debugPrint('Error saving grocery state: $e');
    }
  }

  /// Check if an item is in pantry
  bool isInPantry(String item) => _pantryItems.contains(item);

  /// Check if an item is checked
  bool isChecked(String item) => _checkedItems[item] ?? false;

  /// Check if an item is skipped
  bool isSkipped(String item) => _skippedItems.contains(item);

  /// Toggle an item's checked status
  void toggleChecked(String item) {
    _checkedItems[item] = !(_checkedItems[item] ?? false);
    notifyListeners();
    _saveState();
  }

  /// Set an item's checked status
  void setChecked(String item, bool checked) {
    _checkedItems[item] = checked;
    notifyListeners();
    _saveState();
  }

  /// Add an item to pantry
  void addToPantry(String item) {
    _pantryItems.add(item);
    notifyListeners();
    _saveState();
  }

  /// Remove an item from pantry
  void removeFromPantry(String item) {
    _pantryItems.remove(item);
    notifyListeners();
    _saveState();
  }

  /// Toggle an item's pantry status
  void togglePantry(String item) {
    if (_pantryItems.contains(item)) {
      _pantryItems.remove(item);
    } else {
      _pantryItems.add(item);
    }
    notifyListeners();
    _saveState();
  }

  /// Skip an item
  void skipItem(String item) {
    _skippedItems.add(item);
    notifyListeners();
    _saveState();
  }

  /// Unskip an item
  void unskipItem(String item) {
    _skippedItems.remove(item);
    notifyListeners();
    _saveState();
  }

  /// Toggle an item's skipped status
  void toggleSkipped(String item) {
    if (_skippedItems.contains(item)) {
      _skippedItems.remove(item);
    } else {
      _skippedItems.add(item);
    }
    notifyListeners();
    _saveState();
  }

  /// Toggle showing pantry items
  void toggleShowPantryItems() {
    _showPantryItems = !_showPantryItems;
    notifyListeners();
  }

  /// Set whether to show pantry items
  void setShowPantryItems(bool show) {
    _showPantryItems = show;
    notifyListeners();
  }

  /// Filter ingredients based on pantry and skip settings
  List<String> filterIngredients(List<String> ingredients) {
    return ingredients.where((item) {
      if (!_showPantryItems && _pantryItems.contains(item)) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Calculate progress for a list of ingredients
  double calculateProgress(List<String> ingredients) {
    if (ingredients.isEmpty) return 0.0;
    final filteredIngredients = filterIngredients(ingredients);
    if (filteredIngredients.isEmpty) return 1.0;

    int completed = 0;
    for (final item in filteredIngredients) {
      if (_checkedItems[item] == true || _skippedItems.contains(item)) {
        completed++;
      }
    }
    return completed / filteredIngredients.length;
  }

  /// Reset all checked items
  void resetCheckedItems() {
    _checkedItems.clear();
    notifyListeners();
    _saveState();
  }

  /// Reset all skipped items
  void resetSkippedItems() {
    _skippedItems.clear();
    notifyListeners();
    _saveState();
  }
}
