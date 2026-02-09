import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/models/planned_meal.dart';
import 'package:meal_plan/data/providers/meal_plan_provider.dart';

class DishDetailsScreen extends StatefulWidget {
  final String dishId;
  final String name;
  final String category;
  final List<String> ingredients;
  final List<String> tags;
  final String? author;
  final bool isPublic;
  final List<String> optionalIngredients;

  const DishDetailsScreen({
    super.key,
    required this.dishId,
    required this.name,
    required this.category,
    required this.ingredients,
    this.tags = const [],
    this.author,
    this.isPublic = false,
    this.optionalIngredients = const [],
  });

  @override
  State<DishDetailsScreen> createState() => _DishDetailsScreenState();
}

class _DishDetailsScreenState extends State<DishDetailsScreen> {
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dish Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.red : AppColors.textPrimary,
            ),
            onPressed: () {
              setState(() {
                _isFavorite = !_isFavorite;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isFavorite
                        ? '${widget.name} added to favorites'
                        : '${widget.name} removed from favorites',
                  ),
                  backgroundColor: AppColors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Container(
              width: double.infinity,
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),

            // Dish name and category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Category chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.category.split(', ').map((cat) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  // Author info
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Created by ${widget.author ?? 'You'}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Ingredients section
            _buildSection(
              title: 'Ingredients',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.ingredients.map((ingredient) {
                      final isOptional = widget.optionalIngredients.contains(ingredient);
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
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
                  if (widget.optionalIngredients.isNotEmpty) ...[
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
            if (widget.tags.isNotEmpty)
              _buildSection(
                title: 'Tags',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
      bottomNavigationBar: Container(
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
          child: ElevatedButton.icon(
            onPressed: () {
              _showAddToPlanDialog();
            },
            icon: const Icon(Icons.calendar_today, size: 18),
            label: const Text(
              'Add to Plan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
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

  void _showAddToPlanDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add to which meal?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildMealOption(sheetContext, 'Breakfast', MealType.breakfast, Icons.breakfast_dining, const Color(0xFFFF9800)),
            _buildMealOption(sheetContext, 'Lunch', MealType.lunch, Icons.lunch_dining, const Color(0xFF4CAF50)),
            _buildMealOption(sheetContext, 'Dinner', MealType.dinner, Icons.dinner_dining, const Color(0xFF2196F3)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMealOption(BuildContext sheetContext, String mealLabel, MealType mealType, IconData icon, Color color) {
    return ListTile(
      onTap: () {
        Navigator.pop(sheetContext);

        // Save to today's meal plan via Firestore
        final mealPlanProvider = context.read<MealPlanProvider>();
        mealPlanProvider.saveMeal(DateTime.now(), mealType.name, widget.name, dishId: widget.dishId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.name} added to $mealLabel'),
            backgroundColor: AppColors.primary,
          ),
        );
      },
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        mealLabel,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
    );
  }
}
