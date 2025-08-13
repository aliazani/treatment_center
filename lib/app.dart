import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // WHO Brand Colors (keeping your brand identity)
  static const Color _whoBluePrimary = Color(0xFF0093D5);
  static const Color _whoBlueLight = Color(0xFF50BFE6);
  static const Color _whoGreen = Color(0xFF2E7D32);
  static const Color _whoOrange = Color(0xFFFF8F00);

  // System Colors
  static const Color _errorRed = Color(0xFFD32F2F);
  static const Color _white = Colors.white;

  // Light Theme Colors
  static const _LightColors _lightColors = _LightColors();

  // Dark Theme Colors
  static const _DarkColors _darkColors = _DarkColors();

  /// WHO Light Theme
  static ThemeData get lightTheme => _buildTheme(_lightColors);

  /// WHO Dark Theme
  static ThemeData get darkTheme => _buildTheme(_darkColors);

  /// Build theme with consistent structure
  static ThemeData _buildTheme(_ThemeColors colors) {
    final colorScheme = colors.colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,

      // Core theme properties
      scaffoldBackgroundColor: colors.background,
      dividerColor: colors.outline,

      // Enhanced App Bar with subtle gradient effect
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        scrolledUnderElevation: 3,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(0)),
        ),
      ),

      // Enhanced Navigation with better visual feedback
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant.withValues(
          alpha: 0.7,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        enableFeedback: true,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        selectedIconTheme: IconThemeData(
          color: colorScheme.onPrimaryContainer,
          size: 26,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
        selectedLabelTextStyle: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        useIndicator: true,
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelType: NavigationRailLabelType.all,
      ),

      // Enhanced Cards with better depth and distinction
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainer,         
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(4),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
      ),

      // Enhanced List tiles with better hover and press states
      listTileTheme: ListTileThemeData(
          tileColor: colorScheme.surfaceContainerHighest,

        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.4),
        selectedColor: colorScheme.primary,
        enableFeedback: true,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 14,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          letterSpacing: -0.1,
        ),
        leadingAndTrailingTextStyle: TextStyle(
          fontSize: 12,
          color: colorScheme.onSurfaceVariant,
        ),
        horizontalTitleGap: 16,
        minVerticalPadding: 8,
      ),

      // Enhanced Buttons with modern design
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 2,
          shadowColor: colorScheme.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onPrimary.withValues(alpha: 0.1);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.onPrimary.withValues(alpha: 0.05);
            }
            return null;
          }),
          elevation: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) return 0;
            if (states.contains(WidgetState.hovered)) return 4;
            return 2;
          }),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          side: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.5),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.primary.withValues(alpha: 0.08);
            }
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.primary.withValues(alpha: 0.04);
            }
            return null;
          }),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ),

      // Enhanced FAB with gradient-like effect
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 6,
        focusElevation: 8,
        hoverElevation: 8,
        disabledElevation: 0,
        highlightElevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        sizeConstraints: const BoxConstraints.tightFor(
          width: 56.0,
          height: 56.0,
        ),
        smallSizeConstraints: const BoxConstraints.tightFor(
          width: 40.0,
          height: 40.0,
        ),
        largeSizeConstraints: const BoxConstraints.tightFor(
          width: 96.0,
          height: 96.0,
        ),
        extendedTextStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          letterSpacing: 0.5,
        ),
      ),

      // Enhanced Input fields with better focus states
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 16,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          fontSize: 16,
        ),
        helperStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
        errorStyle: TextStyle(color: colorScheme.error, fontSize: 12),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
      ),

      // Enhanced Chips with better interactivity
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.5,
        ),
        selectedColor: colorScheme.primaryContainer,
        secondarySelectedColor: colorScheme.secondaryContainer,
        labelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        secondaryLabelStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: Colors.transparent),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        showCheckmark: true,
        checkmarkColor: colorScheme.onPrimaryContainer,
        deleteIconColor: colorScheme.onSurfaceVariant,
        elevation: 0,
        pressElevation: 2,
      ),

      // Progress indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
        refreshBackgroundColor: colorScheme.surface,
      ),

      // Icons
      iconTheme: IconThemeData(color: colorScheme.onSurfaceVariant, size: 24),
      primaryIconTheme: IconThemeData(color: colorScheme.onPrimary, size: 24),

      // Enhanced Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        elevation: 24,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.4),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.5,
        ),
        contentTextStyle: TextStyle(
          fontSize: 16,
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      ),

      // Enhanced Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: colorScheme.onInverseSurface,
          fontSize: 14,
        ),
        actionTextColor: colorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 6,
        width: 400,
      ),

      // Text theme
      textTheme: _buildTextTheme(colorScheme),
    );
  }

  /// Build consistent text theme
  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        color: colorScheme.onSurface,
        letterSpacing: -1.5,
        height: 1.12,
      ),
      displayMedium: TextStyle(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        color: colorScheme.onSurface,
        letterSpacing: -0.5,
        height: 1.16,
      ),
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurface,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  // Utility methods for consistent color access
  static Color primaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color onPrimaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.onPrimary;

  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color onSurfaceColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color errorColor(BuildContext context) =>
      Theme.of(context).colorScheme.error;

  static Color successColor(BuildContext context) =>
      Theme.of(context).colorScheme.tertiary;

  static Color warningColor(BuildContext context) => _whoOrange;

  /// Get card elevation based on type
  static double getCardElevation(
    BuildContext context, {
    String type = 'default',
  }) {
    switch (type) {
      case 'primary':
        return 4;
      case 'elevated':
        return 8;
      case 'flat':
        return 0;
      default:
        return 2;
    }
  }

  /// Get custom card decoration
  static BoxDecoration getCardDecoration(
    BuildContext context, {
    String type = 'default',
    Color? color,
    Color? borderColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color bgColor;
    Color bColor;
    List<BoxShadow> shadows;

    switch (type) {
      case 'primary':
        bgColor = color ?? colorScheme.primaryContainer;
        bColor = borderColor ?? colorScheme.primary.withValues(alpha: 0.2);
        shadows = [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case 'elevated':
        bgColor = color ?? colorScheme.surface;
        bColor = borderColor ?? Colors.transparent;
        shadows = [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
        break;
      case 'outlined':
        bgColor = color ?? colorScheme.surface;
        bColor = borderColor ?? colorScheme.outline.withValues(alpha: 0.3);
        shadows = [];
        break;
      default:
        bgColor = color ?? colorScheme.surface;
        bColor = borderColor ?? colorScheme.outline.withValues(alpha: 0.2);
        shadows = [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ];
    }

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: bColor, width: 1),
      boxShadow: shadows,
    );
  }

  /// Get status-specific colors
  static Color getStatusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return colorScheme.tertiary;
      case 'in_progress':
      case 'active':
        return colorScheme.primary;
      case 'pending':
      case 'waiting':
        return colorScheme.secondary;
      case 'draft':
        return _whoOrange;
      case 'error':
      case 'failed':
        return colorScheme.error;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// Get status container color
  static Color getStatusContainerColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        return colorScheme.tertiaryContainer;
      case 'in_progress':
      case 'active':
        return colorScheme.primaryContainer;
      case 'pending':
      case 'waiting':
        return colorScheme.secondaryContainer;
      case 'draft':
        return _whoOrange.withValues(alpha: 0.12);
      case 'error':
      case 'failed':
        return colorScheme.errorContainer;
      default:
        return colorScheme.surfaceContainerHighest;
    }
  }
}

