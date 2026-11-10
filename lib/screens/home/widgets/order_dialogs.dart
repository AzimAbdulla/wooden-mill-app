import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wooden_mill_app/core/theme/app_semantic_colors.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/pdf_invoice_helper.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/widgets/receipt_slip.dart';

/// Asks the operator to check the order before it is saved.
Future<bool> showOrderConfirmDialog(BuildContext context, OrderModel order) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _OrderDialog(
      title: 'Check the order',
      order: order,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Confirm and save'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Go back'),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Shown after a successful save: print the receipt, open the order, or finish.
Future<void> showOrderSavedDialog(BuildContext context, OrderModel order) {
  final router = GoRouter.of(context);

  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _OrderDialog(
      icon: Icon(Icons.check_circle, color: AppSemanticColors.of(context).success, size: 28),
      title: 'Order #${order.id ?? 1} saved',
      order: order,
      actions: [
        FilledButton.icon(
          onPressed: () => PdfInvoiceHelper.printOrderInvoice(context, order),
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print receipt'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).pop();
            router.push('/history/${order.id}');
          },
          child: const Text('View details'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class _OrderDialog extends StatelessWidget {
  final Widget? icon;
  final String title;
  final OrderModel order;
  final List<Widget> actions;

  const _OrderDialog({
    this.icon,
    required this.title,
    required this.order,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(ShadTokens.spaceXl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ShadTokens.spaceLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (icon != null) ...[icon!, const SizedBox(width: ShadTokens.spaceSm)],
                  Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge)),
                ],
              ),
              const SizedBox(height: ShadTokens.spaceLg),
              ReceiptSlip(order: order),
              const SizedBox(height: ShadTokens.spaceLg),
              for (int i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: ShadTokens.spaceSm),
                actions[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
