import 'package:fintrack/core/models/transaction_model.dart';
import 'package:fintrack/core/services/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionRepository {
  final FirestoreService _firestoreService;
  final FirebaseAuth _auth;

  TransactionRepository(this._firestoreService, this._auth);

  Future<void> addTransaction(Map<String, dynamic> transactionData) async {
    final userId = _auth.currentUser!.uid;
    final transaction = Transaction(
      id: '',
      userId: userId,
      amount: double.parse(transactionData['amount']),
      type: transactionData['type'],
      category: transactionData['category'],
      date: transactionData['date'],
      description: transactionData['description'],
    );
    await _firestoreService.addTransaction(userId, transaction);
  }

  Future<void> updateTransaction(String transactionId, Map<String, dynamic> transactionData) async {
    final userId = _auth.currentUser!.uid;
    final transaction = Transaction(
      id: transactionId,
      userId: userId,
      amount: double.parse(transactionData['amount']),
      type: transactionData['type'],
      category: transactionData['category'],
      date: transactionData['date'],
      description: transactionData['description'],
    );
    await _firestoreService.updateTransaction(userId, transaction);
  }

  Future<void> deleteTransaction(String transactionId) async {
    final userId = _auth.currentUser!.uid;
    await _firestoreService.deleteTransaction(userId, transactionId);
  }

  Stream<List<Transaction>> getTransactions() {
    final userId = _auth.currentUser!.uid;
    return _firestoreService.getTransactions(userId);
  }

  Future<double> getTotalAmount(String type) async {
    final userId = _auth.currentUser!.uid;
    final transactions = await _firestoreService.getTransactions(userId).first;
    return transactions
        .where((transaction) => transaction.type == type)
        .fold<double>(0.0, (double sum, Transaction transaction) => sum + transaction.amount);
  }
}