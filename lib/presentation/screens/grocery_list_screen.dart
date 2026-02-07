import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/providers/grocery_provider.dart';
import 'package:meal_plan/data/providers/meal_plan_provider.dart';

class GroceryListScreen extends StatelessWidget {
  const GroceryListScreen({super.key});

  void _showIngredientOptionsSheet(
    BuildContext context,
    String ingredient,
    Color sectionColor,
  ) {
    final groceryProvider = context.read<GroceryProvider>();
    final isSkipped = groceryProvider.isSkipped(ingredient);
    final isInPantry = groceryProvider.isInPantry(ingredient);

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
            Text(
              ingredient,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              onTap: () {
                Navigator.pop(sheetContext);
                if (isSkipped) {
                  groceryProvider.unskipItem(ingredient);
                } else {
                  groceryProvider.skipItem(ingredient);
                  groceryProvider.setChecked(ingredient, false);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isSkipped
                          ? '$ingredient added back to list'
                          : '$ingredient marked as unavailable',
                    ),
                    backgroundColor: isSkipped ? AppColors.primary : Colors.grey[600],
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: Colors.white,
                      onPressed: () {
                        if (isSkipped) {
                          groceryProvider.skipItem(ingredient);
                        } else {
                          groceryProvider.unskipItem(ingredient);
                        }
                      },
                    ),
                  ),
                );
              },
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSkipped
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isSkipped ? Icons.add_circle_outline : Icons.remove_circle_outline,
                  color: isSkipped ? AppColors.primary : Colors.grey[600],
                  size: 20,
                ),
              ),
              title: Text(
                isSkipped ? 'Add back to list' : 'Not available / Skip',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                isSkipped
                    ? 'Item will be shown in your shopping list'
                    : 'Item not in store or not needed',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            if (!isInPantry)
              ListTile(
                onTap: () {
                  Navigator.pop(sheetContext);
                  groceryProvider.addToPantry(ingredient);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$ingredient added to pantry'),
                      backgroundColor: const Color(0xFFFF8F00),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () {
                          groceryProvider.removeFromPantry(ingredient);
                        },
                      ),
                    ),
                  );
                },
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.home_work,
                    color: Color(0xFFFF8F00),
                    size: 20,
                  ),
                ),
                title: const Text(
                  'Add to Pantry',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                subtitle: Text(
                  'Mark as item you always have at home',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showPantryManagementSheet(BuildContext context) {
    final groceryProvider = context.read<GroceryProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, scrollController) => PantryManagementSheet(
          groceryProvider: groceryProvider,
          scrollController: scrollController,
        ),
      ),
    );
  }

  List<String> _filterPantryItems(
    List<String> ingredients,
    GroceryProvider groceryProvider,
  ) {
    if (groceryProvider.showPantryItems) {
      return ingredients;
    }
    return ingredients.where((i) => !groceryProvider.isInPantry(i)).toList();
  }

  List<String> _getNeededPantryItems(
    List<String> todayIngredients,
    List<String> tomorrowIngredients,
    List<String> upcomingIngredients,
    GroceryProvider groceryProvider,
  ) {
    final allNeeded = <String>{};
    allNeeded.addAll(todayIngredients);
    allNeeded.addAll(tomorrowIngredients);
    allNeeded.addAll(upcomingIngredients);
    return groceryProvider.pantryItems
        .where((item) => allNeeded.contains(item))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mealPlanProvider = context.watch<MealPlanProvider>();
    final groceryProvider = context.watch<GroceryProvider>();

    final todayIngredients = mealPlanProvider.getTodaysIngredients();
    final tomorrowIngredients = mealPlanProvider.getTomorrowsIngredients();
    final upcomingIngredients = mealPlanProvider.getUpcomingIngredients();

    final neededPantryItems = _getNeededPantryItems(
      todayIngredients,
      tomorrowIngredients,
      upcomingIngredients,
      groceryProvider,
    );

    final todayFiltered = _filterPantryItems(todayIngredients, groceryProvider);
    final tomorrowFiltered = _filterPantryItems(tomorrowIngredients, groceryProvider);
    final upcomingFiltered = _filterPantryItems(upcomingIngredients, groceryProvider);
    final totalItems = todayFiltered.length + tomorrowFiltered.length + upcomingFiltered.length;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Grocery List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.home_work_outlined, color: Colors.white),
            tooltip: 'Manage Pantry',
            onPressed: () => _showPantryManagementSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              groceryProvider.resetCheckedItems();
              groceryProvider.resetSkippedItems();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSummaryCard(context, totalItems, groceryProvider),
            const SizedBox(height: 12),
            _buildPantryInfoCard(context, neededPantryItems, groceryProvider),
            const SizedBox(height: 8),
            _buildIngredientSection(
              context: context,
              title: "Today's Ingredients",
              subtitle: 'For your meals today',
              ingredients: todayFiltered,
              color: AppColors.primary,
              icon: Icons.today,
              groceryProvider: groceryProvider,
            ),
            _buildIngredientSection(
              context: context,
              title: "Tomorrow's Ingredients",
              subtitle: 'Plan ahead for tomorrow',
              ingredients: tomorrowFiltered,
              color: const Color(0xFF2196F3),
              icon: Icons.schedule,
              groceryProvider: groceryProvider,
            ),
            _buildIngredientSection(
              context: context,
              title: 'Upcoming Ingredients',
              subtitle: 'For the rest of the week',
              ingredients: upcomingFiltered,
              color: const Color(0xFFFF9800),
              icon: Icons.calendar_month,
              groceryProvider: groceryProvider,
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int totalItems, GroceryProvider groceryProvider) {
    final checkedCount = groceryProvider.checkedItems.values.where((v) => v).length;
    final percentage = totalItems > 0 ? ((checkedCount / totalItems) * 100) : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shopping Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$checkedCount of $totalItems items to buy',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${percentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPantryInfoCard(
    BuildContext context,
    List<String> neededPantryItems,
    GroceryProvider groceryProvider,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFE082),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE082).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.home_work,
                  color: Color(0xFFFF8F00),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'In Your Pantry',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    Text(
                      '${neededPantryItems.length} items you already have',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown[400],
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _showPantryManagementSheet(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Manage',
                  style: TextStyle(
                    color: Color(0xFFFF8F00),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          if (neededPantryItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: neededPantryItems.map((item) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFFFE082)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF4CAF50),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Switch(
                value: groceryProvider.showPantryItems,
                onChanged: (value) {
                  groceryProvider.setShowPantryItems(value);
                },
                activeTrackColor: const Color(0xFFFF8F00),
                thumbColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white;
                  }
                  return Colors.grey[400];
                }),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  groceryProvider.showPantryItems
                      ? 'Showing pantry items in list'
                      : 'Hiding pantry items from list',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.brown[400],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientSection({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<String> ingredients,
    required Color color,
    required IconData icon,
    required GroceryProvider groceryProvider,
  }) {
    if (ingredients.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${ingredients.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ingredients.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final ingredient = ingredients[index];
              final isChecked = groceryProvider.isChecked(ingredient);
              final isInPantry = groceryProvider.isInPantry(ingredient);
              final isSkipped = groceryProvider.isSkipped(ingredient);

              return InkWell(
                onTap: () {
                  if (!isSkipped) {
                    groceryProvider.toggleChecked(ingredient);
                  }
                },
                onLongPress: () {
                  _showIngredientOptionsSheet(context, ingredient, color);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      if (isSkipped)
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.remove,
                            color: Colors.white,
                            size: 16,
                          ),
                        )
                      else
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isChecked ? color : Colors.transparent,
                            border: Border.all(
                              color: isChecked ? color : Colors.grey[400]!,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: isChecked
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : null,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 15,
                                color: isSkipped
                                    ? Colors.grey[400]
                                    : isChecked
                                        ? Colors.grey[400]
                                        : AppColors.textPrimary,
                                decoration: (isChecked || isSkipped)
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            if (isSkipped)
                              Text(
                                'Not available - skipped',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (isInPantry && groceryProvider.showPantryItems && !isSkipped)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFFE082)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home, size: 12, color: Color(0xFFFF8F00)),
                              SizedBox(width: 4),
                              Text(
                                'Have',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFFF8F00),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.grey[400],
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          _showIngredientOptionsSheet(context, ingredient, color);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PantryManagementSheet extends StatefulWidget {
  final GroceryProvider groceryProvider;
  final ScrollController scrollController;

  const PantryManagementSheet({
    super.key,
    required this.groceryProvider,
    required this.scrollController,
  });

  @override
  State<PantryManagementSheet> createState() => _PantryManagementSheetState();
}

class _PantryManagementSheetState extends State<PantryManagementSheet> {
  final TextEditingController _addItemController = TextEditingController();

  final List<String> _commonPantryItems = [];

  @override
  void dispose() {
    _addItemController.dispose();
    super.dispose();
  }

  void _addCustomItem() {
    final item = _addItemController.text.trim();
    if (item.isNotEmpty && !widget.groceryProvider.isInPantry(item)) {
      widget.groceryProvider.addToPantry(item);
      _addItemController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.groceryProvider,
      builder: (context, _) {
        final pantryItems = widget.groceryProvider.pantryItems;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.home_work,
                        color: Color(0xFFFF8F00),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'My Pantry',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${pantryItems.length} items you always have',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _addItemController,
                        decoration: InputDecoration(
                          hintText: 'Add custom item...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: (_) => _addCustomItem(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _addCustomItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8F00),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (pantryItems.isNotEmpty) ...[
                      const Text(
                        'Your Pantry Items',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: pantryItems.map((item) {
                          return GestureDetector(
                            onTap: () {
                              widget.groceryProvider.removeFromPantry(item);
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFFE082)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    item,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF5D4037),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.close,
                                    size: 16,
                                    color: Color(0xFFFF8F00),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Common Pantry Items',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add items you usually have at home',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonPantryItems.map((item) {
                        final isInPantry = pantryItems.contains(item);
                        return GestureDetector(
                          onTap: () {
                            widget.groceryProvider.togglePantry(item);
                          },
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isInPantry ? const Color(0xFFFFF8E1) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color:
                                    isInPantry ? const Color(0xFFFFE082) : Colors.grey[300]!,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isInPantry) ...[
                                  const Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  item,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isInPantry
                                        ? const Color(0xFF5D4037)
                                        : Colors.grey[700],
                                    fontWeight:
                                        isInPantry ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
