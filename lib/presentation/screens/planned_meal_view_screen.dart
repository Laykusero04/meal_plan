import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/providers/meal_plan_provider.dart';
import 'package:meal_plan/presentation/screens/select_dish_screen.dart';

class PlannedMealViewScreen extends StatelessWidget {
  final String dishName;
  final String mealType;
  final String category;
  final List<String> ingredients;
  final String description;
  final String mainIngredient;
  final List<String> tags;
  final List<String> optionalIngredients;
  final DateTime date;

  const PlannedMealViewScreen({
    super.key,
    required this.dishName,
    required this.mealType,
    required this.category,
    required this.ingredients,
    this.description = '',
    this.mainIngredient = '',
    this.tags = const [],
    this.optionalIngredients = const [],
    required this.date,
  });

  Color get _mealColor {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return const Color(0xFFFF9800);
      case 'lunch':
        return const Color(0xFF4CAF50);
      case 'dinner':
        return const Color(0xFF2196F3);
      case 'snack':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.primary;
    }
  }

  IconData get _mealIcon {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredientList = ingredients
        .where((e) => e.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Planned Meal',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: _buildBottomActions(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder section
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _mealColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  _mealIcon,
                  size: 80,
                  color: _mealColor.withValues(alpha: 0.5),
                ),
              ),
            ),

            // Dish name, meal type badge, and category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dishName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Description
                  if (description.isNotEmpty) ...[
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Meal type badge + category chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Meal type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _mealColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _mealColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_mealIcon, size: 14, color: _mealColor),
                            const SizedBox(width: 5),
                            Text(
                              mealType,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _mealColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Category chips
                      ...category
                          .split(', ')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .map((cat) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            cat,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Main ingredient section
            if (mainIngredient.isNotEmpty)
              _buildSection(
                title: 'Main Ingredient',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        mainIngredient,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Ingredients section
            if (ingredientList.isNotEmpty)
              _buildSection(
                title: 'Ingredients',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ingredientList.map((ingredient) {
                        final isOptional = optionalIngredients.contains(ingredient);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isOptional
                                ? Colors.orange.withValues(alpha: 0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isOptional ? Colors.orange : AppColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isOptional)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'OPT',
                                    style: TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              Text(
                                ingredient,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isOptional ? Colors.orange : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (optionalIngredients.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Items marked with OPT are optional and can be skipped',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Tags section
            if (tags.isNotEmpty)
              _buildSection(
                title: 'Tags',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Change button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _changeMeal(context),
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Change', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Remove button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _removeMeal(context),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeMeal(BuildContext context) async {
    final dish = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (context) => SelectDishScreen(mealType: mealType),
      ),
    );

    if (dish == null || !context.mounted) return;

    await context.read<MealPlanProvider>().saveMeal(date, mealType, dish.name, dishId: dish.id);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${dish.name} set for $mealType'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _removeMeal(BuildContext context) async {
    await context.read<MealPlanProvider>().removeMeal(date, mealType);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$mealType removed'),
        backgroundColor: AppColors.textSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.pop(context);
  }
}
