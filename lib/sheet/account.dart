import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:simple_chat/util/fetch.dart';
import 'package:simple_chat/util/firebase.dart';
import 'package:simple_chat/widget/profile/profile_card_dialog.dart';
import 'package:simple_chat/model/user.dart' as model;
import 'package:simple_chat/widget/profile/qr_card_dialog.dart';

class MyAccountSheet extends StatelessWidget {
  const MyAccountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 30),
      children: [
        ListTile(
          leading: const Icon(Icons.person_pin_rounded),
          title: const Text('View Profile'),
          onTap: () async {
            showDialog(
                context: context,
                builder: (context) {
                  return ProfileCardDialog.fromUID(
                    uid: myUserId(),
                  );
                });
          },
        ),
        ListTile(
          leading: const Icon(Icons.qr_code_2),
          title: const Text('Show QR'),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) {
                final uid = FirebaseAuth.instance.currentUser!.uid;
                return QRCardDialog(
                  content: uid,
                  title: 'This is your QR',
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(
            Icons.person_add,
          ),
          title: const Text('Add Contact'),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) {
                final controller = TextEditingController();
                return AlertDialog(
                  icon: const Icon(Icons.person_add),
                  title: const Text('Enter User ID of Contact:'),
                  content: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 25,
                            ),
                            hintText: 'User ID',
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _addViaQr(context);
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Go back'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    ElevatedButton(
                      // style: ElevatedButton.styleFrom(
                      // backgroundColor: Theme.of(context).primaryColorLight),
                      child: const Text('Confirm'),
                      onPressed: () async {
                        if (controller.text.trim().isEmpty ||
                            !await _isValidContact(controller.text.trim())) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Invalid Contact ID entered.'),
                            ),
                          );

                          Navigator.pop(context);
                          Navigator.pop(context);
                          return;
                        }
                        _addContact(controller.text);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Contact Added.'),
                          ),
                        );

                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Log Out'),
          onTap: () {
            showDialog(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    icon: const Icon(Icons.logout),
                    title: const Text('Do you want to log out?'),
                    content: const SizedBox(height: 30),
                    actions: [
                      TextButton(
                        child: const Text('Go back'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).primaryColorLight),
                        child: const Text('Confirm'),
                        onPressed: () {
                          updateDeviceToken(
                              FirebaseAuth.instance.currentUser!.uid, '');
                          FirebaseAuth.instance.signOut();

                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                    alignment: Alignment.center,
                  );
                });

            //
          },
        ),
      ],
    );
  }

  Future<bool> _isValidContact(String uid) async {
    final collectionReference = FirebaseFirestore.instance.collection('users');

    return await collectionReference
        .where(FieldPath.documentId, isEqualTo: uid)
        .get()
        .then((value) {
      return (value.docs.isNotEmpty);
    });
  }

  void _addContact(String destUid) async {
    if (!await _isValidContact(destUid)) {
      return;
    }

    final collectionReference = FirebaseFirestore.instance.collection('users');
    final selfUid = FirebaseAuth.instance.currentUser!.uid;
    final selfRef = collectionReference.doc(selfUid);
    final destRef = collectionReference.doc(destUid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot currentUserSnapshot = await transaction.get(destRef);

      List<dynamic> currentContacts =
          (currentUserSnapshot.data() as Map<String, dynamic>?)?['contacts'] ??
              [];

      if (!currentContacts.contains(selfUid)) {
        currentContacts.add(selfUid);

        transaction.update(destRef, {
          'contacts': currentContacts,
        });
      }
    });
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final currentUserSnapshot = await transaction.get(selfRef);

      List<dynamic> currentContacts =
          (currentUserSnapshot.data())?['contacts'] ?? [];

      if (!currentContacts.contains(destUid)) {
        currentContacts.add(destUid);

        transaction.update(selfRef, {
          'contacts': currentContacts,
        });
      }
    });
  }

  void _addViaQr(BuildContext context) async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666",
      "Cancel",
      false,
      ScanMode.QR,
    );
    if (barcodeScanRes.isEmpty) return;
    if (!await _isValidContact(barcodeScanRes)) {
      print(barcodeScanRes);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid ID: $barcodeScanRes')),
      );
      return;
    }
    _addContact(barcodeScanRes);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact Added.'),
      ),
    );
    Navigator.pop(context);
  }
}
