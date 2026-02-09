import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/models/dish.dart';
import 'package:meal_plan/data/providers/dish_provider.dart';

class AddDishScreen extends StatefulWidget {
  const AddDishScreen({super.key});

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dishNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagController = TextEditingController();

  final Set<String> _selectedCategories = {};
  final Set<String> _selectedIngredients = {};
  final Set<String> _optionalIngredients = {};
  final List<String> _tags = [];
  bool _isPrivate = true;
  String? _selectedMainIngredient;
  String _ingredientSearch = '';
  String _mainIngredientSearch = '';

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Breakfast', 'icon': Icons.wb_sunny_outlined},
    {'name': 'Lunch', 'icon': Icons.light_mode_outlined},
    {'name': 'Dinner', 'icon': Icons.nightlight_outlined},
    {'name': 'Snack', 'icon': Icons.cookie_outlined},
  ];

  List<String> get _allIngredients {
    final dishProvider = context.read<DishProvider>();
    return dishProvider.ingredients.toList();
  }

  List<String> _getDisplayedIngredients() {
    final available = _allIngredients
        .where((i) => !_selectedIngredients.contains(i))
        .toList();

    if (_ingredientSearch.isEmpty) {
      return available.take(8).toList();
    } else {
      return available
          .where((i) => i.toLowerCase().contains(_ingredientSearch.toLowerCase()))
          .toList();
    }
  }

  List<String> _getDisplayedMainIngredients() {
    if (_mainIngredientSearch.isEmpty) {
      return _allIngredients.take(8).toList();
    } else {
      return _allIngredients
          .where((i) => i.toLowerCase().contains(_mainIngredientSearch.toLowerCase()))
          .toList();
    }
  }

  int get _completedSteps {
    int count = 0;
    if (_dishNameController.text.trim().isNotEmpty) count++;
    if (_selectedCategories.isNotEmpty) count++;
    if (_selectedMainIngredient != null) count++;
    if (_selectedIngredients.isNotEmpty) count++;
    return count;
  }

  static const int _totalRequiredSteps = 4;

  @override
  void initState() {
    super.initState();
    _dishNameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _saveDish() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategories.isEmpty) {
        _showError('Please select at least one category');
        return;
      }

      if (_selectedMainIngredient == null) {
        _showError('Please select a main ingredient');
        return;
      }

      if (_selectedIngredients.isEmpty) {
        _showError('Please select at least one ingredient');
        return;
      }

      final dishProvider = context.read<DishProvider>();
      final dish = Dish(
        id: dishProvider.generateId(),
        name: _dishNameController.text.trim(),
        description: _descriptionController.text.trim(),
        mainIngredient: _selectedMainIngredient!,
        ingredients: _selectedIngredients.toList(),
        category: _selectedCategories.join(', '),
        tags: _tags,
        optionalIngredients: _optionalIngredients.toList(),
        isPublic: !_isPrivate,
      );

      dishProvider.addDish(dish);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text('${_dishNameController.text} saved!'),
            ],
          ),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Flexible(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completedSteps / _totalRequiredSteps;

    return Scaffold(
      backgroundColor: AppColors.grey100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Dish',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: AppColors.grey200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress == 1.0 ? AppColors.primary : AppColors.secondary,
                ),
                minHeight: 3,
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomSaveBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress hint
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _completedSteps == _totalRequiredSteps
                      ? 'All required fields filled!'
                      : '$_completedSteps of $_totalRequiredSteps required fields completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: _completedSteps == _totalRequiredSteps
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Dish Name
              _buildSection(
                icon: Icons.restaurant_menu,
                iconColor: AppColors.primary,
                accentColor: AppColors.primary,
                title: 'Dish Name',
                isRequired: true,
                isCompleted: _dishNameController.text.trim().isNotEmpty,
                child: TextFormField(
                  controller: _dishNameController,
                  style: const TextStyle(fontSize: 15),
                  decoration: _inputDecoration(
                    hint: 'e.g., Chicken Adobo',
                    prefixIcon: Icons.edit_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a dish name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Description
              _buildSection(
                icon: Icons.notes,
                iconColor: AppColors.grey600,
                accentColor: AppColors.grey400,
                title: 'Description',
                subtitle: 'A short summary of your dish',
                child: TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration(
                    hint: 'e.g., A creamy Italian pasta with garlic and parmesan',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Category
              _buildSection(
                icon: Icons.category_outlined,
                iconColor: AppColors.secondary,
                accentColor: AppColors.secondary,
                title: 'Category',
                isRequired: true,
                isCompleted: _selectedCategories.isNotEmpty,
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _categories.map((cat) {
                    final name = cat['name'] as String;
                    final icon = cat['icon'] as IconData;
                    final isSelected = _selectedCategories.contains(name);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedCategories.remove(name);
                          } else {
                            _selectedCategories.add(name);
                          }
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.secondary.withValues(alpha: 0.1)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              icon,
                              size: 16,
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.secondary
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // Main Ingredient
              _buildSection(
                icon: Icons.star_outline,
                iconColor: AppColors.warning,
                accentColor: AppColors.warning,
                title: 'Main Ingredient',
                isRequired: true,
                isCompleted: _selectedMainIngredient != null,
                subtitle: _selectedMainIngredient != null
                    ? null
                    : 'Choose the star of this dish',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show selected main ingredient
                    if (_selectedMainIngredient != null) ...[
                      GestureDetector(
                        onTap: () {
                          setState(() => _selectedMainIngredient = null);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.warning, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.star, size: 16, color: AppColors.warning),
                              const SizedBox(width: 6),
                              Text(
                                _selectedMainIngredient!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.close, size: 14, color: AppColors.warning),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Search field
                    TextField(
                      onChanged: (value) {
                        setState(() => _mainIngredientSearch = value);
                      },
                      decoration: _searchDecoration('Search ingredients...'),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getDisplayedMainIngredients().map((ingredient) {
                        final isSelected = _selectedMainIngredient == ingredient;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMainIngredient = isSelected ? null : ingredient;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.warning.withValues(alpha: 0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.warning
                                    : AppColors.border,
                              ),
                            ),
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected
                                    ? AppColors.warning
                                    : AppColors.textPrimary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Ingredients
              _buildSection(
                icon: Icons.shopping_basket_outlined,
                iconColor: AppColors.primaryDark,
                accentColor: AppColors.primaryDark,
                title: 'Ingredients',
                isRequired: true,
                isCompleted: _selectedIngredients.isNotEmpty,
                trailing: _optionalIngredients.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_optionalIngredients.length} optional',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : null,
                subtitle: 'Long press selected to mark as optional',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      onChanged: (value) {
                        setState(() => _ingredientSearch = value);
                      },
                      decoration: _searchDecoration('Search ingredients...'),
                    ),
                    const SizedBox(height: 10),
                    // Selected ingredients
                    if (_selectedIngredients.isNotEmpty) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedIngredients.map((ingredient) {
                          final isOptional = _optionalIngredients.contains(ingredient);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedIngredients.remove(ingredient);
                                _optionalIngredients.remove(ingredient);
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                if (isOptional) {
                                  _optionalIngredients.remove(ingredient);
                                } else {
                                  _optionalIngredients.add(ingredient);
                                }
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isOptional
                                        ? '$ingredient marked as required'
                                        : '$ingredient marked as optional',
                                  ),
                                  backgroundColor: isOptional ? AppColors.primary : Colors.orange,
                                  duration: const Duration(seconds: 1),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isOptional
                                    ? Colors.orange.withValues(alpha: 0.08)
                                    : AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isOptional ? Colors.orange : AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isOptional)
                                    Container(
                                      margin: const EdgeInsets.only(right: 5),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
                                      color: isOptional ? Colors.orange : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.close,
                                    size: 14,
                                    color: isOptional ? Colors.orange : AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: AppColors.grey200, height: 1),
                      const SizedBox(height: 10),
                    ],
                    // Available ingredients
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _getDisplayedIngredients().map((ingredient) {
                        return GestureDetector(
                          onTap: () {
                            setState(() => _selectedIngredients.add(ingredient));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  ingredient,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Tags
              _buildSection(
                icon: Icons.label_outline,
                iconColor: AppColors.grey600,
                accentColor: AppColors.grey400,
                title: 'Tags',
                subtitle: 'Optional',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            style: const TextStyle(fontSize: 14),
                            decoration: _inputDecoration(
                              hint: 'e.g., Spicy, Quick, Easy',
                              prefixIcon: Icons.tag,
                            ),
                            onSubmitted: (_) => _addTag(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: _addTag,
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.all(12),
                              child: Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags.map((tag) {
                          return Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => _removeTag(tag),
                            backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                            labelStyle: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            deleteIconColor: AppColors.primary,
                            side: BorderSide.none,
                            visualDensity: VisualDensity.compact,
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Visibility
              _buildSection(
                icon: Icons.visibility_outlined,
                iconColor: AppColors.grey600,
                accentColor: AppColors.grey400,
                title: 'Visibility',
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildVisibilityOption(
                            icon: Icons.lock_outline,
                            label: 'Private',
                            description: 'Only you',
                            isSelected: _isPrivate,
                            onTap: () => setState(() => _isPrivate = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildVisibilityOption(
                            icon: Icons.public,
                            label: 'Public',
                            description: 'Everyone',
                            isSelected: !_isPrivate,
                            onTap: () => setState(() => _isPrivate = false),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSaveBar() {
    final isReady = _completedSteps == _totalRequiredSteps;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _saveDish,
          style: ElevatedButton.styleFrom(
            backgroundColor: isReady ? AppColors.primary : AppColors.grey400,
            elevation: isReady ? 2 : 0,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isReady ? Icons.check_circle_outline : Icons.restaurant_menu,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isReady ? 'Save Dish' : 'Complete required fields',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required Color accentColor,
    required String title,
    required Widget child,
    bool isRequired = false,
    bool isCompleted = false,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCompleted ? accentColor.withValues(alpha: 0.3) : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isRequired) ...[
                            const SizedBox(width: 4),
                            Text(
                              '*',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isCompleted ? AppColors.primary : AppColors.error,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            subtitle,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null) trailing,
                if (isRequired && isCompleted)
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityOption({
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.8)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: Colors.grey[400], size: 18)
          : null,
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _searchDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
      prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 18),
      filled: true,
      fillColor: AppColors.grey100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      isDense: true,
    );
  }
}
