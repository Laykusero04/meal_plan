import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/models/dish.dart';
import 'package:meal_plan/data/providers/dish_provider.dart';

class SelectDishDialog extends StatefulWidget {
  final String mealType;
  final Function(Dish) onDishSelected;

  const SelectDishDialog({
    super.key,
    required this.mealType,
    required this.onDishSelected,
  });

  @override
  State<SelectDishDialog> createState() => _SelectDishDialogState();
}

class _SelectDishDialogState extends State<SelectDishDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _searchQuery = '';
          _searchController.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _spinForDish(BuildContext context) {
    final dishProvider = context.read<DishProvider>();
    final allDishes = dishProvider.allDishes;
    if (allDishes.isEmpty) return;

    final randomDish = allDishes[Random().nextInt(allDishes.length)];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primary),
            const SizedBox(width: 8),
            const Text('Lucky Pick!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDishAvatar(randomDish.name, size: 60),
            const SizedBox(height: 16),
            Text(
              randomDish.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              randomDish.category,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Spin Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDishSelected(randomDish);
              Navigator.pop(this.context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Select', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Select Dish for ${widget.mealType}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey[600],
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              tabs: const [
                Tab(text: 'My Dishes'),
                Tab(text: 'Public'),
                Tab(text: 'Spin'),
              ],
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMyDishesTab(),
                  _buildPublicTab(),
                  _buildSpinTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search dishes...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildMyDishesTab() {
    final dishProvider = context.watch<DishProvider>();
    final filteredDishes = dishProvider.filterDishes(
      dishProvider.myDishes,
      searchQuery: _searchQuery,
    );

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: filteredDishes.isEmpty
              ? _buildEmptyState('No dishes found')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDishes.length,
                  itemBuilder: (context, index) {
                    return _buildDishItem(filteredDishes[index], isPublic: false);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPublicTab() {
    final dishProvider = context.watch<DishProvider>();
    final filteredDishes = dishProvider.filterDishes(
      dishProvider.publicDishes,
      searchQuery: _searchQuery,
    );

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: filteredDishes.isEmpty
              ? _buildEmptyState('No dishes found')
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDishes.length,
                  itemBuilder: (context, index) {
                    return _buildDishItem(filteredDishes[index], isPublic: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSpinTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shuffle,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Feeling Lucky?',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Let us pick a random dish for you',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _spinForDish(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Spin for Dish',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishItem(Dish dish, {required bool isPublic}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () {
          widget.onDishSelected(dish);
          Navigator.pop(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _buildDishAvatar(isPublic ? (dish.author ?? dish.name) : dish.name),
        title: Text(
          dish.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          isPublic ? '${dish.category} • by ${dish.author}' : dish.category,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildDishAvatar(String name, {double size = 44}) {
    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      const Color(0xFFE91E63),
      const Color(0xFF9C27B0),
      const Color(0xFFFF9800),
      const Color(0xFF009688),
    ];
    final colorIndex = name.hashCode.abs() % colors.length;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors[colorIndex].withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(size / 4),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: TextStyle(
            color: colors[colorIndex],
            fontWeight: FontWeight.bold,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the dialog
Future<void> showSelectDishDialog({
  required BuildContext context,
  required String mealType,
  required Function(Dish) onDishSelected,
}) {
  return showDialog(
    context: context,
    builder: (context) => SelectDishDialog(
      mealType: mealType,
      onDishSelected: onDishSelected,
    ),
  );
}
