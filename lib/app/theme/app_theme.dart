import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_typography.dart';

abstract final class AppTheme {
  /// Padding used by every scrollable screen body.
  static const screenPadding = EdgeInsets.symmetric(horizontal: 20);

  /// Corner radius shared by cards, chips and tiles.
  static const cardRadius = Radius.circular(18);
  static const tileRadius = Radius.circular(14);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.genotypeBase,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.optimalBright,
        secondary: AppColors.accentCyan,
        surface: AppColors.surface,
        error: AppColors.critical,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: AppFonts.body,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      // The design draws its own headers, so the system bar stays transparent.
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.optimalBright,
      ),
    );
  }
}
