import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Brand palette. Everything else derives from [primary].
abstract final class AppColors {
  static const primary = Color(0xFF6D5EFC);
  static const primaryLight = Color(0xFF9D8FFF);
  static const accent = Color(0xFFB06CFF);

  static const background = Color(0xFF0C0B16);
  static const surface = Color(0xFF14132A);
  static const surfaceLow = Color(0xFF181730);
  static const surfaceMid = Color(0xFF1E1C3A);
  static const surfaceHigh = Color(0xFF252347);
  static const surfaceHighest = Color(0xFF2D2A55);
  static const outline = Color(0xFF5B5790);
  static const outlineVariant = Color(0xFF34315E);
  static const textMuted = Color(0xFFA9A6CF);

  static const success = Color(0xFF3DDC97);
  static const danger = Color(0xFFFF5C7A);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, accent],
  );

  /// Soft page backdrop: a violet glow fading into near-black.
  static const backdrop = RadialGradient(
    center: Alignment(-0.8, -1.1),
    radius: 1.6,
    colors: [Color(0xFF2A2170), Color(0xFF131128), background],
    stops: [0, 0.45, 1],
  );
}

abstract final class AppTheme {
  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark).copyWith(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF3A2F9E),
      onPrimaryContainer: const Color(0xFFE4DFFF),
      secondary: AppColors.primaryLight,
      secondaryContainer: const Color(0xFF2E2A66),
      onSecondaryContainer: const Color(0xFFE4DFFF),
      tertiary: AppColors.accent,
      surface: AppColors.surface,
      onSurface: const Color(0xFFF1F0FF),
      onSurfaceVariant: AppColors.textMuted,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: AppColors.surfaceLow,
      surfaceContainer: AppColors.surfaceMid,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      error: AppColors.danger,
      errorContainer: const Color(0xFF4A1A2A),
      onErrorContainer: const Color(0xFFFFD9DF),
    );

    final radius16 = BorderRadius.circular(16);
    final base = ThemeData(useMaterial3: true, colorScheme: scheme, brightness: Brightness.dark);
    final text = base.textTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: text.copyWith(
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.2),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -0.3),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceMid.withValues(alpha: 0.85),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primaryLight,
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMid.withValues(alpha: 0.9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        labelStyle: const TextStyle(color: AppColors.textMuted),
        hintStyle: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.7)),
        border:
            OutlineInputBorder(borderRadius: radius16, borderSide: const BorderSide(color: AppColors.outlineVariant)),
        enabledBorder:
            OutlineInputBorder(borderRadius: radius16, borderSide: const BorderSide(color: AppColors.outlineVariant)),
        focusedBorder: OutlineInputBorder(
            borderRadius: radius16, borderSide: const BorderSide(color: AppColors.primary, width: 1.6)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(borderRadius: radius16),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          backgroundColor: AppColors.surfaceMid.withValues(alpha: 0.7),
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(style: IconButton.styleFrom(foregroundColor: scheme.onSurface)),
      navigationBarTheme: NavigationBarThemeData(
        height: 70,
        elevation: 0,
        backgroundColor: AppColors.surface.withValues(alpha: 0.92),
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primary.withValues(alpha: 0.22),
        indicatorShape: RoundedRectangleBorder(borderRadius: radius16),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((s) => IconThemeData(
              color: s.contains(WidgetState.selected) ? AppColors.primaryLight : AppColors.textMuted,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith((s) => TextStyle(
              fontSize: 12,
              fontWeight: s.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
              color: s.contains(WidgetState.selected) ? Colors.white : AppColors.textMuted,
            )),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceMid,
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        side: const BorderSide(color: AppColors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          backgroundColor: AppColors.surfaceMid,
          selectedBackgroundColor: AppColors.primary,
          selectedForegroundColor: Colors.white,
          side: const BorderSide(color: AppColors.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : null),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.primary : null),
        trackOutlineColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.outline),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.surfaceHighest,
        thumbColor: Colors.white,
        overlayColor: AppColors.primary.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primary,
        trackHeight: 6,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryLight,
        linearTrackColor: AppColors.surfaceHighest,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceLow,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppColors.outlineVariant),
        ),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
        iconColor: AppColors.primaryLight,
        collapsedIconColor: AppColors.textMuted,
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outlineVariant, space: 1),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: radius16),
      ),
    );
  }
}
