import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/util/firebase.dart';
import 'package:simple_chat/util/validator.dart';
import 'package:simple_chat/widget/form/social_login_row.dart';
import 'package:simple_chat/widget/form/user_image_picker.dart';

final firebaseAuth = FirebaseAuth.instance;

class SignUpAuthForm extends StatefulWidget {
  const SignUpAuthForm({super.key});

  @override
  State<SignUpAuthForm> createState() => _SignUpAuthFormState();
}

class _SignUpAuthFormState extends State<SignUpAuthForm> {
  final _signupForm = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _selectedImage;

  bool _submitting = false;

  bool _passwordObscured = true;
  bool _staySignedInCheck = true;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _signupForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserImagePicker(
            onPicked: (image) {
              _selectedImage = image;
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            validator: validateEmail,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              label: Text('E-Mail'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.alternate_email),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _usernameController,
            validator: validateUsername,
            decoration: const InputDecoration(
              label: Text('Username'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            validator: validatePassword,
            obscureText: _passwordObscured,
            decoration: InputDecoration(
              label: const Text('Password'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.password),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    _passwordObscured = !_passwordObscured;
                  });
                },
                icon: Icon((_passwordObscured)
                    ? Icons.visibility_off
                    : Icons.visibility),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(elevation: MaterialStateProperty.all(10)),
                onPressed: (!_submitting) ? _submit : null,
                child: (!_submitting)
                    ? const Text('Sign Up')
                    : const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      ),
              )
            ],
          ),
          const SizedBox(height: 30),
          const SocialLoginRow(),
        ],
      ),
    );
  }

  void _submit() async {
    final isValid = _signupForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    _signupForm.currentState!.save;

    try {
      setState(() {
        _submitting = true;
      });
      final credentials = await firebaseAuth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      String? url;
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_avatar')
            .child('${credentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        url = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credentials.user!.uid)
          .set({
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'image_url': url,
        'deviceToken': await getPushNotificationsToken()??'',
        'contacts': <String>[],
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('User Already Exists!'),
                content: const Text(
                    'The entered email address is already in use. Please login instead.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Okay'))
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return const AlertDialog(
                title: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60, horizontal: 5),
                  child: Text(
                      'An error occurred. Please try again after some time.'),
                ),
                // content: Text(''),
              );
            });
      }
    } finally {
      setState(() {
        _submitting = false;
      });
    }
  }
}
