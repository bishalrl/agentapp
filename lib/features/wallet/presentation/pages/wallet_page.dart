import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/events/wallet_event.dart';
import '../bloc/states/wallet_state.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../../../core/injection/injection.dart' as di;
import '../../../../core/widgets/error_snackbar.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/app_bar.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/back_button_handler.dart';
import '../../../../core/widgets/enhanced_card.dart';
import '../../../../core/widgets/filter_chips.dart';
import '../../../../core/theme/app_theme.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<WalletBloc>()..add(GetTransactionsEvent()),
      child: const _WalletView(),
    );
  }
}

class _WalletView extends StatefulWidget {
  const _WalletView();

  @override
  State<_WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<_WalletView> {
  List<String> _selectedTypeFilter = [];

  List<Map<String, dynamic>> _groupTransactionsByDate(List transactions) {
    final Map<String, List> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final transaction in transactions) {
      final tx = transaction as WalletTransactionEntity;
      final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);

      String dateKey;
      if (txDate == today) {
        dateKey = 'today';
      } else if (txDate == yesterday) {
        dateKey = 'yesterday';
      } else {
        dateKey = DateFormat('yyyy-MM-dd').format(txDate);
      }

      grouped.putIfAbsent(dateKey, () => []).add(transaction);
    }

    final sortedGroups = grouped.entries.map((entry) {
      String label;
      if (entry.key == 'today') {
        label = 'Today';
      } else if (entry.key == 'yesterday') {
        label = 'Yesterday';
      } else {
        final date = DateTime.parse(entry.key);
        label = DateFormat('MMM d, y').format(date);
      }

      return {
        'key': entry.key,
        'label': label,
        'transactions': entry.value..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      };
    }).toList();

    sortedGroups.sort((a, b) {
      if (a['key'] == 'today') return -1;
      if (b['key'] == 'today') return 1;
      if (a['key'] == 'yesterday') return -1;
      if (b['key'] == 'yesterday') return 1;
      return b['key'].toString().compareTo(a['key'].toString());
    });

    return sortedGroups;
  }

  void _showAddMoneyDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    AppDialog.show(
      context: context,
      title: 'Add Money to Wallet',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: 'Rs. ',
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
            ),
          ),
        ],
      ),
      primaryLabel: 'Add',
      onPrimary: () {
        final amount = double.tryParse(amountController.text);
        if (amount != null && amount > 0) {
          context.read<WalletBloc>().add(
                AddMoneyEvent(
                  amount: amount,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                ),
              );
          if (context.mounted) Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            ErrorSnackBar(message: 'Please enter a valid amount', errorSource: 'Wallet'),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackButtonHandler(
      enableDoubleBackToExit: false,
      child: Scaffold(
      appBar: AppAppBar(
        title: 'Wallet',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMoneyDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<WalletBloc, WalletState>(
        listener: (context, state) {
          if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              ErrorSnackBar(
                message: state.message,
                errorSource: 'Wallet',
              ),
            );
          } else if (state is MoneyAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
               SuccessSnackBar(message: 'Money added successfully'),
            );
            context.read<WalletBloc>().add(GetTransactionsEvent());
          }
        },
        builder: (context, state) {
          if (state is WalletLoading) {
            return const SkeletonList(itemCount: 6, itemHeight: 72);
          }

          if (state is WalletError) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<WalletBloc>().add(GetTransactionsEvent()),
            );
          }

          if (state is TransactionsLoaded) {
            // Calculate balance from transactions
            double balance = 0.0;
            for (final transaction in state.transactions) {
              if (transaction.type == 'credit') {
                balance += transaction.amount;
              } else {
                balance -= transaction.amount;
              }
            }

            // Group transactions by date
            final groupedTransactions = _groupTransactionsByDate(state.transactions);
            final selectedType = _selectedTypeFilter.isEmpty ? null : _selectedTypeFilter.first;

            return Column(
              children: [
                // Header Card with Balance
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Wallet Balance',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                              ),
                              const SizedBox(height: AppTheme.spacingXS),
                              Text(
                                '₹${NumberFormat('#,##0.00').format(balance)}',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: () => _showAddMoneyDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Money'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                if (state.transactions.isNotEmpty)
                  FilterChips(
                    items: const [
                      FilterChipItem(label: 'All', value: 'all'),
                      FilterChipItem(label: 'Credit', value: 'credit', icon: Icons.arrow_downward),
                      FilterChipItem(label: 'Debit', value: 'debit', icon: Icons.arrow_upward),
                    ],
                    selectedValues: _selectedTypeFilter,
                    onSelectionChanged: (values) {
                      setState(() {
                        _selectedTypeFilter = values;
                      });
                    },
                  ),

                // Transactions List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<WalletBloc>().add(GetTransactionsEvent());
                    },
                    child: groupedTransactions.isEmpty
                        ? const EmptyStateWidget(
                            icon: Icons.filter_alt_off,
                            title: 'No transactions match filter',
                            description: 'Try adjusting your filters.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(AppTheme.spacingM),
                            itemCount: groupedTransactions.length,
                            itemBuilder: (context, index) {
                              final group = groupedTransactions[index];
                              final transactions = selectedType == null
                                  ? group['transactions'] as List
                                  : (group['transactions'] as List).where((t) {
                                      final tx = t as WalletTransactionEntity;
                                      return tx.type == selectedType;
                                    }).toList();

                              if (transactions.isEmpty) return const SizedBox.shrink();

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppTheme.spacingM,
                                      horizontal: AppTheme.spacingS,
                                    ),
                                    child: Text(
                                      group['label'] as String,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                  ...transactions.map((transaction) {
                                    return EnhancedCard(
                                      margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: transaction.type == 'credit'
                                              ? AppTheme.successColor.withOpacity(0.1)
                                              : AppTheme.errorColor.withOpacity(0.1),
                                          child: Icon(
                                            transaction.type == 'credit'
                                                ? Icons.arrow_downward
                                                : Icons.arrow_upward,
                                            color: transaction.type == 'credit'
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor,
                                          ),
                                        ),
                                        title: Text(
                                          transaction.description,
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        subtitle: Text(
                                          DateFormat('HH:mm').format(transaction.createdAt),
                                        ),
                                        trailing: Text(
                                          '${transaction.type == 'credit' ? '+' : '-'}₹${NumberFormat('#,##0.00').format(transaction.amount)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: transaction.type == 'credit'
                                                ? AppTheme.successColor
                                                : AppTheme.errorColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          }

          return EmptyStateWidget(
            icon: Icons.account_balance_wallet_outlined,
            title: 'No transactions',
            description: 'Your wallet transactions will appear here.',
            actionLabel: 'Add money',
            onAction: () => _showAddMoneyDialog(context),
          );
        },
      ),
      ),
    );
  }
}
