import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/models/planned_meal.dart';
import 'package:meal_plan/data/providers/meal_plan_provider.dart';
import 'package:meal_plan/presentation/screens/meal_decider_screen.dart';
import 'package:meal_plan/presentation/screens/planned_meal_view_screen.dart';
import 'package:meal_plan/presentation/screens/select_dish_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _username;
  bool _isLoadingUser = true;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _loadUserData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
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

  void _setupMeal(String mealType) async {
    final dish = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDishScreen(mealType: mealType),
      ),
    );

    if (dish == null || !mounted) return;

    await context.read<MealPlanProvider>().saveMeal(DateTime.now(), mealType, dish.name, dishId: dish.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dish.name} set for $mealType'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _showMealOptions(String mealType, String mealName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mealType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mealName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildOptionTile(
              icon: Icons.swap_horiz,
              iconColor: AppColors.primary,
              bgColor: AppColors.primary.withValues(alpha: 0.1),
              title: 'Change meal',
              subtitle: 'Pick a different dish',
              onTap: () {
                Navigator.pop(context);
                _setupMeal(mealType);
              },
            ),
            const SizedBox(height: 8),
            _buildOptionTile(
              icon: Icons.delete_outline,
              iconColor: AppColors.error,
              bgColor: AppColors.error.withValues(alpha: 0.1),
              title: 'Remove meal',
              subtitle: 'Clear this meal slot',
              onTap: () {
                Navigator.pop(context);
                _removeMeal(mealType);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey200),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeMeal(String mealType) async {
    await context.read<MealPlanProvider>().removeMeal(DateTime.now(), mealType);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$mealType removed'),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _onRefresh() async {
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
    final todayPlannedMeals = context.watch<MealPlanProvider>().getPlannedMealsMapForDate(DateTime.now()) ?? <String, PlannedMeal>{};

    if (_isLoadingUser) {
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
        body: _buildSkeletonBody(),
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
                    plannedMeal: todayPlannedMeals['breakfast'],
                    icon: Icons.breakfast_dining,
                    color: const Color(0xFFFFF3E0),
                    iconColor: const Color(0xFFFF9800),
                  ),
                  const SizedBox(height: 8),
                  _buildMealCard(
                    mealType: 'Lunch',
                    plannedMeal: todayPlannedMeals['lunch'],
                    icon: Icons.lunch_dining,
                    color: const Color(0xFFE8F5E9),
                    iconColor: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 8),
                  _buildMealCard(
                    mealType: 'Dinner',
                    plannedMeal: todayPlannedMeals['dinner'],
                    icon: Icons.dinner_dining,
                    color: const Color(0xFFE3F2FD),
                    iconColor: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 8),
                  _buildMealCard(
                    mealType: 'Snack',
                    plannedMeal: todayPlannedMeals['snack'],
                    icon: Icons.cookie_outlined,
                    color: const Color(0xFFF3E5F5),
                    iconColor: const Color(0xFF9C27B0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildMealCard({
    required String mealType,
    required PlannedMeal? plannedMeal,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    final isNotPlanned = plannedMeal == null;
    final mealName = plannedMeal?.dish.name;

    return GestureDetector(
      onTap: isNotPlanned
          ? () => _setupMeal(mealType)
          : () {
              final dish = plannedMeal.dish;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlannedMealViewScreen(
                    dishName: dish.name,
                    mealType: mealType,
                    category: dish.category,
                    ingredients: dish.ingredients,
                    description: dish.description,
                    mainIngredient: dish.mainIngredient,
                    tags: dish.tags,
                    optionalIngredients: dish.optionalIngredients,
                    date: DateTime.now(),
                  ),
                ),
              );
            },
      onLongPress: isNotPlanned
          ? null
          : () => _showMealOptions(mealType, mealName!),
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
                        mealName!,
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
                  onPressed: () => _showMealOptions(mealType, mealName!),
                  icon: Icon(
                    Icons.more_vert,
                    color: AppColors.grey,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
        ],
      ),
      ),
    );
  }

  // ---- Skeleton Loading ----

  Widget _buildSkeletonBody() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting skeleton
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _skeletonBox(width: 220, height: 22, radius: 6),
                    const SizedBox(height: 10),
                    _skeletonBox(width: 180, height: 14, radius: 4),
                  ],
                ),
              ),
              // Today's meals title skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _skeletonBox(width: 120, height: 16, radius: 4),
              ),
              const SizedBox(height: 12),
              // Meal card skeletons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _skeletonMealCard(),
                    const SizedBox(height: 8),
                    _skeletonMealCard(),
                    const SizedBox(height: 8),
                    _skeletonMealCard(),
                    const SizedBox(height: 8),
                    _skeletonMealCard(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Quick actions skeleton
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(child: _skeletonBox(height: 48, radius: 12)),
                    const SizedBox(width: 12),
                    Expanded(child: _skeletonBox(height: 48, radius: 12)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _skeletonMealCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          _skeletonBox(width: 40, height: 40, radius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 60, height: 11, radius: 3),
                const SizedBox(height: 6),
                _skeletonBox(width: 140, height: 14, radius: 4),
              ],
            ),
          ),
          _skeletonBox(width: 50, height: 14, radius: 4),
        ],
      ),
    );
  }

  Widget _skeletonBox({
    double? width,
    double height = 16,
    double radius = 6,
  }) {
    final shimmerValue = _shimmerController.value;
    final baseColor = AppColors.grey200;
    final highlightColor = AppColors.grey100;
    final color = Color.lerp(
      baseColor,
      highlightColor,
      (0.5 + 0.5 * (1.0 - (2.0 * (shimmerValue - 0.5)).abs())),
    )!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
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
