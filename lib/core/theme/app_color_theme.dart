import 'package:flutter/material.dart';

/// Selectable colour themes. Apart from Timber, each keeps a near-neutral
/// paper background and changes only the ink used for the main action and
/// the selected state.
enum AppColorTheme {
  plain('Plain'),
  timber('Timber'),
  teak('Teak'),
  leaf('Leaf'),
  ledgerBlue('Ledger blue'),
  laterite('Laterite');

  final String displayName;

  const AppColorTheme(this.displayName);

  ColorScheme get lightScheme => switch (this) {
        plain => _plainLight,
        timber => _timberLight,
        teak => _paperLight(
            accent: const Color(0xFF7A4A21),
            page: const Color(0xFFF7F4EE),
            field: const Color(0xFFFDFBF7),
            selected: const Color(0xFFEFE9DF),
            ink: const Color(0xFF1F1B16),
            muted: const Color(0xFF5E554A),
            line: const Color(0xFFE6DFD3),
            border: const Color(0xFFB5AA9A),
          ),
        leaf => _paperLight(
            accent: const Color(0xFF1F6B4A),
            page: const Color(0xFFF6F7F4),
            field: const Color(0xFFFFFFFF),
            selected: const Color(0xFFE3EBE3),
            ink: const Color(0xFF171A17),
            muted: const Color(0xFF505A52),
            line: const Color(0xFFE1E5DF),
            border: const Color(0xFFA3ABA3),
          ),
        ledgerBlue => _paperLight(
            accent: const Color(0xFF1E4E8C),
            page: const Color(0xFFF5F7FA),
            field: const Color(0xFFFFFFFF),
            selected: const Color(0xFFE1E9F4),
            ink: const Color(0xFF111827),
            muted: const Color(0xFF4B5565),
            line: const Color(0xFFE1E6EE),
            border: const Color(0xFFA0A9B8),
          ),
        laterite => _paperLight(
            accent: const Color(0xFF9A3B26),
            page: const Color(0xFFF8F5F2),
            field: const Color(0xFFFFFFFF),
            selected: const Color(0xFFF1E4DE),
            ink: const Color(0xFF1F1917),
            muted: const Color(0xFF5F534E),
            line: const Color(0xFFE9E0DA),
            border: const Color(0xFFB8A9A1),
          ),
      };

  ColorScheme get darkScheme => switch (this) {
        plain => _plainDark,
        timber => _timberDark,
        teak => _inkOnDark(const Color(0xFFD9A774)),
        leaf => _inkOnDark(const Color(0xFF7BC9A0)),
        ledgerBlue => _inkOnDark(const Color(0xFF8FB4E8)),
        laterite => _inkOnDark(const Color(0xFFE59A84)),
      };

  /// Color palette preview dots (Primary, Secondary, Surface)
  List<Color> getPreviewColors(bool isDark) {
    final scheme = isDark ? darkScheme : lightScheme;
    return [
      scheme.primary,
      scheme.secondary,
      scheme.primaryContainer,
    ];
  }

  static ColorScheme _paperLight({
    required Color accent,
    required Color page,
    required Color field,
    required Color selected,
    required Color ink,
    required Color muted,
    required Color line,
    required Color border,
  }) {
    return ColorScheme.light(
      primary: accent,
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: selected,
      onPrimaryContainer: ink,
      secondary: muted,
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: selected,
      onSecondaryContainer: ink,
      surface: page,
      onSurface: ink,
      onSurfaceVariant: muted,
      surfaceContainerLowest: field,
      surfaceContainerLow: selected,
      surfaceContainer: selected,
      surfaceContainerHigh: line,
      surfaceContainerHighest: border,
      outline: border,
      outlineVariant: line,
      error: const Color(0xFFDC2626),
      onError: const Color(0xFFFFFFFF),
    );
  }

  /// The neutral dark scheme with a lightened version of the theme's ink.
  static ColorScheme _inkOnDark(Color accent) {
    return _plainDark.copyWith(primary: accent, onPrimary: const Color(0xFF18181B));
  }

