import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/budget_model.dart';
import 'package:fintrack/core/services/firestore_service.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/NotificationService.dart';
import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final FirestoreService firestoreService;
  final FirebaseAuth auth;
  final NotificationService notificationService;

  BudgetBloc({
    required this.firestoreService,
    required this.auth,
    required this.notificationService,
  }) : super(BudgetInitial()) {
    on<AddBudgetEvent>(_onAddBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<LoadBudgetsEvent>(_onLoadBudgets);
    _monitorTransactions();
  }

  void _monitorTransactions() {
    final userId = auth.currentUser!.uid;
    firestoreService.getTransactions(userId).listen((transactions) async {
      final budgets = await firestoreService.getBudgets(userId).first;
      for (var budget in budgets) {
        final expenses = await firestoreService.getTotalExpensesForCategory(
          userId,
          budget.category,
          budget.month,
        );
        if (expenses > budget.amount) {
          await notificationService.sendNotification(
            userId: userId,
            title: 'Budget Limit Exceeded',
            body: 'You have exceeded your budget of ${budget.amount} ر.س for ${budget.category} in ${budget.month}. Total expenses: $expenses ر.س.',
          );
        }
      }
    });
  }

  Future<void> _onAddBudget(AddBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    print('Adding budget: ${event.budgetData}');
    try {
      final userId = auth.currentUser!.uid;
      final budget = Budget(
        id: '',
        userId: userId,
        category: event.budgetData['category'],
        amount: double.parse(event.budgetData['amount'].toString()),
        month: event.budgetData['month'],
      );
      await firestoreService.addBudget(userId, budget);
      print('Budget added successfully');
      final budgetStream = firestoreService.getBudgets(userId);
      await for (final budgets in budgetStream) {
        emit(BudgetLoaded(budgets));
        break;
      }
    } catch (e) {
      print('Failed to add budget: $e');
      emit(BudgetError('Failed to add budget: $e'));
    }
  }

  Future<void> _onUpdateBudget(UpdateBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    print('Updating budget ID: ${event.budgetId} with data: ${event.budgetData}');
    try {
      final userId = auth.currentUser!.uid;
      final budget = Budget(
        id: event.budgetId,
        userId: userId,
        category: event.budgetData['category'],
        amount: double.parse(event.budgetData['amount'].toString()),
        month: event.budgetData['month'],
      );
      await firestoreService.updateBudget(userId, budget);
      print('Budget updated successfully');
      final budgetStream = firestoreService.getBudgets(userId);
      await for (final budgets in budgetStream) {
        emit(BudgetLoaded(budgets));
        break;
      }
    } catch (e) {
      print('Failed to update budget: $e');
      emit(BudgetError('Failed to update budget: $e'));
    }
  }

  Future<void> _onDeleteBudget(DeleteBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    print('Deleting budget with ID: ${event.budgetId}');
    try {
      final userId = auth.currentUser!.uid;
      if (event.budgetId.isEmpty) {
        throw Exception('Budget ID is empty');
      }
      await firestoreService.deleteBudget(userId, event.budgetId);
      print('Budget deleted successfully');
      final budgetStream = firestoreService.getBudgets(userId);
      await for (final budgets in budgetStream) {
        emit(BudgetLoaded(budgets));
        break;
      }
    } catch (e) {
      print('Failed to delete budget: $e');
      emit(BudgetError('Failed to delete budget: $e'));
    }
  }

  Future<void> _onLoadBudgets(LoadBudgetsEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    print('Starting to load budgets');
    try {
      final userId = auth.currentUser!.uid;
      final budgetStream = firestoreService.getBudgets(userId);
      print('Budget stream obtained');
      await for (final budgets in budgetStream) {
        print('Budgets loaded: ${budgets.length} items - $budgets');
        emit(BudgetLoaded(budgets));
      }
      print('Budget stream completed');
    } catch (e) {
      print('Failed to load budgets: $e');
      emit(BudgetError('Failed to load budgets: $e'));
    }
  }
}