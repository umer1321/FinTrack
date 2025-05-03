import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/budget_model.dart';
import 'package:fintrack/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_card.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Curved background
        Container(
          height: 30,
          decoration: const BoxDecoration(
            color: Color(0xFF4CAF50),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),

        // Transaction list
        RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<TransactionBloc>(context)
                .add(const LoadTransactionsEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: const Color(0xFF4CAF50),
          backgroundColor: Colors.white,
          child: BlocListener<TransactionBloc, TransactionState>(
            listener: (context, state) async {
              if (state is TransactionLoaded) {
                final firestoreService =
                RepositoryProvider.of<FirestoreService>(context);
                final userId = state.transactions.isNotEmpty
                    ? state.transactions.first.userId
                    : '';
                if (userId.isNotEmpty) {
                  final budgets =
                  await firestoreService.getBudgets(userId).first;
                  for (var transaction in state.transactions) {
                    if (transaction.type == 'expense') {
                      final month =
                      DateFormat('yyyy-MM').format(transaction.date);
                      final budget = budgets.firstWhere(
                            (b) =>
                        b.category == transaction.category &&
                            b.month == month,
                        orElse: () => Budget(
                          id: '',
                          userId: '',
                          category: '',
                          amount: 0,
                          month: '',
                        ),
                      );
                      if (budget.amount > 0) {
                        final totalExpenses = await firestoreService
                            .getTotalExpensesForCategory(
                            userId, transaction.category, month);
                        final threshold = budget.amount * 0.9;
                        if (totalExpenses >= threshold &&
                            totalExpenses < budget.amount) {
                          _showNotification(
                            context,
                            'Warning: ${transaction.category} expenses are nearing your budget of ر.س${budget.amount.toStringAsFixed(2)}!',
                            Colors.orange,
                          );
                        } else if (totalExpenses >= budget.amount) {
                          _showNotification(
                            context,
                            'Alert: ${transaction.category} expenses have exceeded your budget of ر.س${budget.amount.toStringAsFixed(2)}!',
                            Colors.red,
                          );
                        }
                      }
                    }
                  }
                }
              }
            },
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF4CAF50),
                    ),
                  );
                } else if (state is TransactionLoaded) {
                  if (state.transactions.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = state.transactions[index];

                      // Group transactions by date
                      final bool showDate = index == 0 ||
                          !_isSameDay(
                            state.transactions[index].date,
                            state.transactions[index - 1].date,
                          );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDate) ...[
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 16.0,
                                bottom: 8.0,
                                left: 4.0,
                              ),
                              child: Text(
                                _formatDate(transaction.date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const Divider(),
                          ],
                          TransactionCard(transaction: transaction),
                        ],
                      );
                    },
                  );
                } else if (state is TransactionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            BlocProvider.of<TransactionBloc>(context)
                                .add(const LoadTransactionsEvent());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }
                return _buildEmptyState(context);
              },
            ),
          ),
        ),

        // Floating Action Button
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              Navigator.pushNamed(context, '/transaction-form');
            },
            backgroundColor: const Color(0xFF4CAF50),
            icon: const Icon(Icons.add),
            label: const Text('Add'),
            elevation: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          const Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first transaction to start tracking',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/transaction-form');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        ],
      ),
    );
  }

  void _showNotification(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'VIEW',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to budget details screen
            Navigator.pushNamed(context, '/budgets');
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    if (_isSameDay(date, now)) {
      return 'Today';
    } else if (_isSameDay(date, yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMMM d, y').format(date);
    }
  }
}