import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meal_plan/core/theme/app_colors.dart';
import 'package:meal_plan/data/models/planned_meal.dart';
import 'package:meal_plan/data/providers/meal_plan_provider.dart';
import 'package:meal_plan/presentation/screens/select_dish_screen.dart';
import 'package:meal_plan/presentation/screens/planned_meal_view_screen.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  DateTime _selectedDay = DateTime.now();
  String _selectedView = 'Week';
  bool _isSwipingForward = true;

  final List<String> _viewOptions = ['Week', 'Month'];

  int _getDaysForView(String view) {
    switch (view) {
      case 'Week':
        return 7;
      case 'Month':
        return 30;
      default:
        return 7;
    }
  }

  Future<void> _saveMeal(DateTime date, String mealType, String dishName, {String? dishId}) async {
    await _mealPlanProvider.saveMeal(date, mealType, dishName, dishId: dishId);
  }

  MealPlanProvider get _mealPlanProvider => context.read<MealPlanProvider>();

  Map<String, PlannedMeal>? _getMealPlanForDate(DateTime date) {
    return _mealPlanProvider.getPlannedMealsMapForDate(date);
  }

  bool _hasPlanForDate(DateTime date) {
    return _getMealPlanForDate(date) != null;
  }

  DateTime _getStartOfWeek(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  List<DateTime> _getWeekDays(DateTime date) {
    final startOfWeek = _getStartOfWeek(date);
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  void _showMealTypeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add meal for',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildMealTypeOption('Breakfast', Icons.breakfast_dining, const Color(0xFFFF9800)),
            _buildMealTypeOption('Lunch', Icons.lunch_dining, const Color(0xFF4CAF50)),
            _buildMealTypeOption('Dinner', Icons.dinner_dining, const Color(0xFF2196F3)),
            _buildMealTypeOption('Snack', Icons.cookie_outlined, const Color(0xFF9C27B0)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMealTypeOption(String mealType, IconData icon, Color color) {
    return ListTile(
      onTap: () async {
        Navigator.pop(context);
        final dish = await Navigator.push<dynamic>(
          context,
          MaterialPageRoute(
            builder: (context) => SelectDishScreen(mealType: mealType),
          ),
        );
        if (dish == null || !mounted) return;
        _saveMeal(_selectedDay, mealType, dish.name, dishId: dish.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${dish.name} added to $mealType'),
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
        mealType,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey),
    );
  }



  @override
  Widget build(BuildContext context) {
    // Subscribe to MealPlanProvider so the screen rebuilds when data changes
    context.watch<MealPlanProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text(
          'Plans',
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
      body: Column(
        children: [
          // Calendar Section - Redesigned
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                // Month and Year Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getHeaderText(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, size: 20),
                            color: AppColors.primary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final days = _getDaysForView(_selectedView);
                              setState(() {
                                _selectedDay = _selectedDay.subtract(Duration(days: days));
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, size: 20),
                            color: AppColors.primary,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final days = _getDaysForView(_selectedView);
                              setState(() {
                                _selectedDay = _selectedDay.add(Duration(days: days));
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Weekday Headers
                const SizedBox(height: 8),
                Row(
                  children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                      .map((day) => Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 12),
                // Calendar View based on selected filter
                _buildCalendarView(),
              ],
            ),
          ),
          // View Filter Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: _viewOptions.map((view) {
                final isSelected = _selectedView == view;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: view != _viewOptions.last ? 8 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedView = view;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          view,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.onPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 1),
          // Content Area - Scrollable with swipe navigation
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < -200) {
                    // Swipe left - go to next day
                    setState(() {
                      _isSwipingForward = true;
                      _selectedDay = _selectedDay.add(const Duration(days: 1));
                    });
                  } else if (details.primaryVelocity! > 200) {
                    // Swipe right - go to previous day
                    setState(() {
                      _isSwipingForward = false;
                      _selectedDay = _selectedDay.subtract(const Duration(days: 1));
                    });
                  }
                }
              },
              child: Container(
                width: double.infinity,
                color: AppColors.surface,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    final offsetAnimation = Tween<Offset>(
                      begin: Offset(_isSwipingForward ? 1.0 : -1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ));
                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                  child: SingleChildScrollView(
                    key: ValueKey<String>('${_selectedDay.year}-${_selectedDay.month}-${_selectedDay.day}'),
                    child: _hasPlanForDate(_selectedDay)
                        ? _buildPlanContent()
                        : _buildEmptyState(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 400,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 20),
            const Text(
              'No plan for this date',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new meal plan starting from ${_getFormattedDate(_selectedDay)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                _showMealTypeSelector();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: const Text(
                '+ Create Plan',
                style: TextStyle(
                  color: AppColors.surface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanContent() {
    final mealPlan = _getMealPlanForDate(_selectedDay);
    if (mealPlan == null) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedDate(_selectedDay),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Your meal plan for today',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // TODO: Navigate to edit plan screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Edit plan functionality coming soon!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Breakfast Card
          _buildMealCard(
            mealType: 'Breakfast',
            plannedMeal: mealPlan['breakfast'],
            icon: Icons.breakfast_dining,
            color: const Color(0xFFFFF3E0),
            iconColor: const Color(0xFFFF9800),
          ),
          const SizedBox(height: 8),
          // Lunch Card
          _buildMealCard(
            mealType: 'Lunch',
            plannedMeal: mealPlan['lunch'],
            icon: Icons.lunch_dining,
            color: const Color(0xFFE8F5E9),
            iconColor: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 8),
          // Dinner Card
          _buildMealCard(
            mealType: 'Dinner',
            plannedMeal: mealPlan['dinner'],
            icon: Icons.dinner_dining,
            color: const Color(0xFFE3F2FD),
            iconColor: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 8),
          // Snack Card
          _buildMealCard(
            mealType: 'Snack',
            plannedMeal: mealPlan['snack'],
            icon: Icons.cookie_outlined,
            color: const Color(0xFFF3E5F5),
            iconColor: const Color(0xFF9C27B0),
          ),
          const SizedBox(height: 16),
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showMealTypeSelector();
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Meal', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Share plan functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share plan functionality coming soon!'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('Share', style: TextStyle(fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
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
    final mealName = plannedMeal?.dish.name ?? 'Not planned';

    return GestureDetector(
      onTap: isNotPlanned
          ? null
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
                    date: _selectedDay,
                  ),
                ),
              );
            },
      child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
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
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
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
                    color: AppColors.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  mealName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isNotPlanned
                        ? AppColors.textDisabled
                        : AppColors.textPrimary,
                    fontStyle: isNotPlanned ? FontStyle.italic : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              isNotPlanned ? Icons.add_circle_outline : Icons.edit_outlined,
              color: AppColors.primary,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () async {
              final dish = await Navigator.push<dynamic>(
                context,
                MaterialPageRoute(
                  builder: (context) => SelectDishScreen(mealType: mealType),
                ),
              );
              if (dish == null || !mounted) return;
              _saveMeal(_selectedDay, mealType, dish.name, dishId: dish.id);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${dish.name} added to $mealType'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  String _getMonthYear(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getWeekRange(DateTime date) {
    final startOfWeek = _getStartOfWeek(date);
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    
    if (startOfWeek.month == endOfWeek.month) {
      return '${months[startOfWeek.month - 1]} ${startOfWeek.day} - ${endOfWeek.day}, ${startOfWeek.year}';
    } else {
      return '${months[startOfWeek.month - 1]} ${startOfWeek.day} - ${months[endOfWeek.month - 1]} ${endOfWeek.day}, ${startOfWeek.year}';
    }
  }

  String _getHeaderText() {
    switch (_selectedView) {
      case 'Week':
        return _getWeekRange(_selectedDay);
      case 'Month':
        return _getMonthYear(_selectedDay);
      default:
        return _getWeekRange(_selectedDay);
    }
  }

  Widget _buildCalendarView() {
    switch (_selectedView) {
      case 'Week':
        return _buildWeekView();
      case 'Month':
        return _buildCalendarGrid();
      default:
        return _buildWeekView();
    }
  }

  Widget _buildWeekView() {
    final weekDays = _getWeekDays(_selectedDay);
    
    return Row(
      children: weekDays.map((date) {
        return Expanded(
          child: _buildCalendarDay(date, date.month),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(_selectedDay.year, _selectedDay.month, 1);
    final lastDayOfMonth = DateTime(_selectedDay.year, _selectedDay.month + 1, 0);
    final firstDayWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    // Calculate days to show (including previous month's trailing days)
    final daysToShow = <DateTime>[];
    
    // Add previous month's trailing days
    final prevMonthLastDay = DateTime(_selectedDay.year, _selectedDay.month, 0);
    final daysInPrevMonth = prevMonthLastDay.day;
    for (int i = firstDayWeekday - 1; i > 0; i--) {
      daysToShow.add(DateTime(_selectedDay.year, _selectedDay.month - 1, daysInPrevMonth - i + 1));
    }
    
    // Add current month's days
    for (int i = 1; i <= daysInMonth; i++) {
      daysToShow.add(DateTime(_selectedDay.year, _selectedDay.month, i));
    }
    
    // Add next month's leading days to fill the grid
    final remainingDays = 42 - daysToShow.length; // 6 rows * 7 days
    for (int i = 1; i <= remainingDays; i++) {
      daysToShow.add(DateTime(_selectedDay.year, _selectedDay.month + 1, i));
    }

    return Column(
      children: [
        for (int week = 0; week < 6; week++)
          Row(
            children: [
              for (int day = 0; day < 7; day++)
                Expanded(
                  child: _buildCalendarDay(
                    daysToShow[week * 7 + day],
                    _selectedDay.month,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildCalendarDay(DateTime date, int currentMonth) {
    final isCurrentMonth = date.month == currentMonth;
    final isSelected = _selectedDay.year == date.year &&
        _selectedDay.month == date.month &&
        _selectedDay.day == date.day;
    final isToday = date.year == DateTime.now().year &&
        date.month == DateTime.now().month &&
        date.day == DateTime.now().day;
    final hasPlan = _hasPlanForDate(date);

    return GestureDetector(
      onTap: () {
        // Allow selecting any day in the visible range
        setState(() {
          _selectedDay = date;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        height: 44,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isToday && !isSelected
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent),
          borderRadius: BorderRadius.circular(8),
          border: isToday && !isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected || isToday
                    ? FontWeight.w600
                    : FontWeight.normal,
                color: isSelected
                    ? AppColors.onPrimary
                    : (isCurrentMonth
                        ? AppColors.textPrimary
                        : AppColors.textDisabled),
              ),
            ),
            if (hasPlan && isCurrentMonth)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.onPrimary
                      : AppColors.primary,
                  shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
