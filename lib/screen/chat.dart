import 'dart:io';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_chat/model/user.dart' as model;
import 'package:simple_chat/util/firebase.dart';
import 'package:simple_chat/widget/chat/message_list.dart';
import 'package:simple_chat/widget/chat/new_message_row.dart';
import 'package:simple_chat/widget/common/async_button.dart';
import 'package:simple_chat/widget/common/toast.dart';
import 'package:simple_chat/widget/profile/profile_card_dialog.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final recipientUid = widget.contact.uid;
    final conversationId = getConvId(uid, recipientUid);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.contact.name),
          leading: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return ProfileCardDialog(
                      profile: widget.contact,
                    );
                  });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                radius: 5,
                foregroundImage: NetworkImage(widget.contact.imgUrl!),
              ),
            ),
          ),
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    onTap: _shareContact,
                    child: const Row(children: [
                      Icon(Icons.share),
                      SizedBox(width: 15),
                      Text('Share')
                    ]),
                  ),
                  PopupMenuItem(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (ctx) {
                            return AlertDialog(
                              icon: Icon(
                                Icons.delete_sweep_rounded,
                                size: 40,
                              ),
                              title: Text(
                                'Are you sure?',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                              ),
                              content: Text(
                                '${widget.contact.name} will be removed from your contacts and your conversation here will be erased forever. Are you sure you want to continue?',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSecondaryContainer,
                                ),
                              ),
                              actions: [
                                OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Go Back'),
                                ),
                                AsyncButton(
                                  onTap: () {
                                    return deleteContactMutually(
                                            uid1: uid, uid2: recipientUid)
                                        .then((value) {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                      showToast(
                                          '${widget.contact.name} removed from contacts.');
                                    });
                                  },
                                  child: Text('Confirm Delete'),
                                ),
                              ],
                            );
                          });
                    },
                    child: const Row(children: [
                      Icon(Icons.delete_forever_rounded),
                      SizedBox(width: 15),
                      Text('Delete Contact')
                    ]),
                  ),
                ];
              },
            ),
          ],
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

  void _shareContact() async {
    final data = await QrPainter(
      data: widget.contact.uid,
      version: QrVersions.auto,
    ).toImageData(200);
    final filename = '${widget.contact.uid}.png';
    final tempDir =
        await getTemporaryDirectory(); // Get temporary directory to store the generated image
    File file = await File('${tempDir.path}/$filename')
        .create(); // Create a file to store the generated image
    var bytes = data!.buffer.asUint8List(); // Get the image bytes
    file = await file.writeAsBytes(bytes);
    final xfile = XFile(file.path);
    Share.shareXFiles([xfile],
        text: 'TalkSpace Contact:\n'
            'Name: ${widget.contact.name}\n'
            'Email: ${widget.contact.email}\n'
            'UID: ${widget.contact.uid}\n');
  }
}
