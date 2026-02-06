import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../bloc/sales_bloc.dart';
import '../bloc/events/sales_event.dart';
import '../bloc/states/sales_state.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/theme/app_theme.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<SalesBloc>()..add(GetSalesSummaryEvent()),
      child: const _SalesView(),
    );
  }
}

class _SalesView extends StatelessWidget {
  const _SalesView();

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      enableDoubleBackToExit: false,
      child: Scaffold(
      appBar: AppAppBar(
        title: 'Sales & Reports',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<SalesBloc, SalesState>(
        listener: (context, state) {
          if (state is SalesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Sales',
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SalesLoading) {
            return const SkeletonList(itemCount: 5, itemHeight: 100);
          }

          if (state is SalesError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<SalesBloc>().add(GetSalesSummaryEvent()),
            );
          }

          if (state is SalesSummaryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<SalesBloc>().add(GetSalesSummaryEvent());
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(summary: state.summary),
                    const SizedBox(height: 24),
                    _PaymentMethodBreakdown(summary: state.summary),
                    const SizedBox(height: 24),
                    if (state.groupedData.isNotEmpty) ...[
                      Text(
                        'Grouped Data',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      ...state.groupedData.map((data) => Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(data.key),
                              subtitle: Text('${data.bookings} bookings'),
                              trailing: Text(
                                'Rs. ${NumberFormat('#,##0.00').format(data.sales)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            );
          }

          return const EmptyStateWidget(
            icon: Icons.bar_chart,
            title: 'No data',
            description: 'Sales data will appear here when available.',
          );
        },
      ),
        ),
      
    );
  }

  void _showFilterDialog(BuildContext context) {
    final startDateController = TextEditingController();
    final endDateController = TextEditingController();

    AppDialog.show(
      context: context,
      title: 'Filter Sales',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: startDateController,
            decoration: const InputDecoration(
              labelText: 'Start Date (YYYY-MM-DD)',
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          TextField(
            controller: endDateController,
            decoration: const InputDecoration(
              labelText: 'End Date (YYYY-MM-DD)',
            ),
          ),
        ],
      ),
      primaryLabel: 'Apply',
      onPrimary: () {
        context.read<SalesBloc>().add(
              GetSalesSummaryEvent(
                startDate: startDateController.text.isEmpty
                    ? null
                    : startDateController.text,
                endDate: endDateController.text.isEmpty
                    ? null
                    : endDateController.text,
              ),
            );
        if (context.mounted) Navigator.of(context).pop();
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.currency_rupee,
                    label: 'Total Sales',
                    value: 'Rs. ${NumberFormat('#,##0.00').format(summary.totalSales)}',
                    color: AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.confirmation_number,
                    label: 'Bookings',
                    value: summary.totalBookings.toString(),
                    color: AppTheme.statusInfo,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    icon: Icons.account_balance_wallet,
                    label: 'Commission',
                    value: 'Rs. ${NumberFormat('#,##0.00').format(summary.totalCommission)}',
                    color: AppTheme.secondaryColor,
                  ),
                ),
                Expanded(
                  child: _StatItem(
                    icon: Icons.currency_rupee,
                    label: 'Refunds',
                    value: 'Rs. ${NumberFormat('#,##0.00').format(summary.totalRefunds)}',
                    color: AppTheme.warningColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodBreakdown extends StatelessWidget {
  final summary;

  const _PaymentMethodBreakdown({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method Breakdown',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _PaymentItem(
              label: 'Cash',
              amount: summary.cashSales,
              color: AppTheme.warningColor,
            ),
            _PaymentItem(
              label: 'Online',
              amount: summary.onlineSales,
              color: AppTheme.statusInfo,
            ),
            _PaymentItem(
              label: 'Wallet',
              amount: summary.walletSales,
              color: AppTheme.secondaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _PaymentItem extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _PaymentItem({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
          Text(
            'Rs. ${NumberFormat('#,##0.00').format(amount)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
