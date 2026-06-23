import 'package:flutter/material.dart';
import 'package:meal_plan/core/constants/app_assets.dart';
import 'package:meal_plan/core/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showTitle;
  final bool showTagline;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showTitle = false,
    this.showTagline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(size * 0.15),
          child: Image.asset(
            AppAssets.logo,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
        if (showTitle) ...[
          SizedBox(height: size * 0.15),
          const Text(
            'MealPlan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
        if (showTagline) ...[
          const SizedBox(height: 6),
          const Text(
            'Plan meals without stress',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
