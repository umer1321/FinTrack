import 'package:fintrack/core/services/firestore_service.dart';
import 'package:fintrack/core/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionRepository {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTransaction(Transaction transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    await _firestoreService.addTransaction(userId, transaction.toMap());
  }

  Future<void> updateTransaction(Transaction transaction) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    await _firestoreService.updateTransaction(
        userId, transaction.id, transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    await _firestoreService.deleteTransaction(userId, transactionId);
  }

  Stream<List<Transaction>> getTransactions() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');
    return _firestoreService.getTransactions(userId).map(
          (data) => data
          .map((map) => Transaction.fromMap(map, map['id']))
          .toList(),
    );
  }
}