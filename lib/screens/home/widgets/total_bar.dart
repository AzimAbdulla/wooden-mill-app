import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/screens/home/home_controller.dart';

/// Sticky bar with the running total and the single Save action.
class TotalBar extends StatelessWidget {
  final HomeController controller;
  final VoidCallback onSave;

  const TotalBar({super.key, required this.controller, required this.onSave});

  /// Bottom margin that keeps a snackbar clear of this bar.
  static const double snackInset = 104;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final saving = controller.isSaving;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ShadTokens.spaceLg,
        vertical: ShadTokens.spaceMd,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total · ${VolumeCalculator.formatVolume(controller.totalVolume)} cft',
                  style: theme.textTheme.bodySmall?.copyWith(fontFeatures: AppTheme.tabular),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    VolumeCalculator.formatCurrency(controller.finalPrice),
                    style: theme.textTheme.headlineSmall?.copyWith(fontFeatures: AppTheme.tabular),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: ShadTokens.spaceMd),
          FilledButton.icon(
            onPressed: saving ? null : onSave,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(saving ? 'Saving…' : 'Save order'),
          ),
        ],
      ),
    );
  }
}
