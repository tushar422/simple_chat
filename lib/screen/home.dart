import 'package:flutter/material.dart';
import 'package:simple_chat/sheet/account.dart';
import 'package:simple_chat/widget/contact_list.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return MyAccountSheet();
                    });
              },
              icon: CircleAvatar(
                child: Text('T'),
              ))
        ],
      ),
      body: ContactsList(),
    );
  }
}
