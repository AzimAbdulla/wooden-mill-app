import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/widgets/dotted_rule.dart';

/// "Label ........ value" line. [emphasis] is for the final amount.
/// [leader] draws ledger dots between the two and is used for bill rows only.
class KeyValueRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;
  final bool leader;

  const KeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
    this.leader = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;

    final labelStyle = emphasis
        ? text.titleMedium
        : text.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant);
    final valueStyle = (emphasis ? text.headlineSmall : text.titleMedium)
        ?.copyWith(fontFeatures: AppTheme.tabular);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: leader
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(label, style: labelStyle),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ShadTokens.spaceSm,
                      0,
                      ShadTokens.spaceSm,
                      6,
                    ),
                    child: DottedRule(color: theme.colorScheme.outline),
                  ),
                ),
                Text(value, style: valueStyle),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(label, style: labelStyle),
                const SizedBox(width: ShadTokens.spaceLg),
                Expanded(
                  child: Text(value, style: valueStyle, textAlign: TextAlign.end),
                ),
              ],
            ),
    );
  }
}
