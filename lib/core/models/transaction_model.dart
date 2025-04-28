import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String userId;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String description;

  const Transaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.description,
  });

  @override
  List<Object?> get props => [id, userId, amount, type, category, date, description];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    DateTime transactionDate;
    final dateValue = map['date'];

    if (dateValue is Timestamp) {
      transactionDate = dateValue.toDate();
    } else if (dateValue is String) {
      transactionDate = DateTime.parse(dateValue);
    } else {
      throw Exception('Invalid date format in Firestore data: $dateValue');
    }

    return Transaction(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] ?? '',
      category: map['category'] ?? '',
      date: transactionDate,
      description: map['description'] ?? '',
    );
  }
}