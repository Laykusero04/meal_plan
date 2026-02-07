import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/providers/dish_provider.dart';
import 'package:meal_plan/presentation/screens/dish_details_screen.dart';
import 'package:meal_plan/presentation/screens/meal_decider_screen.dart';
import 'package:meal_plan/presentation/screens/select_dish_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _username;
  bool _isLoadingUser = true;
  Map<String, String> _todayMeals = {};
  StreamSubscription? _mealsSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _listenToTodayMeals();
  }

  @override
  void dispose() {
    _mealsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!mounted) return;
        if (userDoc.exists) {
          setState(() {
            _username = userDoc.data()?['username'] ?? 'User';
            _isLoadingUser = false;
          });
        } else {
          setState(() {
            _username = user.email?.split('@')[0] ?? 'User';
            _isLoadingUser = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _listenToTodayMeals() {
    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    _mealsSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planned_meals')
        .where('date', isEqualTo: Timestamp.fromDate(todayStart))
        .snapshots()
        .listen((snapshot) {
      final Map<String, String> meals = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final mealType = data['mealType'] as String?;
        final dishName = data['dishName'] as String?;
        if (mealType != null && dishName != null) {
          meals[mealType.toLowerCase()] = dishName;
        }
      }

      if (!mounted) return;
      setState(() {
        _todayMeals = meals;
      });
    });
  }

  void _setupMeal(String mealType) async {
    final dish = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDishScreen(mealType: mealType),
      ),
    );

    if (dish == null || !mounted) return;

    final user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final collection = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('planned_meals');

    // Delete existing meal for same date + mealType
    final existing = await collection
        .where('date', isEqualTo: Timestamp.fromDate(todayStart))
        .where('mealType', isEqualTo: mealType.toLowerCase())
        .get();
    for (final doc in existing.docs) {
      await doc.reference.delete();
    }

    // Save new meal
    await collection.add({
      'dishName': dish.name,
      'mealType': mealType.toLowerCase(),
      'date': Timestamp.fromDate(todayStart),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (!mounted) return;
    // No need to manually update _todayMeals - the stream listener handles it

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dish.name} set for $mealType'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _onRefresh() async {
    _mealsSubscription?.cancel();
    _listenToTodayMeals();
    await _loadUserData();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUser) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: const Text(
            'MealPlan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2ECC71),
        title: const Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        toolbarHeight: 56,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()}, $_username',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Let's plan something delicious",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.casino,
                      label: 'Spin Meal',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MealDeciderScreen(),
                          ),
                        );
                      },
                      isPrimary: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add_circle_outline,
                      label: 'Add Plan',
                      onPressed: () {},
                      isPrimary: false,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Today's Meals Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Meals",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMealCard(
                    mealType: 'Breakfast',
                    mealName: _todayMeals['breakfast'],
                    icon: Icons.breakfast_dining,
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                  ),
                  const SizedBox(height: 8),
                  _buildMealCard(
                    mealType: 'Lunch',
                    mealName: _todayMeals['lunch'],
                    icon: Icons.lunch_dining,
                    color: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 8),
                  _buildMealCard(
                    mealType: 'Dinner',
                    mealName: _todayMeals['dinner'],
                    icon: Icons.dinner_dining,
                    color: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF2196F3),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Tip Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFF9C4).withOpacity(0.8),
                      const Color(0xFFFFF9C4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC107).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Color(0xFFFFC107),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Daily Tip',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Plan your meals ahead to save time and reduce food waste!',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMealCard({
    required String mealType,
    required String? mealName,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    final isNotPlanned = mealName == null;

    return GestureDetector(
      onTap: isNotPlanned
          ? null
          : () {
              final dishProvider = context.read<DishProvider>();
              final matches = dishProvider.allDishes.where((d) => d.name == mealName);
              final dish = matches.isNotEmpty ? matches.first : null;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DishDetailsScreen(
                    name: mealName,
                    category: dish?.category ?? mealType,
                    ingredients: dish?.ingredients ?? '',
                    tags: dish?.tags ?? const [],
                    optionalIngredients: dish?.optionalIngredients ?? const [],
                  ),
                ),
              );
            },
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isNotPlanned ? Colors.grey[100] : color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isNotPlanned ? Colors.grey[400] : iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[500],
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                isNotPlanned
                    ? Text(
                        'No meal planned',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    : Text(
                        mealName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
              ],
            ),
          ),
          isNotPlanned
              ? TextButton(
                  onPressed: () => _setupMeal(mealType),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Set up',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () => _setupMeal(mealType),
                  icon: Icon(
                    Icons.edit_outlined,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
        ],
      ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary
              ? null
              : Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isPrimary ? Colors.white : const Color(0xFF333333),
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPrimary ? Colors.white : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
