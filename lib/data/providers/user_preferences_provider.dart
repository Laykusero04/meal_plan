import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  String _mealGoal = '';
  String _dietType = '';
  List<String> _preferredIngredients = [];
  bool _isLoaded = false;

  String get mealGoal => _mealGoal;
  String get dietType => _dietType;
  List<String> get preferredIngredients => List.unmodifiable(_preferredIngredients);
  bool get isLoaded => _isLoaded;

  /// Whether the user has an active diet filter (anything other than '' or 'None')
  bool get hasDietFilter => _dietType.isNotEmpty && _dietType != 'None';

  UserPreferencesProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadPreferences();
      } else {
        _mealGoal = '';
        _dietType = '';
        _preferredIngredients = [];
        _isLoaded = false;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _mealGoal = data['mealGoal'] as String? ?? '';
        _dietType = data['dietType'] as String? ?? '';
        _preferredIngredients = List<String>.from(data['preferredIngredients'] ?? []);
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> savePreferences({
    required String mealGoal,
    required String dietType,
    required List<String> ingredients,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'mealGoal': mealGoal,
      'dietType': dietType,
      'preferredIngredients': ingredients,
    }, SetOptions(merge: true));

    _mealGoal = mealGoal;
    _dietType = dietType;
    _preferredIngredients = ingredients;
    notifyListeners();
  }
}
