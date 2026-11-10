import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/app_color_theme.dart';
import 'package:wooden_mill_app/core/theme/app_semantic_colors.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

class AppTheme {
  AppTheme._();

  /// Equal-width digits so amounts and measurements line up.
  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];

  static ThemeData buildTheme(AppColorTheme colorTheme, {required bool isDark}) {
    final scheme = isDark ? colorTheme.darkScheme : colorTheme.lightScheme;
    final muted = scheme.onSurfaceVariant;
    final divider = scheme.outlineVariant;
    final fieldFill = isDark ? scheme.surfaceContainerLow : scheme.surfaceContainerLowest;
    final sheetColor = isDark ? scheme.surfaceContainer : scheme.surfaceContainerLowest;

    TextStyle text(double size, FontWeight weight, {Color? color}) =>
        TextStyle(fontSize: size, fontWeight: weight, color: color ?? scheme.onSurface);

    // Sized for older operators: body text is 16, nothing is below 13.
    final textTheme = TextTheme(
      headlineMedium: text(28, FontWeight.w600),
      headlineSmall: text(24, FontWeight.w600),
      titleLarge: text(20, FontWeight.w600),
      titleMedium: text(17, FontWeight.w600),
      titleSmall: text(15, FontWeight.w600),
      bodyLarge: text(16, FontWeight.w400),
      bodyMedium: text(15, FontWeight.w400),
      bodySmall: text(14, FontWeight.w400, color: muted),
      labelLarge: text(16, FontWeight.w600),
      labelMedium: text(14, FontWeight.w600, color: muted),
      labelSmall: text(13, FontWeight.w500, color: muted),
    );

    final controlShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusMd),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      extensions: [isDark ? AppSemanticColors.dark : AppSemanticColors.light],
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        shape: Border(bottom: BorderSide(color: divider)),
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        labelStyle: textTheme.bodyLarge?.copyWith(color: muted),
        floatingLabelStyle: textTheme.labelMedium,
        hintStyle: textTheme.bodyLarge?.copyWith(color: muted),
        errorStyle: textTheme.labelSmall?.copyWith(color: scheme.error),
        errorMaxLines: 2,
        border: inputBorder(scheme.outline),
        enabledBorder: inputBorder(scheme.outline),
        disabledBorder: inputBorder(divider),
        focusedBorder: inputBorder(scheme.primary, 2),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, 2),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          foregroundColor: scheme.onSurface,
          side: BorderSide(color: scheme.outline),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: controlShape,
          textStyle: textTheme.labelLarge,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(48, 48),
          side: BorderSide(color: scheme.outline),
          shape: controlShape,
          textStyle: textTheme.titleSmall,
        ),
      ),
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: sheetColor,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ShadTokens.radiusLg),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        elevation: 0,
        backgroundColor: sheetColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(ShadTokens.radiusLg)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall,
        iconColor: scheme.onSurface,
      ),
      dataTableTheme: DataTableThemeData(
        headingTextStyle: textTheme.labelMedium,
        dataTextStyle: textTheme.bodyMedium?.copyWith(fontFeatures: tabular),
        dividerThickness: 1,
        headingRowHeight: 44,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 56,
        horizontalMargin: 0,
        columnSpacing: 20,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 72,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return text(13, selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? scheme.onSurface : muted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? scheme.onSecondaryContainer : muted);
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.secondaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onSecondaryContainer),
        unselectedIconTheme: IconThemeData(color: muted),
        selectedLabelTextStyle: text(13, FontWeight.w600),
        unselectedLabelTextStyle: text(13, FontWeight.w500, color: muted),
      ),
      snackBarTheme: SnackBarThemeData(
        elevation: 0,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        shape: controlShape,
      ),
    );
  }
}