/// Abstract base class for theme colors
abstract class _ThemeColors {
  const _ThemeColors();

  ColorScheme get colorScheme;
  Color get background;
  Color get outline;
}

/// Light theme color definitions
class _LightColors extends _ThemeColors {
  const _LightColors();

  @override
  Color get background => const Color(0xFFF5F7FA); // Slightly blue-tinted gray

  @override
  Color get outline => const Color(0xFFDCE2E9); // Softer outline

  @override
  ColorScheme get colorScheme => const ColorScheme.light(
    // Primary colors
    primary: AppTheme._whoBluePrimary,
    onPrimary: AppTheme._white,
    primaryContainer: Color(0xFFCCE8F7), // Lighter, more vibrant
    onPrimaryContainer: Color(0xFF001D36),

    // Secondary colors
    secondary: AppTheme._whoBlueLight,
    onSecondary: AppTheme._white,
    secondaryContainer: Color(0xFFD4F3FF), // Lighter secondary container
    onSecondaryContainer: Color(0xFF001E2B),

    // Tertiary colors (success/green)
    tertiary: AppTheme._whoGreen,
    onTertiary: AppTheme._white,
    tertiaryContainer: Color(0xFFD4F0D4), // Softer green container
    onTertiaryContainer: Color(0xFF002106),

    // Error colors
    error: AppTheme._errorRed,
    onError: AppTheme._white,
    errorContainer: Color(0xFFFDE7E7), // Softer error container
    onErrorContainer: Color(0xFF410002),

    // Enhanced surface colors with better distinction
    surface: AppTheme._white,
    onSurface: Color(0xFF1C1F23), // Slightly darker for better contrast
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFFAFBFC), // Very subtle tint
    surfaceContainer: Color(0xFFF5F7FA), // Noticeable but light
    surfaceContainerHigh: Color(0xFFEEF2F6), // More distinct
    surfaceContainerHighest: Color(0xFFE6EBF1), // Clear distinction
    onSurfaceVariant: Color(0xFF525860), // Better contrast
    // Outline colors
    outline: Color(0xFFDCE2E9), // Softer, modern outline
    outlineVariant: Color(0xFFEBEFF3), // Very subtle outline
    // Utility colors
    shadow: Color(0xFF000000), // Pure black for shadows
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF1A2332),
    onInverseSurface: Color(0xFFE8F4FD),
    inversePrimary: Color(0xFF4FC3F7),
    surfaceTint: Colors.transparent, // No tint for cleaner look
  );
}

