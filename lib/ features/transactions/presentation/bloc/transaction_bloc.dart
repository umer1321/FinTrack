import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_event.dart';
import 'package:fintrack/%20features/transactions/presentation/bloc/transaction_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/NotificationService.dart';
import '../data/transaction_repository.dart';
import 'package:intl/intl.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;
  final NotificationService _notificationService;

  TransactionBloc({
    required TransactionRepository transactionRepository,
    required NotificationService notificationService,
  })  : _transactionRepository = transactionRepository,
        _notificationService = notificationService,
        super(TransactionInitial()) {
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<LoadTransactionsEvent>(_onLoadTransactions);
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    print('Adding transaction: ${event.transactionData}');
    try {
      await _transactionRepository.addTransaction(event.transactionData);
      final userId = event.transactionData['userId'] as String? ?? '';
      final amount = event.transactionData['amount'].toString();
      final description = event.transactionData['description'] as String;
      await _notificationService.sendNotification(
        userId: userId,
        title: 'New Transaction Added',
        body: 'You added a transaction of $amount ر.س for $description.',
      );
      final transactionStream = _transactionRepository.getTransactions();
      await for (final transactions in transactionStream) {
        emit(TransactionLoaded(transactions));
        break;
      }
    } catch (e) {
      print('Failed to add transaction: $e');
      emit(TransactionError('Failed to add transaction: $e'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    print('Updating transaction ID: ${event.transactionId} with data: ${event.transactionData}');
    try {
      await _transactionRepository.updateTransaction(
          event.transactionId, event.transactionData);
      final transactionStream = _transactionRepository.getTransactions();
      await for (final transactions in transactionStream) {
        emit(TransactionLoaded(transactions));
        break;
      }
    } catch (e) {
      print('Failed to update transaction: $e');
      emit(TransactionError('Failed to update transaction: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    print('Deleting transaction ID: ${event.transactionId}');
    try {
      if (event.transactionId.isEmpty) {
        throw Exception('Transaction ID cannot be empty');
      }
      await _transactionRepository.deleteTransaction(event.transactionId);
      final transactionStream = _transactionRepository.getTransactions();
      await for (final transactions in transactionStream) {
        emit(TransactionLoaded(transactions));
        break;
      }
    } catch (e) {
      print('Failed to delete transaction: $e');
      emit(TransactionError('Failed to delete transaction: $e'));
    }
  }

  Future<void> _onLoadTransactions(
      LoadTransactionsEvent event, Emitter<TransactionState> emit) async {
    emit(TransactionLoading());
    print('Starting to load transactions');
    try {
      final transactionStream = _transactionRepository.getTransactions();
      print('Transaction stream obtained');
      await for (final transactions in transactionStream) {
        print('Transactions loaded: ${transactions.length} items - $transactions');
        emit(TransactionLoaded(transactions));
      }
      print('Transaction stream completed');
    } catch (e) {
      print('Failed to load transactions: $e');
      emit(TransactionError('Failed to load transactions: $e'));
    }
  }
}