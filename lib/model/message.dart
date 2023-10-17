import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  const Message({
    required this.type,
    required this.message,
    required this.sender,
    required this.receiver,
    required this.timestamp,
  });

  final String message;
  final MessageType type;
  final String sender;
  final String receiver;
  final Timestamp timestamp;
}

enum MessageType {
  text,
  //media way..
  image,
  video,

  //sent an attachment
  fileUrl,

  // sent a link
  link,

  //to be handled separately // sent a location, call invite.
  location,
  meet,
}
