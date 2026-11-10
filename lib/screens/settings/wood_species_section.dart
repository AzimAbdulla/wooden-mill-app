import 'package:flutter/material.dart';
import 'package:wooden_mill_app/core/constants/app_constants.dart';
import 'package:wooden_mill_app/core/controllers/wood_type_controller.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/widgets/app_dialogs.dart';
import 'package:wooden_mill_app/widgets/app_section.dart';

/// Wood species and their rates: list, add, edit, delete, reset.
class WoodSpeciesSection extends StatelessWidget {
  const WoodSpeciesSection({super.key});

  static String _rate(double rate) => '${VolumeCalculator.formatRate(rate)} per cft';

  Future<void> _edit(BuildContext context, WoodTypeConfig wood) async {
    final updated = await showDialog<WoodTypeConfig>(
      context: context,
      builder: (context) => _SpeciesDialog(existing: wood),
    );
    if (updated == null) return;

    await WoodTypeController.instance.updateWoodType(updated);
    if (context.mounted) {
      showAppSnack(
        context,
        '${updated.name} is now ${_rate(updated.ratePerCft)}',
        kind: SnackKind.success,
      );
    }
  }

  Future<void> _add(BuildContext context) async {
    final added = await showDialog<WoodTypeConfig>(
      context: context,
      builder: (context) => const _SpeciesDialog(),
    );
    if (added == null) return;

    await WoodTypeController.instance.addWoodType(
      name: added.name,
      malayalamName: added.malayalamName,
      ratePerCft: added.ratePerCft,
    );
    if (context.mounted) {
      showAppSnack(
        context,
        '${added.name} added at ${_rate(added.ratePerCft)}',
        kind: SnackKind.success,
      );
    }
  }

  Future<void> _delete(BuildContext context, WoodTypeConfig wood) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete ${wood.name}?',
      message: '${wood.name} will no longer be offered for new orders. '
          'Orders already saved are not changed.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;

    await WoodTypeController.instance.deleteWoodType(wood.id);
    if (context.mounted) showAppSnack(context, '${wood.name} deleted');
  }

  Future<void> _resetDefaults(BuildContext context) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Reset wood rates?',
      message: 'Teak, Coconut and Others go back to '
          '${VolumeCalculator.formatRate(AppConstants.teakRate)}, '
          '${VolumeCalculator.formatRate(AppConstants.coconutRate)} and '
          '${VolumeCalculator.formatRate(AppConstants.othersRate)}. '
          'Species you added are removed.',
      confirmLabel: 'Reset rates',
      destructive: true,
    );
    if (!confirmed) return;

    await WoodTypeController.instance.resetToDefaults();
    if (context.mounted) showAppSnack(context, 'Wood rates reset');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListenableBuilder(
      listenable: WoodTypeController.instance,
      builder: (context, _) {
        final woodTypes = WoodTypeController.instance.woodTypes;

        return AppSection(
          title: 'Wood rates',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final wood in woodTypes) ...[
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: ShadTokens.spaceSm),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(wood.displayName, style: theme.textTheme.titleMedium),
                            Text(
                              '${_rate(wood.ratePerCft)}  ·  '
                              '${wood.isDefault ? "Standard" : "Added by you"}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontFeatures: AppTheme.tabular,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Edit ${wood.name}',
                      onPressed: () => _edit(context, wood),
                    ),
                    if (!wood.isDefault)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: scheme.error),
                        tooltip: 'Delete ${wood.name}',
                        onPressed: () => _delete(context, wood),
                      ),
                  ],
                ),
                const Divider(),
              ],
              const SizedBox(height: ShadTokens.spaceMd),
              OutlinedButton.icon(
                onPressed: () => _add(context),
                icon: const Icon(Icons.add),
                label: const Text('Add wood species'),
              ),
              TextButton(
                onPressed: () => _resetDefaults(context),
                child: const Text('Reset rates to defaults'),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Add ([existing] null) or edit a species. Pops the resulting [WoodTypeConfig].
class _SpeciesDialog extends StatefulWidget {
  final WoodTypeConfig? existing;

  const _SpeciesDialog({this.existing});

  @override
  State<_SpeciesDialog> createState() => _SpeciesDialogState();
}

class _SpeciesDialogState extends State<_SpeciesDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _malayalam = TextEditingController(text: widget.existing?.malayalamName);
  late final _rate = TextEditingController(
    text: widget.existing?.ratePerCft.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _name.dispose();
    _malayalam.dispose();
    _rate.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() != true) return;

    final existing = widget.existing;
    final name = _name.text.trim();
    final malayalam = _malayalam.text.trim();
    final rate = double.parse(_rate.text.trim());

    Navigator.of(context).pop(
      existing == null
          ? WoodTypeConfig(id: '', name: name, malayalamName: malayalam, ratePerCft: rate)
          : existing.copyWith(name: name, malayalamName: malayalam, ratePerCft: rate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existing;
    // Names of the built-in species are fixed; only their rate can change.
    final namesLocked = existing?.isDefault ?? false;

    return AlertDialog(
      title: Text(existing == null ? 'Add wood species' : 'Edit ${existing.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: ShadTokens.spaceXs),
              TextFormField(
                controller: _name,
                enabled: !namesLocked,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Name (English)',
                  hintText: 'Rosewood',
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Enter a name' : null,
              ),
              const SizedBox(height: ShadTokens.spaceMd),
              TextFormField(
                controller: _malayalam,
                enabled: !namesLocked,
                decoration: const InputDecoration(
                  labelText: 'Name (Malayalam, optional)',
                  hintText: 'ഈട്ടി',
                ),
              ),
              const SizedBox(height: ShadTokens.spaceMd),
              TextFormField(
                controller: _rate,
                autofocus: namesLocked,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Rate per cft',
                  prefixText: '₹ ',
                  hintText: '5500',
                ),
                validator: (value) {
                  final rate = double.tryParse(value?.trim() ?? '');
                  return (rate == null || rate <= 0) ? 'Enter a rate above 0' : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(existing == null ? 'Add species' : 'Save'),
        ),
      ],
    );
  }
}
