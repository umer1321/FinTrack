import 'package:equatable/equatable.dart';
import 'package:fintrack/core/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object> get props => [];
}

class AddTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  const AddTransactionEvent(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;
  const UpdateTransactionEvent(this.transaction);
  @override
  List<Object> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  const DeleteTransactionEvent(this.transactionId);
  @override
  List<Object> get props => [transactionId];
}

class LoadTransactionsEvent extends TransactionEvent {
  const LoadTransactionsEvent();
}