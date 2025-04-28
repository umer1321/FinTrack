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
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Warning: ${transaction.category} expenses are nearing your budget of ر.س${budget.amount.toStringAsFixed(2)}!'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        } else if (totalExpenses >= budget.amount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Alert: ${transaction.category} expenses have exceeded your budget of ر.س${budget.amount.toStringAsFixed(2)}!'),
                              backgroundColor: Colors.red,
                            ),
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
                  return const Center(child: CircularProgressIndicator());
                } else if (state is TransactionLoaded) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = state.transactions[index];
                      return TransactionCard(transaction: transaction);
                    },
                  );
                } else if (state is TransactionError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: Text('No transactions found'));
              },
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/transaction-form');
            },
            backgroundColor: const Color(0xFF4CAF50),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}