import 'package:equatable/equatable.dart';
import 'package:fintrack/core/models/budget_model.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();
  @override
  List<Object?> get props => [];
}

class LoadBudgetsEvent extends BudgetEvent {
  const LoadBudgetsEvent();
}

class AddBudgetEvent extends BudgetEvent {
  final Map<String, dynamic> budgetData;
  const AddBudgetEvent(this.budgetData);
  @override
  List<Object?> get props => [budgetData];
}

class UpdateBudgetEvent extends BudgetEvent {
  final String budgetId;
  final Map<String, dynamic> budgetData;
  const UpdateBudgetEvent(this.budgetId, this.budgetData);
  @override
  List<Object?> get props => [budgetId, budgetData];
}

class DeleteBudgetEvent extends BudgetEvent {
  final String budgetId;
  const DeleteBudgetEvent(this.budgetId);
  @override
  List<Object?> get props => [budgetId];
}