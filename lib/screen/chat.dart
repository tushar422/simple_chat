import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/model/user.dart' as model;
import 'package:simple_chat/widget/chat/message_list.dart';
import 'package:simple_chat/widget/chat/new_message_row.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.contact,
  });

  final model.User contact;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void _setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;
    final notficationSettings = await fcm.requestPermission();
    final token = await fcm.getToken();
    print(token);
  }

  @override
  void initState() {
    super.initState();
    _setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final recipientUid = widget.contact.uid;
    final conversationId = (uid.compareTo(recipientUid).isNegative)
        ? '$uid-$recipientUid'
        : '$recipientUid-$uid';

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.contact.name),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              foregroundImage: NetworkImage(widget.contact.imgUrl!),
            ),
          ),
        ),
        body: MessagesList(
          recipient: widget.contact,
          cId: conversationId,
        ),
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: BottomAppBar(
            child: NewMessageRow(
              recipient: widget.contact,
              cId: conversationId,
            ),
          ),
        ));
  }
}
