// home_screen.dart
import 'package:firebase_tutorial/service/auth_service.dart';
import 'package:firebase_tutorial/service/database_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _auth = AuthService();
  final DatabaseService _db = DatabaseService();
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = _auth.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () async {
              await _auth.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.article), text: 'Firestore'),
            Tab(icon: Icon(Icons.chat), text: 'Realtime DB'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Firestore Tab (Posts)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _postController,
                        decoration: InputDecoration(
                          hintText: 'Write a post...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        if (_postController.text.isNotEmpty &&
                            currentUser != null) {
                          await _db.addPost({
                            'content': _postController.text,
                            'authorId': currentUser.uid,
                            'authorEmail': currentUser.email,
                            'timestamp': DateTime.now().toString(),
                          });
                          _postController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _db.getPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text('No posts yet!'));
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var post = snapshot.data!.docs[index];
                        var data = post.data() as Map<String, dynamic>;

                        return Card(
                          margin: EdgeInsets.symmetric(
                            vertical: 5,
                            horizontal: 10,
                          ),
                          child: ListTile(
                            title: Text(data['content']),
                            subtitle: Text('By: ${data['authorEmail']}'),
                            trailing: Text(
                              data['timestamp'].toString().split(' ')[0],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Realtime Database Tab (Chat)
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        if (_messageController.text.isNotEmpty &&
                            currentUser != null) {
                          await _db.addMessage('global', {
                            'text': _messageController.text,
                            'senderId': currentUser.uid,
                            'senderEmail': currentUser.email,
                            'timestamp': DateTime.now().millisecondsSinceEpoch,
                          });
                          _messageController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: _db.getMessages('global'),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData ||
                        snapshot.data!.snapshot.value == null) {
                      return Center(child: Text('No messages yet!'));
                    }

                    // Process the data
                    Map<dynamic, dynamic> messagesMap =
                        (snapshot.data!.snapshot.value
                            as Map<dynamic, dynamic>);

                    List<Map<String, dynamic>> messages = [];

                    messagesMap.forEach((key, value) {
                      messages.add({
                        'key': key,
                        ...Map<String, dynamic>.from(value as Map),
                      });
                    });

                    // Sort by timestamp
                    messages.sort(
                      (a, b) => b['timestamp'].compareTo(a['timestamp']),
                    );

                    return ListView.builder(
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        var message = messages[index];
                        bool isMe =
                            currentUser != null &&
                            message['senderId'] == currentUser.uid;

                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              vertical: 5,
                              horizontal: 10,
                            ),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[200],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message['text'],
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  message['senderEmail'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
