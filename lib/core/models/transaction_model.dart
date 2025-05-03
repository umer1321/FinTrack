import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String description;

  Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    print('Mapping transaction data: $map');
    try {
      return Transaction(
        id: map['id'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        amount: map['amount'] is num ? (map['amount'] as num).toDouble() : 0.0,
        type: map['type'] as String? ?? 'Unknown',
        category: map['category'] as String? ?? 'Unknown',
        date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
        description: map['description'] as String? ?? 'No description',
      );
    } catch (e) {
      print('Error mapping transaction: $e');
      return Transaction(
        id: map['id'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        amount: 0.0,
        type: 'Unknown',
        category: 'Unknown',
        date: DateTime.now(),
        description: 'Error loading transaction',
      );
    }
  }
}