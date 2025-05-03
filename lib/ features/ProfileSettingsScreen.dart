import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'auth/presentation/widgets/auth_button.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _newClassController = TextEditingController();
  List<String> _financialClasses = [];

  @override
  void initState() {
    super.initState();
    _loadFinancialClasses();
  }

  Future<void> _loadFinancialClasses() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    final doc = await _firestore.collection('users').doc(userId).collection('settings').doc('financial_classes').get();
    if (doc.exists) {
      setState(() {
        _financialClasses = List<String>.from(doc.data()?['classes'] ?? []);
      });
    }
  }

  Future<void> _saveFinancialClasses() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    await _firestore.collection('users').doc(userId).collection('settings').doc('financial_classes').set({
      'classes': _financialClasses,
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Financial classes saved')));
  }

  void _addClass(String className) {
    if (className.isNotEmpty && !_financialClasses.contains(className)) {
      setState(() {
        _financialClasses.add(className);
      });
      _newClassController.clear();
    }
  }

  void _removeClass(String className) {
    setState(() {
      _financialClasses.remove(className);
    });
  }

  @override
  void dispose() {
    _newClassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: const Color(0xFF1A3C34),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manage Financial Classes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newClassController,
                    decoration: const InputDecoration(labelText: 'Add New Class'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _addClass(_newClassController.text),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                  child: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _financialClasses.length,
                itemBuilder: (context, index) {
                  final className = _financialClasses[index];
                  return ListTile(
                    title: Text(className),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeClass(className),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            AuthButton(
              text: 'Save Changes',
              onPressed: _saveFinancialClasses,
            ),
          ],
        ),
      ),
    );
  }
}