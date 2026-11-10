import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/widgets/dotted_rule.dart';
import 'package:wooden_mill_app/widgets/key_value_row.dart';

/// An order drawn as a paper receipt: tear edges, ledger leaders and the
/// final amount as the one big figure.
class ReceiptSlip extends StatelessWidget {
  final OrderModel order;

  /// Customer, phone, wood and date at the top.
  final bool showCustomer;

  /// One line per log with its measurements and volume.
  final bool showLogs;

  const ReceiptSlip({
    super.key,
    required this.order,
    this.showCustomer = true,
    this.showLogs = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final small = text.bodySmall?.copyWith(fontFeatures: AppTheme.tabular);
    final tearEdge = DottedRule(color: scheme.outline, dash: 6, gap: 4);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tearEdge,
        Container(
          padding: const EdgeInsets.all(ShadTokens.spaceLg),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.symmetric(vertical: BorderSide(color: scheme.outlineVariant)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showCustomer) ...[
                Text(order.customerName, style: text.titleMedium),
                Text('${order.phone}  ·  ${order.woodType}', style: small),
                Text(DateFormat('dd MMM yyyy, hh:mm a').format(order.dateTime), style: small),
                const SizedBox(height: ShadTokens.spaceMd),
              ],
              if (showLogs) ...[
                for (int i = 0; i < order.logs.length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: ShadTokens.space2xs),
                    child: Row(
                      children: [
                        SizedBox(width: 28, child: Text('${i + 1}', style: small)),
                        Expanded(
                          child: Text(
                            '${_trim(order.logs[i].length)} ft × ${_trim(order.logs[i].girth)} in',
                            style: text.bodyMedium?.copyWith(fontFeatures: AppTheme.tabular),
                          ),
                        ),
                        Text(
                          '${VolumeCalculator.formatVolume(order.logs[i].volume)} cft',
                          style: text.bodyMedium?.copyWith(fontFeatures: AppTheme.tabular),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: ShadTokens.spaceXl),
              ],
              KeyValueRow(
                label: 'Total volume',
                value: '${VolumeCalculator.formatVolume(order.totalVolume)} cft',
                leader: true,
              ),
              KeyValueRow(
                label: 'Subtotal',
                value: VolumeCalculator.formatCurrency(order.subtotal),
                leader: true,
              ),
              KeyValueRow(
                label: 'Cutting charge',
                value: '+ ${VolumeCalculator.formatCurrency(order.cuttingCharge)}',
                leader: true,
              ),
              KeyValueRow(
                label: 'Discount',
                value: '− ${VolumeCalculator.formatCurrency(order.discount)}',
                leader: true,
              ),
              Divider(height: ShadTokens.spaceXl, color: scheme.onSurface),
              KeyValueRow(
                label: 'Final amount',
                value: VolumeCalculator.formatCurrency(order.finalPrice),
                emphasis: true,
              ),
            ],
          ),
        ),
        tearEdge,
      ],
    );
  }

  /// 10.0 -> "10", 10.5 -> "10.5"
  static String _trim(double value) {
    return value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();
  }
}
