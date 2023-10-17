import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:simple_chat/model/user.dart';

String? myUserId() {
  return fa.FirebaseAuth.instance.currentUser?.uid;
}

Future<User> fetchUserData(String uid) async {
  final snapshot =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return User.fromSnapshot(snapshot);
}

Future<List<String>> getContactsOf(String uid) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final map = doc.data();
  final contacts = List<String>.from(map!['contacts'] ?? []);
  return contacts;
}
