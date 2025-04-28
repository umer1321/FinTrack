import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/budget_model.dart';


import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../bloc/budget_state.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<BudgetBloc>(context).add(const LoadBudgetsEvent());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: const Color(0xFF4CAF50),
          backgroundColor: Colors.white,
          child: BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              if (state is BudgetLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is BudgetLoaded) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.budgets.length,
                  itemBuilder: (context, index) {
                    final budget = state.budgets[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(budget.category),
                        subtitle: Text('Budget: ر.س${budget.amount.toStringAsFixed(2)} - ${budget.month}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            BlocProvider.of<BudgetBloc>(context).add(DeleteBudgetEvent(budget.id));
                          },
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/budget-form',
                            arguments: budget,
                          );
                        },
                      ),
                    );
                  },
                );
              } else if (state is BudgetError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('No budgets found'));
            },
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/budget-form');
            },
            backgroundColor: const Color(0xFF4CAF50),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}