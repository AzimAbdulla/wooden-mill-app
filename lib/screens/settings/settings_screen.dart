import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/theme/app_color_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/theme/theme_controller.dart';
import 'package:wooden_mill_app/main.dart';
import 'package:wooden_mill_app/screens/settings/backup_section.dart';
import 'package:wooden_mill_app/screens/settings/wood_species_section.dart';
import 'package:wooden_mill_app/widgets/app_dialogs.dart';
import 'package:wooden_mill_app/widgets/app_section.dart';
import 'package:wooden_mill_app/widgets/key_value_row.dart';
import 'package:wooden_mill_app/widgets/select_pill.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _resetSettings(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Reset settings?',
      message: 'Theme, colour and text size go back to their defaults. '
          'Your orders and wood rates are not affected.',
      confirmLabel: 'Reset settings',
      destructive: true,
    );
    if (!confirmed) return;

    await themeController.resetSettings();
    if (context.mounted) showAppSnack(context, 'Settings reset');
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: ShadTokens.spaceXl),
          children: [
            const WoodSpeciesSection(),
            const BackupSection(),
            const _AppearanceSection(),
            const AppSection(
              title: 'About',
              child: Column(
                children: [
                  KeyValueRow(label: 'App', value: 'Timbr'),
                  KeyValueRow(label: 'Version', value: AppConstants.appVersionName),
                  KeyValueRow(label: 'Build', value: AppConstants.appBuildNumber),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ShadTokens.spaceLg,
                ShadTokens.spaceXl,
                ShadTokens.spaceLg,
                0,
              ),
              child: TextButton.icon(
                onPressed: () => _resetSettings(context),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Reset settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  const _AppearanceSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: themeController,
      builder: (context, _) {
        final density = themeController.displayDensity;

        return AppSection(
          title: 'Appearance',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<AppDisplayDensity>(
                initialValue: density,
                decoration: const InputDecoration(labelText: 'Text size'),
                items: [
                  for (final option in AppDisplayDensity.values)
                    DropdownMenuItem(value: option, child: Text(option.label)),
                ],
                onChanged: (value) {
                  if (value != null) themeController.setDisplayDensity(value);
                },
              ),
              if (density != AppDisplayDensity.recommended)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () =>
                        themeController.setDisplayDensity(AppDisplayDensity.recommended),
                    child: const Text('Reset to recommended'),
                  ),
                ),
              const SizedBox(height: ShadTokens.spaceLg),
              Text('Theme', style: theme.textTheme.bodySmall),
              const SizedBox(height: ShadTokens.spaceSm),
              SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                  ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ],
                selected: {themeController.themeMode},
                onSelectionChanged: (selection) => themeController.setThemeMode(selection.first),
              ),
              const SizedBox(height: ShadTokens.spaceLg),
              Text('Colour', style: theme.textTheme.bodySmall),
              const SizedBox(height: ShadTokens.spaceSm),
              Wrap(
                spacing: ShadTokens.spaceSm,
                runSpacing: ShadTokens.spaceSm,
                children: [
                  for (final option in AppColorTheme.values)
                    SelectPill(
                      label: option.displayName,
                      selected: themeController.colorTheme == option,
                      onTap: () => themeController.setColorTheme(option),
                      leading: _PaletteDots(colors: option.getPreviewColors(isDark)),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaletteDots extends StatelessWidget {
  final List<Color> colors;

  const _PaletteDots({required this.colors});

  @override
  Widget build(BuildContext context) {
    final outline = Theme.of(context).colorScheme.outline;

    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: ShadTokens.space2xs,
      children: [
        for (final color in colors)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: outline, width: 0.5),
            ),
          ),
      ],
    );
  }
}
