import 'package:flutter/material.dart';

/// Colours the Material scheme has no slot for.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  final Color success;
  final Color onSuccess;

  const AppSemanticColors({required this.success, required this.onSuccess});

  static const light = AppSemanticColors(
    success: Color(0xFF047857),
    onSuccess: Color(0xFFFFFFFF),
  );

  static const dark = AppSemanticColors(
    success: Color(0xFF34D399),
    onSuccess: Color(0xFF022C22),
  );

  static AppSemanticColors of(BuildContext context) =>
      Theme.of(context).extension<AppSemanticColors>() ?? light;

  @override
  AppSemanticColors copyWith({Color? success, Color? onSuccess}) => AppSemanticColors(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
      );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
    );
  }
}
