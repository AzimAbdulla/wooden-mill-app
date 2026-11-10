import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:wooden_mill_app/core/controllers/wood_type_controller.dart';
import 'package:wooden_mill_app/core/theme/app_theme.dart';
import 'package:wooden_mill_app/core/theme/shadcn_tokens.dart';
import 'package:wooden_mill_app/core/utils/export_helper.dart';
import 'package:wooden_mill_app/core/utils/responsive_layout.dart';
import 'package:wooden_mill_app/core/utils/volume_calculator.dart';
import 'package:wooden_mill_app/models/order.dart';
import 'package:wooden_mill_app/repositories/order_repository.dart';
import 'package:wooden_mill_app/screens/details/details_screen.dart';
import 'package:wooden_mill_app/widgets/empty_state.dart';
import 'package:wooden_mill_app/widgets/select_pill.dart';

enum DateFilterOption {
  all('All time'),
  today('Today'),
  thisWeek('This week'),
  thisMonth('This month');

  final String label;
  const DateFilterOption(this.label);
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const String _allWoods = 'All';

  final OrderRepository _repository = OrderRepository();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<OrderModel>> _ordersFuture;
  OrderModel? _selectedOrder;
  String _searchQuery = '';
  DateFilterOption _dateFilter = DateFilterOption.all;
  String _woodFilter = _allWoods;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _repository.getAllOrders();
    });
  }

  void _onOrderSelected(OrderModel order) {
    if (ResponsiveLayout.isPhone(context)) {
      context.push('/history/${order.id}').then((_) => _loadOrders());
    } else {
      setState(() => _selectedOrder = order);
    }
  }

  Future<void> _export() async {
    final orders = await _ordersFuture;
    if (mounted) ExportHelper.showExportOptionsModal(context, orders);
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startOfWeek = today.subtract(Duration(days: now.weekday - 1));

    return orders.where((order) {
      if (_searchQuery.isNotEmpty) {
        final matches = order.customerName.toLowerCase().contains(_searchQuery) ||
            order.phone.toLowerCase().contains(_searchQuery) ||
            order.woodType.toLowerCase().contains(_searchQuery);
        if (!matches) return false;
      }

      if (_woodFilter != _allWoods && order.woodType.toLowerCase() != _woodFilter.toLowerCase()) {
        return false;
      }

      final date = order.dateTime;
      return switch (_dateFilter) {
        DateFilterOption.all => true,
        DateFilterOption.today =>
          date.year == now.year && date.month == now.month && date.day == now.day,
        DateFilterOption.thisWeek => !date.isBefore(startOfWeek),
        DateFilterOption.thisMonth => date.year == now.year && date.month == now.month,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export orders (CSV or PDF)',
            onPressed: _export,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadOrders,
          ),
          const SizedBox(width: ShadTokens.spaceSm),
        ],
      ),
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.error_outline,
              isError: true,
              title: 'Couldn\'t load the orders',
              body: snapshot.error.toString(),
              actionLabel: 'Try again',
              onAction: _loadOrders,
            );
          }

          final allOrders = snapshot.data ?? [];
          if (allOrders.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              body: 'Orders you save from New order appear here.',
            );
          }

          final orders = _filterOrders(allOrders);
          // On tablets the first order is shown until the operator picks one.
          final selected = _selectedOrder ?? (orders.isNotEmpty ? orders.first : null);

          final list = Column(
            children: [
              _buildSearchBar(),
              _buildFilters(),
              const Divider(),
              Expanded(child: _buildOrderList(orders, selected)),
            ],
          );

          return ResponsiveLayout(
            phone: list,
            tablet: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 45, child: list),
                const VerticalDivider(),
                Expanded(
                  flex: 55,
                  child: selected == null
                      ? const EmptyState(
                          icon: Icons.touch_app_outlined,
                          title: 'Select an order to see its details',
                        )
                      : DetailsScreen(
                          orderId: selected.id!,
                          isEmbedded: true,
                          onDeleted: () {
                            setState(() => _selectedOrder = null);
                            _loadOrders();
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ShadTokens.spaceLg,
        ShadTokens.spaceLg,
        ShadTokens.spaceLg,
        ShadTokens.spaceSm,
      ),
      child: TextField(
        controller: _searchController,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search name, phone or wood',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  tooltip: 'Clear search',
                  onPressed: _searchController.clear,
                ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        ShadTokens.spaceLg,
        ShadTokens.spaceXs,
        ShadTokens.spaceLg,
        ShadTokens.spaceMd,
      ),
      child: ListenableBuilder(
        listenable: WoodTypeController.instance,
        builder: (context, _) {
          final woods = [_allWoods, ...WoodTypeController.instance.woodTypes.map((w) => w.name)];

          return Row(
            spacing: ShadTokens.spaceSm,
            children: [
              PopupMenuButton<DateFilterOption>(
                initialValue: _dateFilter,
                tooltip: 'Filter by date',
                onSelected: (option) => setState(() => _dateFilter = option),
                itemBuilder: (context) => [
                  for (final option in DateFilterOption.values)
                    PopupMenuItem(value: option, child: Text(option.label)),
                ],
                child: SelectPill(
                  label: _dateFilter.label,
                  selected: _dateFilter != DateFilterOption.all,
                  leading: const Icon(Icons.calendar_today_outlined, size: 18),
                  trailing: const Icon(Icons.arrow_drop_down),
                ),
              ),
              for (final wood in woods)
                SelectPill(
                  label: wood,
                  selected: _woodFilter.toLowerCase() == wood.toLowerCase(),
                  onTap: () => setState(() => _woodFilter = wood),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderList(List<OrderModel> orders, OrderModel? selected) {
    if (orders.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No matching orders',
        body: 'Try a different search or filter.',
      );
    }

    final highlightSelection = !ResponsiveLayout.isPhone(context);

    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _OrderRow(
          order: order,
          selected: highlightSelection && selected?.id == order.id,
          onTap: () => _onOrderSelected(order),
        );
      },
    );
  }
}

class _OrderRow extends StatelessWidget {
  final OrderModel order;
  final bool selected;
  final VoidCallback onTap;

  const _OrderRow({required this.order, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final logCount = order.logs.length;
    final small = text.bodySmall?.copyWith(fontFeatures: AppTheme.tabular);

    return Material(
      color: selected ? theme.colorScheme.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ShadTokens.spaceLg,
            vertical: ShadTokens.spaceMd,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      order.customerName,
                      style: text.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: ShadTokens.spaceMd),
                  Text(
                    VolumeCalculator.formatCurrency(order.finalPrice),
                    style: text.titleMedium?.copyWith(fontFeatures: AppTheme.tabular),
                  ),
                ],
              ),
              const SizedBox(height: ShadTokens.spaceXs),
              Text(
                '${order.woodType}  ·  $logCount ${logCount == 1 ? "log" : "logs"}  ·  '
                '${VolumeCalculator.formatVolume(order.totalVolume)} cft',
                style: small,
              ),
              Text(
                '${DateFormat('dd MMM yyyy, hh:mm a').format(order.dateTime)}  ·  ${order.phone}',
                style: small,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
