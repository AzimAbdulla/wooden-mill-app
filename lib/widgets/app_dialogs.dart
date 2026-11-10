import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/theme/app_semantic_colors.dart';

enum SnackKind { info, success, error }

/// [bottomInset] lifts the message above a sticky bar at the bottom of the screen.
void showAppSnack(
  BuildContext context,
  String message, {
  SnackKind kind = SnackKind.info,
  double bottomInset = 0,
}) {
  final scheme = Theme.of(context).colorScheme;
  final semantic = AppSemanticColors.of(context);

  final (Color? background, Color? foreground) = switch (kind) {
    SnackKind.info => (null, null),
    SnackKind.success => (semantic.success, semantic.onSuccess),
    SnackKind.error => (scheme.error, scheme.onError),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, style: foreground == null ? null : TextStyle(color: foreground)),
        backgroundColor: background,
        margin: bottomInset > 0 ? EdgeInsets.fromLTRB(16, 0, 16, bottomInset) : null,
      ),
    );
}

/// Cancel / confirm dialog. [destructive] makes the confirm button red.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: scheme.error,
                    foregroundColor: scheme.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
