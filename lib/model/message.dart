import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.message,
    required this.sender,
    required this.receiver,
    required this.timestamp,
  });

  final String message;
  final String sender;
  final String receiver;
  final Timestamp timestamp;
}
