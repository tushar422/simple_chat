import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/model/user.dart' as model;

class NewMessageRow extends StatefulWidget {
  const NewMessageRow({
    super.key,
    required this.recipient,
    required this.cId,
  });
  final model.User recipient;
  final String cId;

  @override
  State<NewMessageRow> createState() => _NewMessageRowState();
}

class _NewMessageRowState extends State<NewMessageRow> {
  final _messageController = TextEditingController();
  NetworkImage? _selfImage;

  @override
  Widget build(BuildContext context) {
    _setUserImage();

    return Container(
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          CircleAvatar(
            foregroundImage: _selfImage,
          ),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'New Message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              // contentPadding:
              suffixIcon: IconButton(
                onPressed: _sendFile,
                icon: Icon(
                  Icons.attach_file_rounded,
                  size: 20,
                ),
              ),
            ),
          )),
          const SizedBox(width: 5),
          IconButton.filled(
            onPressed: _sumbitMessage,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  void _setUserImage() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snapshot =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (snapshot.exists) {
      setState(() {
        _selfImage = NetworkImage(model.User.fromSnapshot(snapshot).imgUrl!);
      });
    }
  }

  void _sumbitMessage() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser!;
    // final userData = await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(user.uid)
    //     .get();

    FirebaseFirestore.instance
        .collection('conversation')
        .doc(widget.cId)
        .collection('messages')
        .add({
      'timestamp': Timestamp.now(),
      'sender': user.uid,
      'receiver': widget.recipient.uid,
      'message': enteredMessage,

    });

    _messageController.clear();
  }

  void _sendFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.media,
    );
    if (result != null && result.paths[0]!=null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('attachments')
          .child('${widget.cId}.jpg');
      final file = File(result.paths[0]!);
      await storageRef.putFile(file);
      final url = await storageRef.getDownloadURL();
      print(result.paths);
      

    }
    // if (result != null) {
    //   final storageRef = FirebaseStorage.instance
    //       .ref()
    //       .child('attachments')
    //       .child('${credentials.user!.uid}.jpg');
    //   await storageRef.putFile(_selectedImage!);
    //   url = await storageRef.getDownloadURL();
    // }
  }
}
