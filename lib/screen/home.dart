import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/sheet/account.dart';
import 'package:simple_chat/widget/contact_list.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  // final user = FirebaseAuth.instance.currentUser!;
  late final String displayName;
  @override
  void initState() {
    final acc = FirebaseAuth.instance.currentUser!;
    if (acc.displayName?.isNotEmpty ?? false)
      displayName = acc.displayName!;
    else
      displayName = acc.email!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(FirebaseAuth.instance.currentUser!.displayName);
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
                child: Text(displayName[0]),
              ))
        ],
      ),
      body: ContactsList(),
    );
  }
}
