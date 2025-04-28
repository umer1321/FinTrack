class Transaction {
  final String id;
  final String userId;
  final double amount;
  final String type; // 'income' or 'expense'
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
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map, String id) {
    return Transaction(
      id: id,
      userId: map['userId'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }
}