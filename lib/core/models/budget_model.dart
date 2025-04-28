import 'package:equatable/equatable.dart';

class Budget extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String month;

  const Budget({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.month,
  });

  @override
  List<Object?> get props => [id, userId, category, amount, month];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'amount': amount,
      'month': month,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      category: map['category'] ?? '',
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] ?? '',
    );
  }
}