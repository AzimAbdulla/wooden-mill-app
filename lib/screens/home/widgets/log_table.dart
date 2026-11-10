import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/screens/home/home_controller.dart';
import 'package:wooden_mill_app/widgets/app_section.dart';

/// The list of log measurement rows on the New order screen.
class LogTable extends StatelessWidget {
  final HomeController controller;
  final ValueChanged<int> onRemove;

  const LogTable({super.key, required this.controller, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final logs = controller.logs;
    final canAdd = logs.length < AppConstants.maxLogs;
    final canRemove = logs.length > AppConstants.minLogs;

    return AppSection(
      title: 'Logs · ${logs.length} of ${AppConstants.maxLogs}',
      trailing: OutlinedButton.icon(
        onPressed: canAdd ? controller.addLog : null,
        icon: const Icon(Icons.add),
        label: const Text('Add log'),
      ),
      child: Column(
        children: [
          for (int i = 0; i < logs.length; i++)
            _LogRow(
              number: i + 1,
              log: logs[i],
              onRemove: canRemove ? () => onRemove(i) : null,
            ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  final int number;
  final LogInput log;
  final VoidCallback? onRemove;

  const _LogRow({required this.number, required this.log, required this.onRemove});

  static const double _numberWidth = 28;
  static const double _fieldHeight = 56;

  static final _decimalOnly = [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: ShadTokens.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: _numberWidth,
                height: _fieldHeight,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('$number', style: theme.textTheme.labelMedium),
                ),
              ),
              Expanded(child: _field(log.lengthController, 'Length (ft)', log.lengthError)),
              const SizedBox(width: ShadTokens.spaceSm),
              Expanded(child: _field(log.girthController, 'Girth (in)', log.girthError)),
              SizedBox(
                width: 48,
                height: _fieldHeight,
                child: onRemove == null
                    ? null
                    : IconButton(
                        onPressed: onRemove,
                        icon: const Icon(Icons.close),
                        tooltip: 'Remove log $number',
                      ),
              ),
            ],
          ),
          if (log.volume > 0)
            Padding(
              padding: const EdgeInsets.only(left: _numberWidth, top: ShadTokens.spaceXs),
              child: Text(
                '${VolumeCalculator.formatVolume(log.volume)} cft  ·  '
                '${VolumeCalculator.formatCurrency(log.price)}',
                style: theme.textTheme.bodySmall?.copyWith(fontFeatures: AppTheme.tabular),
              ),
            ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, String? error) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label, errorText: error),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: _decimalOnly,
      textInputAction: TextInputAction.next,
    );
  }
}
