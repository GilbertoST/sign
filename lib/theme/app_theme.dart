import 'package:flutter/material.dart';

/// Design tokens and themes for Sign.
///
/// Blue, orange, green and purple stay the identity, at a deeper,
/// less saturated range. Surfaces are off-white paper and white cards.
class AppTheme {
  // Brand
  static const primaryColor = Color(0xFF2563EB);
  static const primaryBright = Color(0xFF3B82F6);
  static const secondaryColor = Color(0xFFF97316);
  static const secondaryBright = Color(0xFFFB923C);
  static const successColor = Color(0xFF16A34A);
  static const successBright = Color(0xFF22C55E);
  static const purple = Color(0xFF7C3AED);
  static const purpleBright = Color(0xFF8B5CF6);
  static const errorColor = Color(0xFFDC2626);
  static const amber = Color(0xFFD97706);

  // Neutrals, light
  static const backgroundColor = Color(0xFFF7F8FA);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const inkSoft = Color(0xFF374151);
  static const hairline = Color(0xFFE6E8ED);
  static const well = Color(0xFFF1F3F6);
  static const track = Color(0xFFE7E9EE);

  // Neutrals, dark
  static const darkBackground = Color(0xFF0F1115);
  static const darkSurface = Color(0xFF181B21);
  static const darkInk = Color(0xFFF3F4F6);
  static const darkMuted = Color(0xFF9CA3AF);
  static const darkHairline = Color(0xFF2A2E36);
  static const darkWell = Color(0xFF22262E);
  static const darkTrack = Color(0xFF2A2E36);

  // Spacing scale
  static const double space2xs = 4;
  static const double spaceXs = 8;
  static const double spaceSm = 12;
  static const double spaceMd = 16;
  static const double page = 20;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 40;

  static const double paddingXSmall = space2xs;
  static const double paddingSmall = spaceXs;
  static const double paddingMedium = spaceMd;
  static const double paddingLarge = spaceLg;
  static const double paddingXLarge = spaceXl;

  // Radii
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusButton = 14;
  static const double radiusCard = 18;
  static const double radiusXl = 24;
  static const double radiusPill = 999;

  static const double borderRadiusSmall = radiusXs;
  static const double borderRadiusMedium = radiusSm;
  static const double borderRadiusLarge = radiusCard;
  static const double borderRadiusXLarge = radiusXl;

