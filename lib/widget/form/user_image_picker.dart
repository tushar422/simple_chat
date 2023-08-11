import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.onPicked});

  final Function(File? image) onPicked;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: _showSource,
      child: CircleAvatar(
        radius: 60,
        foregroundImage:
            (_pickedImage != null) ? FileImage(_pickedImage!) : null,
        child: const Icon(
          Icons.add_a_photo,
          size: 40,
        ),
      ),
    );
  }

  void _showSource() {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Select image source:'),
            content: Wrap(
              direction: Axis.vertical,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Take a photo'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Upload from gallery'),
                ),
              ],
            ),
          );
        });
  }

  void _pickImage(ImageSource source) async {
    final file = await ImagePicker()
        .pickImage(source: source, imageQuality: 80, maxWidth: 150);
    if (file == null) {
      return;
    }
    setState(() {
      _pickedImage = File(file.path);
    });

    widget.onPicked(_pickedImage);
  }
}
