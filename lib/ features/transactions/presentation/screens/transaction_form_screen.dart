import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/transaction_model.dart';

import 'package:firebase_auth/firebase_auth.dart';

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
          onSubmit: (data) {
            final newTransaction = Transaction(
              id: transaction?.id ?? '',
              userId: FirebaseAuth.instance.currentUser!.uid,
              amount: double.parse(data['amount']),
              type: data['type'],
              category: data['category'],
              date: data['date'],
              description: data['description'],
            );
            if (transaction == null) {
              BlocProvider.of<TransactionBloc>(context)
                  .add(AddTransactionEvent(newTransaction));
            } else {
              BlocProvider.of<TransactionBloc>(context)
                  .add(UpdateTransactionEvent(newTransaction));
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}