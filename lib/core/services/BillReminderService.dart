import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';

import 'NotificationService.dart';

class BillReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService;

  BillReminderService({required NotificationService notificationService})
      : _notificationService = notificationService;

  void startBillReminders(String userId) {
    print('Starting bill reminders for user: $userId');
    _firestore
        .collection('users')
        .doc(userId)
        .collection('bills')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final dueDate = (data['dueDate'] as Timestamp).toDate();
        final description = data['description'] as String;
        final amount = (data['amount'] as num).toDouble();
        final now = DateTime.now();
        final difference = dueDate.difference(now);
        if (difference.inDays <= 1 && difference.inDays >= 0) {
          _notificationService.sendNotification(
            userId: userId,
            title: 'Bill Reminder',
            body: 'Your bill "$description" of $amount ر.س is due on ${DateFormat('yyyy-MM-dd').format(dueDate)}.',
          );
        }
      }
    });
  }
}