// database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

class DatabaseService {
  // Firestore reference
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Realtime Database reference
  final DatabaseReference _realtimeDb = FirebaseDatabase.instance.ref();

  // Save user data to Firestore
  Future<void> saveUserData(String uid, Map<String, dynamic> userData) async {
    await _firestore.collection('users').doc(uid).set(userData);

    // Also save to Realtime Database
    await _realtimeDb.child('users').child(uid).set(userData);
  }

  // Get user data from Firestore
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // Get user data from Realtime Database
  Future<DataSnapshot> getUserDataRealtime(String uid) async {
    return await _realtimeDb.child('users').child(uid).get();
  }

  // Add a post to Firestore
  Future<DocumentReference> addPost(Map<String, dynamic> postData) async {
    return await _firestore.collection('posts').add(postData);
  }

  // Get posts from Firestore
  Stream<QuerySnapshot> getPosts() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Add message to Realtime Database
  Future<void> addMessage(
    String chatId,
    Map<String, dynamic> messageData,
  ) async {
    await _realtimeDb.child('chats').child(chatId).push().set(messageData);
  }

  // Get messages from Realtime Database
  Stream<DatabaseEvent> getMessages(String chatId) {
    return _realtimeDb
        .child('chats')
        .child(chatId)
        .orderByChild('timestamp')
        .onValue;
  }
}
