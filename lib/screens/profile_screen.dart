import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _ageController = TextEditingController();
  final _jobController = TextEditingController();
  final _hobbiesController = TextEditingController();

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'age': int.parse(_ageController.text),
      'job': _jobController.text,
      'hobbies': _hobbiesController.text.split(','),
    });

    Navigator.pushNamed(context, '/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Setup Profile')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _jobController,
              decoration: InputDecoration(labelText: 'Job'),
            ),
            TextField(
              controller: _hobbiesController,
              decoration: InputDecoration(labelText: 'Hobbies (comma separated)'),
            ),
            ElevatedButton(onPressed: _saveProfile, child: Text('Save and Start Chatting')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _jobController.dispose();
    _hobbiesController.dispose();
    super.dispose();
  }
}