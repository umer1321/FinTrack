import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/transaction_model.dart';


import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../widgets/transaction_form.dart';

class TransactionFormScreen extends StatelessWidget {
  final Transaction? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(transaction == null ? 'Add Transaction' : 'Edit Transaction'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TransactionForm(
          transaction: transaction,
          onSubmit: (transactionData) {
            if (transaction == null) {
              BlocProvider.of<TransactionBloc>(context).add(
                AddTransactionEvent(transactionData),
              );
            } else {
              BlocProvider.of<TransactionBloc>(context).add(
                UpdateTransactionEvent(transaction!.id, transactionData),
              );
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}