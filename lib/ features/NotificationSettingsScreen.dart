import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final doc = await _firestore.collection('users').doc(userId).collection('settings').doc('notifications').get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        _pushEnabled = data['pushEnabled'] as bool? ?? true;
        _emailEnabled = data['emailEnabled'] as bool? ?? false;
        _emailController.text = data['emailAddress'] as String? ?? '';
      });
    }
  }

  Future<void> _savePreferences() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).collection('settings').doc('notifications').set({
      'pushEnabled': _pushEnabled,
      'emailEnabled': _emailEnabled,
      'emailAddress': _emailController.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved')));
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        backgroundColor: const Color(0xFF1A3C34),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              value: _pushEnabled,
              onChanged: (value) => setState(() => _pushEnabled = value),
              activeColor: const Color(0xFF4CAF50),
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              value: _emailEnabled,
              onChanged: (value) => setState(() => _emailEnabled = value),
              activeColor: const Color(0xFF4CAF50),
            ),
            if (_emailEnabled)
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Address'),
                keyboardType: TextInputType.emailAddress,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}