  static const double buttonHeight = 52;

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x120F172A),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(
      color: Color(0x66000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: Color(0x332563EB),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const primaryGradient = LinearGradient(
    colors: [primaryBright, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const successGradient = LinearGradient(
    colors: [successBright, successColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const orangeGradient = LinearGradient(
    colors: [secondaryBright, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleGradient = LinearGradient(
    colors: [purpleBright, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Color line(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkHairline : hairline;

  static Color cardColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurface : surface;

  static List<BoxShadow> shadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkCardShadow : cardShadow;

  static Color difficultyColor(int difficulty) {
    switch (difficulty) {
      case 1:
        return successColor;
      case 2:
        return secondaryColor;
      case 3:
        return errorColor;
      default:
        return muted;
    }
  }

  static Color namedColor(String name) {
    switch (name.toLowerCase()) {
      case 'blue':
        return primaryColor;
      case 'orange':
        return secondaryColor;
      case 'green':
        return successColor;
      case 'purple':
        return purple;
      case 'red':
        return errorColor;
      case 'yellow':
        return amber;
      default:
        return primaryColor;
    }
  }

  static ThemeData lightTheme = _build(Brightness.light);
  static ThemeData darkTheme = _build(Brightness.dark);

  static TextTheme _textTheme(Color inkColor, Color mutedColor) {
    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
        height: 1.12,
        color: inkColor,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.55,
        height: 1.15,
        color: inkColor,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.45,
        height: 1.18,
        color: inkColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.35,
        height: 1.25,
        color: inkColor,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.15,
        height: 1.3,
        color: inkColor,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        height: 1.3,
        color: inkColor,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: inkColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: inkColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: mutedColor,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.12,
        color: inkColor,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.05,
        color: inkColor,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: mutedColor,
      ),
    );
  }

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final inkColor = dark ? darkInk : ink;
    final mutedColor = dark ? darkMuted : muted;
    final bg = dark ? darkBackground : backgroundColor;
    final card = dark ? darkSurface : surface;
    final lineColor = dark ? darkHairline : hairline;
    final wellColor = dark ? darkWell : well;
    final trackColor = dark ? darkTrack : track;
    final text = _textTheme(inkColor, mutedColor);

    final scheme = ColorScheme(
      brightness: brightness,
      primary: primaryColor,
      onPrimary: Colors.white,
      primaryContainer: dark ? const Color(0xFF1E3A8A) : const Color(0xFFDBE6FE),
      onPrimaryContainer: dark ? const Color(0xFFDBE6FE) : const Color(0xFF1E3A8A),
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer: dark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5),
      onSecondaryContainer: dark ? const Color(0xFFFFEDD5) : const Color(0xFF9A3412),
      tertiary: purple,
      onTertiary: Colors.white,
      tertiaryContainer: dark ? const Color(0xFF4C1D95) : const Color(0xFFEDE9FE),
      onTertiaryContainer: dark ? const Color(0xFFEDE9FE) : const Color(0xFF5B21B6),
      error: errorColor,
      onError: Colors.white,
      errorContainer: dark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
      onErrorContainer: dark ? const Color(0xFFFEE2E2) : const Color(0xFF991B1B),
      surface: card,
      onSurface: inkColor,
      onSurfaceVariant: mutedColor,
      outline: lineColor,
      outlineVariant: lineColor,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: dark ? surface : ink,
      onInverseSurface: dark ? ink : surface,
      inversePrimary: primaryBright,
      surfaceTint: Colors.transparent,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusButton),
    );
    const buttonText = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.12,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      splashFactory: InkRipple.splashFactory,
      textTheme: text,
      primaryTextTheme: text,
      iconTheme: IconThemeData(color: inkColor),
      dividerColor: lineColor,
      dividerTheme: DividerThemeData(
        color: lineColor,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: inkColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
          color: inkColor,
        ),
        iconTheme: IconThemeData(color: inkColor),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
          side: BorderSide(color: lineColor),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withValues(alpha: 0.40),
          disabledForegroundColor: Colors.white,
          minimumSize: const Size.fromHeight(buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: page),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: card,
          foregroundColor: inkColor,
          minimumSize: const Size(64, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: spaceMd, vertical: spaceSm),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusButton),
            side: BorderSide(color: lineColor),
          ),
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: inkColor,
          backgroundColor: card,
          minimumSize: const Size.fromHeight(buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: page),
          side: BorderSide(color: lineColor),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.1,
          ),
          shape: buttonShape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(
          color: mutedColor,
          fontWeight: FontWeight.w400,
          fontSize: 15,
        ),
        labelStyle: TextStyle(
          color: mutedColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: lineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: BorderSide(color: lineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusButton),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: wellColor,
        selectedColor: primaryColor.withValues(alpha: dark ? 0.28 : 0.12),
        disabledColor: wellColor,
        checkmarkColor: primaryColor,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: inkColor,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        side: BorderSide(color: lineColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusPill),
        ),
        elevation: 0,
        pressElevation: 0,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: trackColor,
        linearMinHeight: 8,
        borderRadius: BorderRadius.circular(radiusPill),
        circularTrackColor: trackColor,
        trackGap: 0,
        stopIndicatorRadius: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        indicatorColor: primaryColor.withValues(alpha: dark ? 0.24 : 0.12),
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: -0.05,
            color: selected ? primaryColor : mutedColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color: selected ? primaryColor : mutedColor,
          );
        }),
        overlayColor: WidgetStateProperty.all(
          primaryColor.withValues(alpha: 0.06),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: const Color(0xFF1F2937),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.35,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusButton),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: page, vertical: spaceMd),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
          side: BorderSide(color: lineColor),
        ),
        titleTextStyle: text.titleLarge?.copyWith(fontSize: 18),
        contentTextStyle: text.bodyMedium,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: primaryColor,
        textColor: inkColor,
        titleTextStyle: text.titleSmall,
        subtitleTextStyle: text.bodySmall,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        side: BorderSide(color: dark ? darkMuted : const Color(0xFFCBD0D8), width: 1.5),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return dark ? darkMuted : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryColor;
          return dark ? darkWell : track;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: CircleBorder(),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: card,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
      ),
    );
  }
}
