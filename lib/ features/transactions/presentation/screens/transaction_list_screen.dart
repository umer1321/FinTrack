import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_card.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
      TransactionBloc()..add(const LoadTransactionsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transactions'),
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<TransactionBloc>(context)
                .add(const LoadTransactionsEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: const Color(0xFF4CAF50), // Soft green spinner
          backgroundColor: Colors.white,
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/transaction-form');
          },
          backgroundColor: const Color(0xFF4CAF50),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}