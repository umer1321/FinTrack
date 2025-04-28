import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fintrack/core/models/transaction_model.dart';


import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'ar_SA',
      symbol: 'ر.س',
      decimalDigits: 2,
    );

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          '${transaction.type == 'income' ? '+' : '-'} ${currencyFormatter.format(transaction.amount)}',
          style: TextStyle(
            color: transaction.type == 'income'
                ? const Color(0xFF4CAF50)
                : Colors.redAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.category),
            Text(DateFormat.yMMMd().format(transaction.date)),
            if (transaction.description.isNotEmpty)
              Text(
                transaction.description,
                style: TextStyle(color: Colors.grey[600]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF1A3C34)),
              onPressed: () {
                Navigator.pushNamed(context, '/transaction-form',
                    arguments: transaction);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              onPressed: () {
                context
                    .read<TransactionBloc>()
                    .add(DeleteTransactionEvent(transaction.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}