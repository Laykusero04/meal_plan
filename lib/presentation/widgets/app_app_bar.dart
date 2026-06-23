import 'package:flutter/material.dart';
import 'package:meal_plan/core/constants/app_assets.dart';
import 'package:meal_plan/core/theme/app_colors.dart';

class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  const AppAppBar({
    super.key,
    this.actions,
    this.leading,
    this.bottom,
  });

  static Widget titleRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            AppAssets.logo,
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'MealPlan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      automaticallyImplyLeading: false,
      leading: leading,
      title: titleRow(),
      actions: actions,
      bottom: bottom,
      elevation: 0,
      toolbarHeight: 56,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        56 + (bottom?.preferredSize.height ?? 0),
      );
}
