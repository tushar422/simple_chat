import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/model/attachment.dart';
import 'package:simple_chat/model/message.dart';
import 'package:simple_chat/model/user.dart' as model;
import 'package:simple_chat/util/file.dart';
import 'package:simple_chat/util/location.dart';
import 'package:simple_chat/widget/common/async_button.dart';
import 'package:simple_chat/widget/common/option_button_tile.dart';

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
  bool _sending = false;

  Attachment? _attachment;
  final GlobalKey<FormFieldState> _fieldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    _setUserImage();

    return Container(
      padding: const EdgeInsets.all(0),
      child: Row(
        children: [
          // CircleAvatar(
          //   foregroundImage: _selfImage,
          // ),

          const SizedBox(width: 10),
          Expanded(
              child: TextField(
            enabled: !_sending,
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            decoration: InputDecoration(
                hintText: 'New Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: EdgeInsets.all(20),
                suffixIcon: Container(
                  padding: EdgeInsets.all(5),
                  child: (_attachment == null)
                      ? IconButton(
                          onPressed: _attachMediaFile,
                          icon: Icon(Icons.photo_library_rounded))
                      : IconButton.filledTonal(
                          color: Colors.red,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.green.withOpacity(0.2),
                            foregroundColor: Colors.green,
                          ),
                          icon: Icon(
                            Icons.photo_library_rounded,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _attachment = null;
                            });
                          },
                        ),
                )
                // contentPadding:
                ),
          )),

          SizedBox(width: (_attachment == null) ? 5 : 10),

          if (_attachment == null)
            IconButton.filledTonal(
                onPressed: _showAttachmentModal, icon: const Icon(Icons.add)),
          // const SizedBox(width: 5),
          IconButton.filled(
            onPressed: (!_sending) ? _sumbitMessage : null,
            icon: (!_sending)
                ? const Icon(Icons.send)
                : const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
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

  Future<void> _sumbitMessage() async {
    final enteredMessage = _messageController.text.trim();
    if (enteredMessage.isEmpty) return;
    setState(() {
      _sending = true;
    });

    final user = FirebaseAuth.instance.currentUser!;

    if (_attachment == null) {
      _messageController.clear();
      await FirebaseFirestore.instance
          .collection('conversation')
          .doc(widget.cId)
          .collection('messages')
          .add({
        'timestamp': Timestamp.now(),
        'sender': user.uid,
        'receiver': widget.recipient.uid,
        'message': enteredMessage,
        'type': MessageType.text.name,
        'attachment': null,
      });
      setState(() {
        _sending = false;
      });
      return;
    }
    final type = _attachment!.type;
    final attachmentUrl = await _uploadAttachment();

    await FirebaseFirestore.instance
        .collection('conversation')
        .doc(widget.cId)
        .collection('messages')
        .add(
      {
        'timestamp': Timestamp.now(),
        'sender': user.uid,
        'receiver': widget.recipient.uid,
        'message': enteredMessage,
        'type': type.name,
        'attachment': attachmentUrl,
      },
    );
    _messageController.clear();
    setState(() {
      _attachment = null;
      _sending = false;
    });
    return;
  }

  Future<String?> _uploadAttachment() async {
    if (_attachment!.type == MessageType.link ||
        _attachment!.type == MessageType.location) return _attachment!.url;

    // _attachment!.type == MessageType.meet ????

    final fileName = path.basename(_attachment!.file!.path);

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('attachments')
        .child('${widget.cId}_$fileName');

    await storageRef.putFile(_attachment!.file!);
    return await storageRef.getDownloadURL();
  }

  void _showAttachmentModal() {
    showModalBottomSheet(
        context: context,
        useSafeArea: true,
        showDragHandle: true,
        builder: (ctx) {
          return ListView(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 30),
            shrinkWrap: true,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Text(
                  'Message Options',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ),
              Divider(
                height: 0,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text('Camera Media'),
                subtitle: Text('Take and attach media from your camera.'),
                leading: Icon(Icons.camera_alt_rounded),
                shape: const StadiumBorder(),
                onTap: () {
                  _showCameraMediaOptions();
                },
              ),
              ListTile(
                title: Text('File Attachment'),
                subtitle: Text('Attach any file to the message.'),
                leading: Icon(Icons.file_present_rounded),
                shape: const StadiumBorder(),
                onTap: () {
                  _attachNonMediaFile();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text('Location'),
                subtitle: Text('Send your current location to the person.'),
                leading: Icon(Icons.pin_drop_rounded),
                shape: const StadiumBorder(),
                onTap: () {
                  Navigator.pop(context);
                  _attachLocation();
                },
              ),
              ListTile(
                title: Text('Link'),
                subtitle: Text('Send a link to the person.'),
                leading: Icon(Icons.pin_drop_rounded),
                shape: const StadiumBorder(),
                onTap: () {
                  Navigator.pop(context);
                  _attachLink();
                },
              ),
            ],
          );
        });
  }

  void _showCameraMediaOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _attachCameraImage,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(10)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.image_rounded,
                          size: 45,
                        ),
                        Text(
                          'Image',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _attachCameraVideo,
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(10)),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      // color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.video_collection_rounded,
                          size: 45,
                        ),
                        Text(
                          'Video',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  //functions to attach files

  //for video/photo
  void _attachMediaFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.media,
    );
    if (result != null && result.paths[0] != null) {
      final fileName = path.basename(result.paths[0]!);
      final type = getMessageType(fileName);
      setState(() {
        _attachment = Attachment(type: type, file: File(result.paths[0]!));
      });

      print(result.paths);
    }
  }

  void _attachNonMediaFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (result != null && result.paths[0] != null) {
      setState(() {
        _attachment =
            Attachment(type: MessageType.fileUrl, file: File(result.paths[0]!));
      });

      print(result.paths);
    }
  }

  void _attachCameraMediaFile() async {
    final imagePicker = ImagePicker();
    await imagePicker.pickVideo(source: ImageSource.camera);
    // final result = await FilePicker.platform.pickFiles(
    //   allowMultiple: false,
    //   type: FileType.media,
    // );
    // if (result != null && result.paths[0] != null) {
    //   final fileName = path.basename(result.paths[0]!);
    //   final type = getMessageType(fileName);
    //   setState(() {
    //     _attachment = Attachment(type: type, file: File(result.paths[0]!));
    //   });

    //   print(result.paths);
    // }
  }

  void _attachCameraImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.camera);
    if (result == null) return;
    final file = File(result.path);
    final type = MessageType.image;
    setState(() {
      _attachment = Attachment(type: type, file: file);
    });
    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _attachCameraVideo() async {
    final picker = ImagePicker();
    final result = await picker.pickVideo(source: ImageSource.camera);
    if (result == null) return;

    final file = File(result.path);
    final type = MessageType.video;
    setState(() {
      _attachment = Attachment(type: type, file: file);
    });

    Navigator.pop(context);
    Navigator.pop(context);
  }

  void _attachLocation() async {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          icon: Icon(
            Icons.pin_drop_rounded,
            size: 50,
          ),
          title: Text(
            'Attach Location',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          content: Text(
            'Do you want to send your current location. Grant the location permissions if asked.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          actions: [
            OutlinedButton(
              child: Text('Back'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            AsyncButton(
                child: Text('Yes, Confirm'),
                onTap: () {
                  return getCurrentLocation().then((value) {
                    final mapUrl =
                        'https://www.google.com/maps/search/?api=1&query=${value.latitude}%2C${value.longitude}';
                    final attachment =
                        Attachment(type: MessageType.location, url: mapUrl);
                    setState(() {
                      _attachment = attachment;
                    });
                    Navigator.pop(context);
                  });
                }),
          ],
        );
      },
    );
  }

  void _attachLink() async {
    showDialog(
      context: context,
      builder: (ctx) {
        final _controller = TextEditingController();
        return AlertDialog(
          icon: Icon(
            Icons.ads_click,
            size: 50,
          ),
          title: Text(
            'Attach Link',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the URL you want to attach to the message. Make sure it\'s a valid URL.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  hintText: 'Enter URL',
                  contentPadding: EdgeInsets.all(20),
                ),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              child: Text('Back'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
                child: const Text('Add'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  final attachment = Attachment(
                      type: MessageType.link, url: _controller.text.trim());
                  setState(() {
                    _attachment = attachment;
                  });
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }
}
