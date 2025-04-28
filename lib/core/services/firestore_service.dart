import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:fintrack/core/models/transaction_model.dart';
import 'package:fintrack/core/models/budget_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addTransaction(String userId, Transaction transaction) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id.isEmpty ? null : transaction.id);

    final transactionMap = transaction.toMap();
    if (transaction.id.isEmpty) {
      transactionMap['id'] = docRef.id;
    }

    await docRef.set(transactionMap);
  }

  Future<void> updateTransaction(String userId, Transaction transaction) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  Stream<List<Transaction>> getTransactions(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Ensure the ID is set in the data map
      return Transaction.fromMap(data);
    }).toList());
  }

  /*Future<void> addBudget(String userId, Budget budget) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budget.id.isEmpty ? null : budget.id)
        .set(budget.toMap());
  }*/
  Future<void> addBudget(String userId, Budget budget) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budget.id.isEmpty ? null : budget.id);

    final budgetMap = budget.toMap();
    if (budget.id.isEmpty) {
      budgetMap['id'] = docRef.id; // Set the generated ID in the document
    }

    await docRef.set(budgetMap);
  }

  Future<void> updateBudget(String userId, Budget budget) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budget.id)
        .update(budget.toMap());
  }

 /* Future<void> deleteBudget(String userId, String budgetId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budgetId)
        .delete();
  }*/
  Future<void> deleteBudget(String userId, String budgetId) async {
    if (budgetId.isEmpty) {
      throw Exception('Budget ID cannot be empty');
    }
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .doc(budgetId)
        .delete();
  }
  Stream<List<Budget>> getBudgets(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('budgets')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // Add the document ID to the data map
      return Budget.fromMap(data);
    }).toList());
  }

  Future<double> getTotalExpensesForCategory(
      String userId, String category, String month) async {
    final startDate = DateTime.parse('$month-01');
    final endDate = DateTime(startDate.year, startDate.month + 1, 1);

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .where('type', isEqualTo: 'expense')
        .where('category', isEqualTo: category)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThan: Timestamp.fromDate(endDate))
        .get();

    return snapshot.docs.fold<double>(
      0.0,
          (double sum, doc) => sum + (doc.data()['amount'] as num).toDouble(),
    );
  }
}