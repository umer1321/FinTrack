import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService() {
    _initializeFirebaseMessaging();
  }

  void _initializeFirebaseMessaging() async {
    await _firebaseMessaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received foreground message: ${message.notification?.title}');
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.notification?.title}');
  }

  Future<Map<String, dynamic>> getUserNotificationPreferences(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).collection('settings').doc('notifications').get();
    if (!doc.exists) {
      return {'pushEnabled': true, 'emailEnabled': false, 'emailAddress': ''};
    }
    return doc.data() as Map<String, dynamic>;
  }

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
  }) async {
    final prefs = await getUserNotificationPreferences(userId);
    final pushEnabled = prefs['pushEnabled'] as bool? ?? true;
    final emailEnabled = prefs['emailEnabled'] as bool? ?? false;
    final emailAddress = prefs['emailAddress'] as String? ?? '';

    if (pushEnabled) {
      await _sendPushNotification(userId, title, body);
    }
    if (emailEnabled && emailAddress.isNotEmpty) {
      await _sendEmailNotification(emailAddress, title, body);
    }
  }

  Future<void> _sendPushNotification(String userId, String title, String body) async {
    try {
      final token = await _firebaseMessaging.getToken();
      if (token == null) {
        print('Failed to get FCM token');
        return;
      }
      print('Sending push notification to user $userId: $title - $body');
      // Typically, you'd send the notification via a server using FCM HTTP v1 API.
      // For simplicity, assume the device token is used directly (in production, use a server).
    } catch (e) {
      print('Error sending push notification: $e');
    }
  }

  Future<void> _sendEmailNotification(String emailAddress, String title, String body) async {
    final smtpServer = gmail('your-email@gmail.com', 'your-app-password');
    final message = Message()
      ..from = const Address('your-email@gmail.com', 'FinTrack')
      ..recipients.add(emailAddress)
      ..subject = title
      ..text = body;

    try {
      await send(message, smtpServer);
      print('Email sent to $emailAddress: $title');
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}