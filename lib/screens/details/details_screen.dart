import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/pdf_invoice_helper.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/widgets/app_dialogs.dart';
import 'package:wooden_mill_app/widgets/app_section.dart';
import 'package:wooden_mill_app/widgets/empty_state.dart';
import 'package:wooden_mill_app/widgets/receipt_slip.dart';
import 'package:wooden_mill_app/widgets/shad_badge.dart';

class DetailsScreen extends StatefulWidget {
  final int orderId;
  final bool isEmbedded;
  final VoidCallback? onDeleted;

  const DetailsScreen({
    super.key,
    required this.orderId,
    this.isEmbedded = false,
    this.onDeleted,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final OrderRepository _repository = OrderRepository();
  late Future<OrderModel?> _orderFuture;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  @override
  void didUpdateWidget(covariant DetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orderId != widget.orderId) {
      _loadOrder();
    }
  }

  void _loadOrder() {
    setState(() {
      _orderFuture = _repository.getOrderById(widget.orderId);
    });
  }

  Future<void> _deleteOrder(OrderModel order) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Delete this order?',
      message: 'The order for ${order.customerName} will be deleted. This can\'t be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;

    await _repository.deleteOrderById(order.id!);
    if (!mounted) return;

    showAppSnack(context, 'Order deleted');

    if (widget.onDeleted != null) {
      widget.onDeleted!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = FutureBuilder<OrderModel?>(
      future: _orderFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return EmptyState(
            icon: Icons.error_outline,
            isError: true,
            title: 'Couldn\'t load this order',
            actionLabel: 'Try again',
            onAction: _loadOrder,
          );
        }

        final order = snapshot.data;
        if (order == null) {
          return const EmptyState(icon: Icons.search_off, title: 'Order not found');
        }

        return _buildOrder(order);
      },
    );

    if (widget.isEmbedded) return body;

    return Scaffold(
      appBar: AppBar(title: const Text('Order details')),
      body: SafeArea(child: body),
    );
  }

  Widget _buildOrder(OrderModel order) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.only(bottom: ShadTokens.spaceXl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ShadTokens.spaceLg,
            ShadTokens.spaceXl,
            ShadTokens.spaceLg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(order.customerName, style: text.titleLarge)),
                  const SizedBox(width: ShadTokens.spaceMd),
                  ShadBadge(label: order.woodType, variant: ShadBadgeVariant.outline),
                ],
              ),
              const SizedBox(height: ShadTokens.spaceSm),
              _iconLine(Icons.phone_outlined, order.phone),
              const SizedBox(height: ShadTokens.spaceXs),
              _iconLine(
                Icons.calendar_today_outlined,
                DateFormat('dd MMMM yyyy, hh:mm a').format(order.dateTime),
              ),
            ],
          ),
        ),
        AppSection(
          title: 'Logs',
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('#')),
                    DataColumn(label: Text('Length (ft)'), numeric: true),
                    DataColumn(label: Text('Girth (in)'), numeric: true),
                    DataColumn(label: Text('Volume (cft)'), numeric: true),
                    DataColumn(label: Text('Price'), numeric: true),
                  ],
                  rows: [
                    for (int i = 0; i < order.logs.length; i++)
                      DataRow(
                        cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(order.logs[i].length.toStringAsFixed(1))),
                          DataCell(Text(order.logs[i].girth.toStringAsFixed(1))),
                          DataCell(Text(VolumeCalculator.formatVolume(order.logs[i].volume))),
                          DataCell(Text(VolumeCalculator.formatCurrency(order.logs[i].price))),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AppSection(
          title: 'Bill',
          child: ReceiptSlip(order: order, showCustomer: false, showLogs: false),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            ShadTokens.spaceLg,
            ShadTokens.space2xl,
            ShadTokens.spaceLg,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: () => PdfInvoiceHelper.printOrderInvoice(context, order),
                icon: const Icon(Icons.print_outlined),
                label: const Text('Print receipt'),
              ),
              const SizedBox(height: ShadTokens.spaceSm),
              TextButton.icon(
                onPressed: () => _deleteOrder(order),
                style: TextButton.styleFrom(foregroundColor: scheme.error),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete order'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconLine(IconData icon, String value) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: ShadTokens.spaceSm),
        Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
      ],
    );
  }
}
