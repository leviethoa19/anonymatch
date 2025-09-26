import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  String? _partnerId;
  int _compatibility = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _findRandomPartner();
  }

  Future<void> _findRandomPartner() async {
    print('Starting _findRandomPartner for user: ${user!.uid}');
    final users = await FirebaseFirestore.instance.collection('users').get();
    final otherUsers = users.docs.where((doc) => doc.id != user!.uid).toList();
    print('Found ${otherUsers.length} other users');

    if (otherUsers.isEmpty) {
      print('No other users available');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No other users available to match')),
      );
      return;
    }

    final partnerDoc = otherUsers[0];
    print('Selected partner: ${partnerDoc.id}');
    setState(() => _partnerId = partnerDoc.id);

    final myData = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    final partnerData = partnerDoc.data();
    print('My data: ${myData.data()}');
    print('Partner data: ${partnerData}');
    int score = 0;
    if ((myData['age'] - partnerData['age']).abs() < 5) {
      score += 30;
      print('Age match: +30');
    }
    if (myData['job'] == partnerData['job']) {
      score += 20;
      print('Job match: +20');
    }
    List myHobbies = myData['hobbies'];
    List partnerHobbies = partnerData['hobbies'];
    if (myHobbies.any((h) => partnerHobbies.contains(h))) {
      score += 20;
      print('Hobbies match: +20');
    }
    print('Final compatibility score: $score');
    setState(() => _compatibility = score);
  }

  Future<void> _sendMessage() async {
    if (_partnerId == null || _messageController.text.trim().isEmpty) return;

    final chatId = user!.uid.compareTo(_partnerId!) < 0
        ? '${user!.uid}_${_partnerId!}'
        : '${_partnerId!}_${user!.uid}';
    print('Sending message to chatId: $chatId');

    await FirebaseFirestore.instance.collection('chats').doc(chatId).collection('messages').add({
      'text': _messageController.text.trim(),
      'sender': user!.uid,
      'timestamp': Timestamp.now(),
    });

    _updateCompatibility(_messageController.text);
    _messageController.clear();
  }

  void _updateCompatibility(String message) {
    if (message.toLowerCase().contains('like')) {
      print('Message contains "like", increasing compatibility by 5');
      setState(() => _compatibility += 5);
    }
    if (_compatibility > 70) {
      print('Compatibility > 70, triggering match');
      _match();
    }
  }

  void _match() {
    if (_partnerId != null) {
      print('Navigating to MatchScreen with partner: $_partnerId');
      Navigator.pushNamed(context, '/match', arguments: _partnerId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _partnerId == null ? 'Chat' : 'Chat - $_compatibility%',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
        ],
      ),
      body: _partnerId == null
          ? Center(child: Text('Finding a partner...'))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chats')
                        .doc(user!.uid.compareTo(_partnerId!) < 0
                            ? '${user!.uid}_${_partnerId!}'
                            : '${_partnerId!}_${user!.uid}')
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          var msg = snapshot.data!.docs[index];
                          return ListTile(
                            title: Text(msg['text']),
                            subtitle: Text(msg['sender'] == user!.uid ? 'You' : 'Them'),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(labelText: 'Message'),
                        ),
                      ),
                      IconButton(onPressed: _sendMessage, icon: Icon(Icons.send)),
                      ElevatedButton(onPressed: _match, child: Text('Match Now')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}