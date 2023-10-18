import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_chat/model/user.dart';
import 'package:simple_chat/util/fetch.dart';
import 'package:simple_chat/widget/common/async_button.dart';
import 'package:simple_chat/widget/common/toast.dart';
import 'package:simple_chat/widget/profile/profile_shimmer.dart';

class EditProfileDialog extends StatefulWidget {
  const EditProfileDialog({
    super.key,
    required this.profile,
  });

  final User profile;

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final String _imgUrl;
  bool _imageModified = false;
  File? _selectedImage;

  bool _loading = false;
  @override
  void initState() {
    _nameController = TextEditingController(text: widget.profile.name);
    _imgUrl = widget.profile.imgUrl ?? dummyProfileImageUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 10,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ),
      content: (_loading)
          ? const ProfileCardShimmer()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(children: [
                  Container(
                    height: 200,
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: (_selectedImage == null)
                        ? Image.network(
                            _imgUrl,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                            // height: 100,
                          )
                        : Image.file(
                            _selectedImage!,
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                          ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: IconButton.filledTonal(
                      onPressed: _showImageEditOptions,
                      icon: const Icon(Icons.edit_note_rounded),
                    ),
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 40, 0, 5),
                  child: TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      label: Text('Name'),
                    ),

                    // userProfile.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                ),
                ListTile(
                  leading: Text('Email'),
                  title: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.2),
                    ),
                    child: Text(widget.profile.email),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                ),
                ListTile(
                  leading: Text('UID'),
                  title: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.2),
                      ),
                      child: Text(widget.profile.uid)),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 5, vertical: 0),
                ),
              ],
            ),
      actions: [
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Discard'),
        ),
        AsyncButton(
          onTap: () {
            return _saveChanges().then((value) {
              Navigator.pop(context);
              showToast('Profile Updated');
            });
          },
          child: Text('Save Changes'),
        ),
      ],
    );
  }

  void _showImageEditOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _setCameraImage();
                        },
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
                                Icons.photo_camera_back_rounded,
                                size: 45,
                              ),
                              Text(
                                'Take Photo',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _setLocalImage();
                        },
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
                                Icons.photo_library_rounded,
                                size: 45,
                              ),
                              Text(
                                'Select from Gallery',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  void _setCameraImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.camera);
    if (result == null) return;
    _imageModified = true;
    final file = File(result.path);

    setState(() {
      _selectedImage = file;
    });
    // Navigator.pop(context);
  }

  void _setLocalImage() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);

    if (result == null) return;
    final file = File(result.path);
    print(file.path);
    _imageModified = true;

    setState(() {
      _selectedImage = file;
    });
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('user_avatar')
          .child('${widget.profile.uid}.jpg');
      await storageRef.putFile(_selectedImage!);
      final url = await storageRef.getDownloadURL();
      return url;
    }
    return null;
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    final nameChanged = (widget.profile.name != name);
    if (!nameChanged && !_imageModified) return;
    final collectionReference = FirebaseFirestore.instance.collection('users');

    final ref = collectionReference.doc(widget.profile.uid);
    if (nameChanged) {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // DocumentSnapshot currentUserSnapshot = await transaction.get(ref);
        transaction.update(ref, {
          'username': name,
        });
      });
    }
    if (_imageModified) {
      final imgUrl = await _uploadImage();
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // DocumentSnapshot currentUserSnapshot = await transaction.get(ref);
        transaction.update(ref, {
          'image_url': imgUrl,
        });
      });
    }
    return;
  }

  // void _setProfile(String uid) async {
  //   setState(() {
  //     _loading = true;
  //   });
  //   final user = await fetchUserData(uid);
  //   userProfile = user;
  //   setState(() {
  //     _loading = false;
  //   });
  // }
}