  static const _plainLight = ColorScheme.light(
    primary: Color(0xFF18181B),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFF4F4F5),
    onPrimaryContainer: Color(0xFF18181B),
    secondary: Color(0xFF52525B),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFE4E4E7),
    onSecondaryContainer: Color(0xFF18181B),
    surface: Color(0xFFFAFAFA),
    onSurface: Color(0xFF18181B),
    onSurfaceVariant: Color(0xFF52525B),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF4F4F5),
    surfaceContainer: Color(0xFFE4E4E7),
    surfaceContainerHigh: Color(0xFFD4D4D8),
    surfaceContainerHighest: Color(0xFFA1A1AA),
    outline: Color(0xFFA1A1AA),
    outlineVariant: Color(0xFFE4E4E7),
    error: Color(0xFFEF4444),
    onError: Color(0xFFFFFFFF),
  );

  static const _plainDark = ColorScheme.dark(
    primary: Color(0xFFFAFAFA),
    onPrimary: Color(0xFF18181B),
    primaryContainer: Color(0xFF27272A),
    onPrimaryContainer: Color(0xFFFAFAFA),
    secondary: Color(0xFFA1A1AA),
    onSecondary: Color(0xFF18181B),
    secondaryContainer: Color(0xFF3F3F46),
    onSecondaryContainer: Color(0xFFFAFAFA),
    surface: Color(0xFF09090B),
    onSurface: Color(0xFFFAFAFA),
    onSurfaceVariant: Color(0xFFA1A1AA),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF18181B),
    surfaceContainer: Color(0xFF27272A),
    surfaceContainerHigh: Color(0xFF3F3F46),
    surfaceContainerHighest: Color(0xFF52525B),
    outline: Color(0xFF3F3F46),
    outlineVariant: Color(0xFF27272A),
    error: Color(0xFFF87171),
    onError: Color(0xFF09090B),
  );

  static const _timberLight = ColorScheme.light(
    primary: Color(0xFF006B54),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFF9FF3D5),
    onPrimaryContainer: Color(0xFF002017),
    secondary: Color(0xFF705C00),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFFEE16E),
    onSecondaryContainer: Color(0xFF221B00),
    surface: Color(0xFFF4FBF7),
    onSurface: Color(0xFF161D1A),
    onSurfaceVariant: Color(0xFF3F4944),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFEEF5F1),
    surfaceContainer: Color(0xFFE8EFEB),
    surfaceContainerHigh: Color(0xFFE2E9E5),
    surfaceContainerHighest: Color(0xFFDCE3DF),
    outline: Color(0xFF707974),
    outlineVariant: Color(0xFFBFC9C3),
    error: Color(0xFFBA1A1A),
    onError: Color(0xFFFFFFFF),
  );

  static const _timberDark = ColorScheme.dark(
    primary: Color(0xFF95D3BA),
    onPrimary: Color(0xFF003829),
    primaryContainer: Color(0xFF064E3B),
    onPrimaryContainer: Color(0xFF80BEA6),
    secondary: Color(0xFFE9C349),
    onSecondary: Color(0xFF3C2F00),
    secondaryContainer: Color(0xFFAF8D11),
    onSecondaryContainer: Color(0xFF342800),
    tertiary: Color(0xFFC8C6C5),
    onTertiary: Color(0xFF303030),
    tertiaryContainer: Color(0xFF454444),
    onTertiaryContainer: Color(0xFFB3B1B1),
    surface: Color(0xFF131313),
    onSurface: Color(0xFFE5E2E1),
    onSurfaceVariant: Color(0xFFBFC9C3),
    outline: Color(0xFF89938D),
    outlineVariant: Color(0xFF404944),
    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surfaceContainerLowest: Color(0xFF0E0E0E),
    surfaceContainerLow: Color(0xFF1C1B1B),
    surfaceContainer: Color(0xFF201F1F),
    surfaceContainerHigh: Color(0xFF2A2A2A),
    surfaceContainerHighest: Color(0xFF353534),
  );
}
