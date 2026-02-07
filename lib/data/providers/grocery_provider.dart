import 'package:flutter/foundation.dart';

class GroceryProvider extends ChangeNotifier {
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
  }

  /// Set an item's checked status
  void setChecked(String item, bool checked) {
    _checkedItems[item] = checked;
    notifyListeners();
  }

  /// Add an item to pantry
  void addToPantry(String item) {
    _pantryItems.add(item);
    notifyListeners();
  }

  /// Remove an item from pantry
  void removeFromPantry(String item) {
    _pantryItems.remove(item);
    notifyListeners();
  }

  /// Toggle an item's pantry status
  void togglePantry(String item) {
    if (_pantryItems.contains(item)) {
      _pantryItems.remove(item);
    } else {
      _pantryItems.add(item);
    }
    notifyListeners();
  }

  /// Skip an item
  void skipItem(String item) {
    _skippedItems.add(item);
    notifyListeners();
  }

  /// Unskip an item
  void unskipItem(String item) {
    _skippedItems.remove(item);
    notifyListeners();
  }

  /// Toggle an item's skipped status
  void toggleSkipped(String item) {
    if (_skippedItems.contains(item)) {
      _skippedItems.remove(item);
    } else {
      _skippedItems.add(item);
    }
    notifyListeners();
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
  }

  /// Reset all skipped items
  void resetSkippedItems() {
    _skippedItems.clear();
    notifyListeners();
  }
}
