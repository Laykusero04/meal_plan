import 'package:flutter/material.dart';

/// App color palette following Material Design 3 best practices
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors (Green Theme)
  static const Color primary = Color(0xFF2ECC71);
  static const Color primaryLight = Color(0xFF58E88A);
  static const Color primaryDark = Color(0xFF27AE60);
  static const Color onPrimary = Colors.white;

  // Secondary Colors
  static const Color secondary = Color(0xFF3498DB);
  static const Color secondaryLight = Color(0xFF5DADE2);
  static const Color secondaryDark = Color(0xFF2874A6);
  static const Color onSecondary = Colors.white;

  // Background Colors
  static const Color background = Color(0xFFE8F8F0);
  static const Color surface = Colors.white;
  static const Color onBackground = Color(0xFF333333);
  static const Color onSurface = Color(0xFF333333);

  // Error Colors
  static const Color error = Color(0xFFE74C3C);
  static const Color errorLight = Color(0xFFEC7063);
  static const Color onError = Colors.white;

  // Warning Colors
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFFC107);
  static const Color onWarning = Colors.white;

  // Success Colors
  static const Color success = Color(0xFF27AE60);
  static const Color successLight = Color(0xFF2ECC71);
  static const Color onSuccess = Colors.white;

  // Neutral Colors
  static const Color grey = Color(0xFF95A5A6);
  static const Color greyLight = Color(0xFFBDC3C7);
  static const Color greyDark = Color(0xFF7F8C8D);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Text Colors
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textHint = Color(0xFF9E9E9E);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFF5F5F5);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Shadow Colors
  static Color shadowLight = Colors.black.withOpacity(0.04);
  static Color shadowMedium = Colors.black.withOpacity(0.06);
  static Color shadowDark = Colors.black.withOpacity(0.08);

  // Overlay Colors
  static Color overlayLight = Colors.black.withOpacity(0.1);
  static Color overlayMedium = Colors.black.withOpacity(0.3);
  static Color overlayDark = Colors.black.withOpacity(0.5);
}

