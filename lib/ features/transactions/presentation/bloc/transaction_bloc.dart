import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_event.dart';
import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../data/transaction_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc({required TransactionRepository transactionRepository})
      : _transactionRepository = transactionRepository,
        super(TransactionInitial()) {
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<LoadTransactionsEvent>(_onLoadTransactions);
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.addTransaction(event.transactionData);
    } catch (e) {
      emit(TransactionError('Failed to add transaction: $e'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.updateTransaction(
          event.transactionId, event.transactionData);
    } catch (e) {
      emit(TransactionError('Failed to update transaction: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      if (event.transactionId.isEmpty) {
        throw Exception('Transaction ID cannot be empty');
      }
      await _transactionRepository.deleteTransaction(event.transactionId);
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: $e'));
    }
  }

  Future<void> _onLoadTransactions(
      LoadTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    try {
      final transactionStream = _transactionRepository.getTransactions();
      await for (final transactions in transactionStream) {
        emit(TransactionLoaded(transactions));
      }
    } catch (e) {
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }
}