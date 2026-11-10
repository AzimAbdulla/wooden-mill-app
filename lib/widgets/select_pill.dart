import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

/// Tappable option with a clear selected state. Used for wood types, history
/// filters and colour themes. Leave [onTap] null when a parent handles the tap.
class SelectPill extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  const SelectPill({
    super.key,
    required this.label,
    this.subtitle,
    this.selected = false,
    this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final radius = BorderRadius.circular(ShadTokens.radiusMd);

    return Material(
      color: selected ? scheme.secondaryContainer : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(
          color: selected ? scheme.primary : scheme.outline,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: ShadTokens.spaceSm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: ShadTokens.spaceSm)],
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: selected
                            ? theme.textTheme.titleSmall
                            : theme.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontFeatures: AppTheme.tabular,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: ShadTokens.spaceXs), trailing!],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
