import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/models/dish.dart';
import 'package:meal_plan/data/providers/dish_provider.dart';

class SelectDishScreen extends StatefulWidget {
  final String mealType;

  const SelectDishScreen({
    super.key,
    required this.mealType,
  });

  @override
  State<SelectDishScreen> createState() => _SelectDishScreenState();
}

class _SelectDishScreenState extends State<SelectDishScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showFilters = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

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

  void _selectDish(Dish dish) {
    Navigator.pop(context, dish);
  }

  void _spinForDish() {
    final dishProvider = context.read<DishProvider>();
    final allDishes = dishProvider.allDishes;
    if (allDishes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No dishes available')),
      );
      return;
    }

    final randomDish = allDishes[Random().nextInt(allDishes.length)];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 36,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
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
            _buildCategoryChip(randomDish.category),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Spin Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _selectDish(randomDish);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child:
                const Text('Select', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabs(),
            if (_showFilters) _buildFilters(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDishesGrid(isPublic: false),
                  _buildDishesGrid(isPublic: true),
                  _buildSpinTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.textPrimary,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Dish',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choose a dish for ${widget.mealType}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _showFilters = !_showFilters;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list,
                          size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Filters',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        _showFilters
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _categories.map((category) {
          final isSelected = _selectedCategory == category ||
              (category == 'All' && _selectedCategory == null);
          return FilterChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedCategory =
                    selected && category != 'All' ? category : null;
              });
            },
            selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
            checkmarkColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDishesGrid({required bool isPublic}) {
    final dishProvider = context.watch<DishProvider>();
    final dishes = dishProvider.filterDishes(
      isPublic ? dishProvider.publicDishes : dishProvider.myDishes,
      searchQuery: _searchQuery,
      category: _selectedCategory,
    );

    if (dishes.isEmpty) {
      return _buildEmptyState(
        isPublic ? 'No public dishes found' : 'No dishes found',
        isPublic
            ? 'Try adjusting your search'
            : 'Add your first dish to get started',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: dishes.length,
      itemBuilder: (context, index) {
        return _buildDishCard(dishes[index], isPublic: isPublic);
      },
    );
  }

  Widget _buildDishCard(Dish dish, {required bool isPublic}) {
    return GestureDetector(
      onTap: () => _selectDish(dish),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.restaurant,
                  size: 40,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dish.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    if (isPublic && dish.author != null)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                            child: Text(
                              dish.author!.isNotEmpty
                                  ? dish.author![0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              dish.author!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        dish.ingredients.join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        _buildCategoryChip(dish.category),
                        if (dish.tags.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Expanded(
                            child: _buildTagChip(dish.tags.first),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
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
            onPressed: _spinForDish,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
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

  Widget _buildCategoryChip(String category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 10,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTagChip(String tag) {
    Color chipColor;
    switch (tag.toLowerCase()) {
      case 'vegetarian':
        chipColor = AppColors.primary;
        break;
      case 'low-carb':
        chipColor = AppColors.secondary;
        break;
      default:
        chipColor = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.5)),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 10,
          color: chipColor,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