/// Dark theme color definitions
class _DarkColors extends _ThemeColors {
  const _DarkColors();

  @override
  Color get background => const Color(0xFF0A0E14); // Rich dark background

  @override
  Color get outline => const Color(0xFF2A3441); // Subtle dark outline

  @override
  ColorScheme get colorScheme => const ColorScheme.dark(
    // Primary colors
    primary: Color(0xFF4FC3F7),
    onPrimary: Color(0xFF001D36),
    primaryContainer: Color(0xFF0277BD),
    onPrimaryContainer: Color(0xFFE3F2FD),

    // Secondary colors
    secondary: Color(0xFF81D4FA),
    onSecondary: Color(0xFF001E2B),
    secondaryContainer: Color(0xFF01579B),
    onSecondaryContainer: Color(0xFFE1F5FE),

    // Tertiary colors (success/green)
    tertiary: Color(0xFF66BB6A),
    onTertiary: Color(0xFF002106),
    tertiaryContainer: Color(0xFF1B5E20),
    onTertiaryContainer: Color(0xFFE8F5E8),

    // Error colors
    error: Color(0xFFEF5350),
    onError: Color(0xFF410002),
    errorContainer: Color(0xFFB71C1C),
    onErrorContainer: Color(0xFFFFEBEE),

    // Enhanced dark surface colors with clear hierarchy
    surface: Color(0xFF161B22), // Card/elevated surface
    onSurface: Color(0xFFE6EDF3), // High contrast text
    surfaceContainerLowest: Color(0xFF0A0E14), // Background
    surfaceContainerLow: Color(0xFF0F1419), // Slightly elevated
    surfaceContainer: Color(0xFF1A2029), // Default container
    surfaceContainerHigh: Color(0xFF1F252E), // Elevated container
    surfaceContainerHighest: Color(0xFF252C37), // Highest elevation
    onSurfaceVariant: Color(0xFFADBBC7), // Good contrast for secondary text
    // Outline colors
    outline: Color(0xFF2A3441), // Visible but not harsh
    outlineVariant: Color(0xFF1F252E), // Subtle variant
    // Utility colors
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppTheme._white,
    onInverseSurface: Color(0xFF1C1F23),
    inversePrimary: AppTheme._whoBluePrimary,
    surfaceTint: Colors.transparent,
  );
}
