import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<String?> getPushNotificationsToken() async {
  final fcm = FirebaseMessaging.instance;
  final notficationSettings = await fcm.requestPermission();
  return fcm.getToken();
}

void updateDeviceToken(String uid, String token) async {
  final collectionReference = FirebaseFirestore.instance.collection('users');
  await collectionReference.doc(uid).update({'deviceToken': token});
}

Future<void> deleteContactMutually({
  required String uid1,
  required String uid2,
}) async {
  final usersReference = FirebaseFirestore.instance.collection('users');
  final conversationReference =
      FirebaseFirestore.instance.collection('conversation');

  final selfRef = usersReference.doc(uid1);
  final destRef = usersReference.doc(uid2);
  final convRef = conversationReference.doc(getConvId(uid1, uid2));

  return await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot currentUserSnapshot = await transaction.get(selfRef);
    final destSnapshot = await transaction.get(destRef);

    List<dynamic> currentContacts =
        (currentUserSnapshot.data() as Map<String, dynamic>?)?['contacts'];
    currentContacts.remove(uid2);
    transaction.update(selfRef, {
      'contacts': currentContacts,
    });

    List<dynamic> destContacts = (destSnapshot.data())?['contacts'];
    destContacts.remove(uid1);
    transaction.update(destRef, {
      'contacts': destContacts,
    });
    await convRef.delete();
    final messageCollectionRef = convRef.collection('messages');

    // Get all of the documents in the message collection.
    final documents = await messageCollectionRef.get();

    // Delete each of the documents in the message collection.
    for (final document in documents.docs) {
      await document.reference.delete();
    }
  });
}

String getConvId(String u1, String u2) {
  return (u1.compareTo(u2).isNegative) ? '$u1-$u2' : '$u2-$u1';
}
