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
  text, // simple text message

  image, //message with image/video attachment
  video,

  fileUrl, //message with file attachment

  link, // message with link attachment

  location, // message with location attachment

  // meet,
}
