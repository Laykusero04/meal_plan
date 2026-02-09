import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/providers/dish_provider.dart';
import 'package:meal_plan/data/providers/user_preferences_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _username;
  String? _email;
  bool _isLoading = true;

  static const List<String> mealGoalOptions = [
    '3 meals/day',
    '4 meals/day',
    '5 meals/day',
    'Weekly plan',
    'Budget-friendly',
    'Quick & easy',
  ];

  static const List<String> dietOptions = [
    'None',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Gluten-Free',
    'Low-Carb',
    'Mediterranean',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _email = user.email;
        });

        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        if (!mounted) return;
        if (userDoc.exists) {
          final data = userDoc.data();
          setState(() {
            _username = data?['username'] ?? 'User';
            _isLoading = false;
          });
        } else {
          setState(() {
            _username = user.email?.split('@')[0] ?? 'User';
            _isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showEditPreferencesDialog() {
    final prefs = context.read<UserPreferencesProvider>();
    String selectedGoal = prefs.mealGoal;
    String selectedDiet = prefs.dietType.isEmpty ? 'None' : prefs.dietType;

    final dishProvider = context.read<DishProvider>();
    final ingredientSet = <String>{};
    for (final dish in dishProvider.myDishes) {
      ingredientSet.addAll(dish.ingredients);
    }
    final allIngredients = ingredientSet.toList()..sort();
    final selectedIngredients = Set<String>.from(prefs.preferredIngredients);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Edit Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Meal Goal',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: mealGoalOptions.map((goal) {
                        final isSelected = selectedGoal == goal;
                        return ChoiceChip(
                          label: Text(
                            goal,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (_) {
                            setDialogState(() {
                              selectedGoal = goal;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Diet Type',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: dietOptions.map((diet) {
                        final isSelected = selectedDiet == diet;
                        return ChoiceChip(
                          label: Text(
                            diet,
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (_) {
                            setDialogState(() {
                              selectedDiet = diet;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    if (allIngredients.isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Preferred Ingredients',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                if (selectedIngredients.length == allIngredients.length) {
                                  selectedIngredients.clear();
                                } else {
                                  selectedIngredients.addAll(allIngredients);
                                }
                              });
                            },
                            child: Text(
                              selectedIngredients.length == allIngredients.length
                                  ? 'Deselect all'
                                  : 'Select all',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: allIngredients.map((ingredient) {
                          final isSelected = selectedIngredients.contains(ingredient);
                          return FilterChip(
                            label: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected ? Colors.white : AppColors.textPrimary,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.grey[100],
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            onSelected: (selected) {
                              setDialogState(() {
                                if (selected) {
                                  selectedIngredients.add(ingredient);
                                } else {
                                  selectedIngredients.remove(ingredient);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final diet = selectedDiet == 'None' ? '' : selectedDiet;
                    try {
                      await context.read<UserPreferencesProvider>().savePreferences(
                        mealGoal: selectedGoal,
                        dietType: diet,
                        ingredients: selectedIngredients.toList()..sort(),
                      );
                      if (context.mounted) Navigator.pop(context);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error saving preferences: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<UserPreferencesProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        elevation: 0,
        toolbarHeight: 56,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Main Profile Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Info Section
                          Row(
                            children: [
                              // Avatar
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _username?.substring(0, 1).toUpperCase() ?? 'U',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Name and Email
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _username ?? 'User',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    if (_email != null)
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.email_outlined,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _email!,
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
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Divider
                          Divider(
                            color: Colors.grey[200],
                            height: 1,
                          ),
                          const SizedBox(height: 20),
                          // Current Preferences Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Current Preferences',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showEditPreferencesDialog,
                                icon: const Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Color(0xFF2ECC71),
                                ),
                                label: const Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Meal Goal
                          _buildPreferenceRow(
                            label: 'Meal Goal',
                            value: prefs.mealGoal.isEmpty ? 'Not set' : prefs.mealGoal,
                          ),
                          const SizedBox(height: 16),
                          // Ingredients
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Preferred Ingredients',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Builder(
                                builder: (context) {
                                  final displayIngredients = prefs.preferredIngredients;
                                  if (displayIngredients.isEmpty) {
                                    return Text(
                                      prefs.mealGoal.isNotEmpty
                                          ? 'No ingredients selected'
                                          : 'No ingredients yet',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[400],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    );
                                  }
                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      ...displayIngredients
                                          .take(6)
                                          .map((i) => _buildIngredientTag(i)),
                                      if (displayIngredients.length > 6)
                                        Text(
                                          '+${displayIngredients.length - 6} more',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Diet Type
                          _buildPreferenceRow(
                            label: 'Diet Type',
                            value: prefs.dietType.isEmpty ? 'Not set' : prefs.dietType,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPreferenceRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientTag(String ingredient) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        ingredient,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF2ECC71),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
