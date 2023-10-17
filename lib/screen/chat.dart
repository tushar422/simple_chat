import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
                    onTap: (){

                    },
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
                              title: Text('Are you sure?'),
                              content: Text(
                                  '${widget.contact.name} will be removed from your contacts and your conversation here will be erased forever. Are you sure you want to continue?'),
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
                    child:const  Row(children: [
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
}
