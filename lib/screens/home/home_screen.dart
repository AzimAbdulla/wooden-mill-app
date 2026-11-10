import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wooden_mill_app/core/controllers/wood_type_controller.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/responsive_layout.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/screens/home/home_controller.dart';
import 'package:wooden_mill_app/screens/home/widgets/log_table.dart';
import 'package:wooden_mill_app/screens/home/widgets/order_dialogs.dart';
import 'package:wooden_mill_app/screens/home/widgets/total_bar.dart';
import 'package:wooden_mill_app/widgets/app_dialogs.dart';
import 'package:wooden_mill_app/widgets/app_section.dart';
import 'package:wooden_mill_app/widgets/key_value_row.dart';
import 'package:wooden_mill_app/widgets/select_pill.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _removeLog(int index) async {
    final log = _controller.logs[index];
    final hasData = log.lengthController.text.isNotEmpty || log.girthController.text.isNotEmpty;

    if (hasData) {
      final confirmed = await confirmDialog(
        context,
        title: 'Remove log ${index + 1}?',
        message: 'The length and girth you entered for this log will be lost.',
        confirmLabel: 'Remove',
        destructive: true,
      );
      if (!confirmed) return;
    }

    _controller.removeLogAt(index);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_controller.validateForm()) {
      showAppSnack(
        context,
        _controller.errorMessage ?? 'Check the order and try again',
        kind: SnackKind.error,
        bottomInset: TotalBar.snackInset,
      );
      return;
    }

    final confirmed = await showOrderConfirmDialog(context, _controller.buildOrder());
    if (!confirmed) return;

    final savedOrder = await _controller.submitOrder();
    if (!mounted) return;

    if (savedOrder == null) {
      showAppSnack(
        context,
        _controller.errorMessage ?? 'Couldn\'t save the order',
        kind: SnackKind.error,
        bottomInset: TotalBar.snackInset,
      );
      return;
    }

    _controller.clearForm();
    showOrderSavedDialog(context, savedOrder);
  }

  Future<void> _clear() async {
    final confirmed = await confirmDialog(
      context,
      title: 'Clear this order?',
      message: 'The customer details and all log measurements will be removed.',
      confirmLabel: 'Clear order',
      destructive: true,
    );
    if (confirmed) _controller.clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New order'),
        actions: [
          TextButton(onPressed: _clear, child: const Text('Clear')),
          const SizedBox(width: ShadTokens.spaceSm),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          final totalBar = TotalBar(controller: _controller, onSave: _submit);

          return SafeArea(
            child: ResponsiveLayout(
              phone: Column(
                children: [
                  Expanded(child: _sectionList([..._entrySections(), ..._billingSections()])),
                  totalBar,
                ],
              ),
              tablet: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _sectionList(_entrySections())),
                  const VerticalDivider(),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: _sectionList(_billingSections())),
                        totalBar,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionList(List<Widget> sections) {
    return ListView(
      padding: const EdgeInsets.only(bottom: ShadTokens.spaceXl),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: sections,
    );
  }

  List<Widget> _entrySections() {
    return [
      AppSection(
        title: 'Customer',
        child: Column(
          children: [
            TextField(
              controller: _controller.customerNameController,
              decoration: const InputDecoration(
                labelText: 'Customer name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.name,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: ShadTokens.spaceMd),
            TextField(
              controller: _controller.phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone number (10 digits)',
                prefixIcon: Icon(Icons.phone_outlined),
                counterText: '',
              ),
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
      AppSection(title: 'Wood', child: _WoodSelector(controller: _controller)),
      LogTable(controller: _controller, onRemove: _removeLog),
    ];
  }

  List<Widget> _billingSections() {
    final digitsOnly = [FilteringTextInputFormatter.digitsOnly];

    return [
      AppSection(
        title: 'Charges',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller.cuttingChargeController,
                decoration: const InputDecoration(labelText: 'Cutting charge', prefixText: '₹ '),
                keyboardType: TextInputType.number,
                inputFormatters: digitsOnly,
              ),
            ),
            const SizedBox(width: ShadTokens.spaceMd),
            Expanded(
              child: TextField(
                controller: _controller.discountController,
                decoration: const InputDecoration(labelText: 'Discount', prefixText: '₹ '),
                keyboardType: TextInputType.number,
                inputFormatters: digitsOnly,
              ),
            ),
          ],
        ),
      ),
      AppSection(
        title: 'Bill',
        child: Column(
          children: [
            KeyValueRow(
              label: 'Total volume',
              value: '${VolumeCalculator.formatVolume(_controller.totalVolume)} cft',
              leader: true,
            ),
            KeyValueRow(
              label: 'Subtotal',
              value: VolumeCalculator.formatCurrency(_controller.subtotal),
              leader: true,
            ),
            KeyValueRow(
              label: 'Cutting charge',
              value: '+ ${VolumeCalculator.formatCurrency(_controller.cuttingCharge)}',
              leader: true,
            ),
            KeyValueRow(
              label: 'Discount',
              value: '− ${VolumeCalculator.formatCurrency(_controller.discount)}',
              leader: true,
            ),
            const Divider(height: ShadTokens.spaceXl),
            KeyValueRow(
              label: 'Final amount',
              value: VolumeCalculator.formatCurrency(_controller.finalPrice),
              emphasis: true,
            ),
          ],
        ),
      ),
    ];
  }
}

class _WoodSelector extends StatelessWidget {
  final HomeController controller;

  const _WoodSelector({required this.controller});

  static const double _gap = ShadTokens.spaceSm;
  static const double _minTileWidth = 100;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: WoodTypeController.instance,
      builder: (context, _) {
        final woodTypes = WoodTypeController.instance.woodTypes;

        return LayoutBuilder(
          builder: (context, constraints) {
            final perRow = ((constraints.maxWidth + _gap) / (_minTileWidth + _gap)).floor().clamp(1, 3);
            final tileWidth = (constraints.maxWidth - _gap * (perRow - 1)) / perRow;

            return Wrap(
              spacing: _gap,
              runSpacing: _gap,
              children: [
                for (final wood in woodTypes)
                  SizedBox(
                    width: tileWidth,
                    child: SelectPill(
                      label: wood.name,
                      subtitle: '${VolumeCalculator.formatRate(wood.ratePerCft)} / cft',
                      selected: wood.id == controller.selectedWoodType.id,
                      onTap: () => controller.selectedWoodType = wood,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
