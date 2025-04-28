import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/transaction_model.dart';

import 'package:intl/intl.dart';

import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;

  const TransactionCard({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          '${transaction.category} - ر.س${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.type} on ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.pushNamed(context, '/transaction-form',
                    arguments: transaction);
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                BlocProvider.of<TransactionBloc>(context)
                    .add(DeleteTransactionEvent(transaction.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}