import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';

/// A labelled block of content. Screens are built from these instead of cards.
class AppSection extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final Widget child;

  const AppSection({
    super.key,
    required this.title,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadTokens.spaceLg,
        ShadTokens.spaceXl,
        ShadTokens.spaceLg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 32),
            child: Row(
              children: [
                Expanded(child: Text(title, style: theme.textTheme.labelMedium)),
                ?trailing,
              ],
            ),
          ),
          const SizedBox(height: ShadTokens.spaceSm),
          child,
        ],
      ),
    );
  }
}
