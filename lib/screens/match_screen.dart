import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MatchScreen extends StatelessWidget {
  final String? partnerId;

  const MatchScreen({Key? key, this.partnerId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('MatchScreen: partnerId = $partnerId'); // Debug partnerId
    if (partnerId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Matched!')),
        body: Center(child: Text('Error: No partner ID provided')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Matched!')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(partnerId).get(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Firestore error: ${snapshot.error}'); // Debug lỗi
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            print('No data for partnerId: $partnerId'); // Debug dữ liệu
            return Center(child: Text('No data found for partner'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            print('Data is null for partnerId: $partnerId'); // Debug null
            return Center(child: Text('No profile data available'));
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Age: ${data['age'] ?? 'Unknown'}', style: TextStyle(fontSize: 20)),
                Text('Job: ${data['job'] ?? 'Unknown'}', style: TextStyle(fontSize: 20)),
                Text(
                  'Hobbies: ${(data['hobbies'] as List<dynamic>?)?.join(', ') ?? 'None'}',
                  style: TextStyle(fontSize: 20),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context), // Chỉ pop về ChatScreen
                  child: Text('Back to Chat'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}