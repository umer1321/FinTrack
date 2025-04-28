import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_event.dart';
import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../data/transaction_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository = TransactionRepository();

  TransactionBloc() : super(TransactionInitial()) {
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<LoadTransactionsEvent>(_onLoadTransactions);
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.addTransaction(event.transaction);
      emit(TransactionLoaded(
          await _transactionRepository.getTransactions().first));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.updateTransaction(event.transaction);
      emit(TransactionLoaded(
          await _transactionRepository.getTransactions().first));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.deleteTransaction(event.transactionId);
      emit(TransactionLoaded(
          await _transactionRepository.getTransactions().first));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  Future<void> _onLoadTransactions(
      LoadTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactions = await _transactionRepository.getTransactions().first;
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}