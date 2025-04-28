import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fintrack/core/models/budget_model.dart';
import 'package:fintrack/core/services/firestore_service.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'budget_event.dart';
import 'budget_state.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final FirestoreService firestoreService;
  final FirebaseAuth auth;

  BudgetBloc({required this.firestoreService, required this.auth})
      : super(BudgetInitial()) {
    on<AddBudgetEvent>(_onAddBudget);
    on<UpdateBudgetEvent>(_onUpdateBudget);
    on<DeleteBudgetEvent>(_onDeleteBudget);
    on<LoadBudgetsEvent>(_onLoadBudgets);
  }

  Future<void> _onAddBudget(
      AddBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final userId = auth.currentUser!.uid;
      final budget = Budget(
        id: '',
        userId: userId,
        category: event.budgetData['category'],
        amount: double.parse(event.budgetData['amount']),
        month: event.budgetData['month'],
      );
      await firestoreService.addBudget(userId, budget);
    } catch (e) {
      emit(BudgetError('Failed to add budget: $e'));
    }
  }

  Future<void> _onUpdateBudget(
      UpdateBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final userId = auth.currentUser!.uid;
      final budget = Budget(
        id: event.budgetId,
        userId: userId,
        category: event.budgetData['category'],
        amount: double.parse(event.budgetData['amount']),
        month: event.budgetData['month'],
      );
      await firestoreService.updateBudget(userId, budget);
    } catch (e) {
      emit(BudgetError('Failed to update budget: $e'));
    }
  }

  /*Future<void> _onDeleteBudget(
      DeleteBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final userId = auth.currentUser!.uid;
      await firestoreService.deleteBudget(userId, event.budgetId);
    } catch (e) {
      emit(BudgetError('Failed to delete budget: $e'));
    }
  }*/
  Future<void> _onDeleteBudget(
      DeleteBudgetEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final userId = auth.currentUser!.uid;
      print('Deleting budget with ID: ${event.budgetId}'); // Add this for debugging
      if (event.budgetId.isEmpty) {
        throw Exception('Budget ID is empty');
      }
      await firestoreService.deleteBudget(userId, event.budgetId);
    } catch (e) {
      emit(BudgetError('Failed to delete budget: $e'));
    }
  }

  Future<void> _onLoadBudgets(
      LoadBudgetsEvent event, Emitter<BudgetState> emit) async {
    emit(BudgetLoading());
    try {
      final userId = auth.currentUser!.uid;
      final budgetStream = firestoreService.getBudgets(userId);
      await for (final budgets in budgetStream) {
        emit(BudgetLoaded(budgets));
      }
    } catch (e) {
      emit(BudgetError('Failed to load budgets: $e'));
    }
  }
}