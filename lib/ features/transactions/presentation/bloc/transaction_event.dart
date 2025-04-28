import 'package:equatable/equatable.dart';
import 'package:fintrack/core/models/transaction_model.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
  @override
  List<Object?> get props => [];
}

class LoadTransactionsEvent extends TransactionEvent {
  const LoadTransactionsEvent();
}

class AddTransactionEvent extends TransactionEvent {
  final Map<String, dynamic> transactionData;
  const AddTransactionEvent(this.transactionData);
  @override
  List<Object?> get props => [transactionData];
}

class UpdateTransactionEvent extends TransactionEvent {
  final String transactionId;
  final Map<String, dynamic> transactionData;
  const UpdateTransactionEvent(this.transactionId, this.transactionData);
  @override
  List<Object?> get props => [transactionId, transactionData];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  const DeleteTransactionEvent(this.transactionId);
  @override
  List<Object?> get props => [transactionId];
}