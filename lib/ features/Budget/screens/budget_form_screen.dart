import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/budget_model.dart';


import '../bloc/budget_bloc.dart';
import '../bloc/budget_event.dart';
import '../widgets/budget_form.dart';

class BudgetFormScreen extends StatelessWidget {
  final Budget? budget;

  const BudgetFormScreen({super.key, this.budget});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(budget == null ? 'Add Budget' : 'Edit Budget'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BudgetForm(
          budget: budget,
          onSubmit: (budgetData) {
            if (budget == null) {
              BlocProvider.of<BudgetBloc>(context).add(
                AddBudgetEvent(budgetData),
              );
            } else {
              BlocProvider.of<BudgetBloc>(context).add(
                UpdateBudgetEvent(budget!.id, budgetData),
              );
            }
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}