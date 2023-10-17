import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/model/user.dart' as model;
import 'package:simple_chat/widget/chat/message_bubble.dart';

class MessagesList extends StatefulWidget {
  const MessagesList({
    super.key,
    required this.recipient,
    required this.cId,
  });

  final model.User recipient;
  final String cId;

  @override
  State<MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<MessagesList> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  String _userImg = '';
  String _userName = '';
  @override
  void initState() {
    _setUserName();
    _setUserImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('conversation')
          .doc(widget.cId)
          .collection('messages')
          .orderBy(
            'timestamp',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('Nothing to see here!'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('An error occurred!'),
          );
        }

        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final isMe = loadedMessages[index].data()['sender'] == _uid;
            final currentMsg = loadedMessages[index].data();
            final nextMsg = (index + 1 < loadedMessages.length)
                ? loadedMessages[index + 1].data()
                : null;
            final currentMsgId = currentMsg['sender'];
            final nextMsgId = nextMsg?['sender'];
            final image = (isMe) ? _userImg : widget.recipient.imgUrl;
            final username = (isMe) ? _userName : widget.recipient.name;

            if (currentMsgId == nextMsgId) {
              return MessageBubble.next(
                message: currentMsg['message'],
                isMe: isMe,
              );
            } else {
              return MessageBubble.first(
                userImage: image,
                username: username,
                message: currentMsg['message'],
                isMe: isMe,
              );
            }
            // final message = Message(
            //   message: loadedMessages[index].data()['message'],
            //   sender: loadedMessages[index].data()['sender'],
            //   receiver: loadedMessages[index].data()['receiver'],
            //   timestamp: loadedMessages[index].data()['timestamp'],
            // );
            // return ChatBubble(message: message, uid: uid);
          },
        );
      },
    );
  }

  void _setUserImage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      setState(() {
        _userImg = model.User.fromSnapshot(snapshot).imgUrl!;
      });
    }
  }

  void _setUserName() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      setState(() {
        _userName = model.User.fromSnapshot(snapshot).name;
      });
    }
  }
}
