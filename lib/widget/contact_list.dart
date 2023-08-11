import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_chat/model/user.dart' as model;
import 'package:flutter/material.dart';
import 'package:simple_chat/screen/chat.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred!'),
            );
          }
          final fetchedContacts =
              List<String>.from(snapshot.data!.data()!['contacts'] ?? []);
          if (fetchedContacts.isEmpty) {
            return const Center(
              child: Text('You have no contacts!'),
            );
          }

          return FutureBuilder(
            future: _getContacts(fetchedContacts),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('An error occurred! : ${snapshot.error}'),
                );
              }
              List<model.User> contacts = snapshot.data ?? [];
              return ListView.builder(
                itemBuilder: (ctx, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      foregroundImage: NetworkImage(contacts[index].imgUrl!),
                    ),
                    title: Text(contacts[index].name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) {
                            return ChatScreen(contact: contacts[index]);
                          },
                        ),
                      );
                    },
                  );
                },
                itemCount: contacts.length,
              );
            },
          );
        });
  }

  Future<List<model.User>> _getContacts(List<String> uids) async {
    List<model.User> contacts = [];
    for (String uid in uids) {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final user = model.User.fromSnapshot(snapshot);
      contacts.add(user);
    }
    return contacts;
  }
}
