import 'package:flutter/material.dart';
import 'package:simple_chat/model/message.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.uid,
  });

  final Message message;
  final String uid;

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == uid;
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: (isMe)
            ? Theme.of(context).primaryColorLight
            : Theme.of(context).secondaryHeaderColor,
      ),
      child: Text(message.message),
    );
    return ListTile(
      leading: (!isMe) ? bubble : null,
      trailing: (isMe) ? bubble : null,
    );
  }
}
