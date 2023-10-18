import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_chat/util/firebase.dart';
import 'package:simple_chat/util/validator.dart';
import 'package:simple_chat/widget/form/social_login_row.dart';

final firebaseAuth = FirebaseAuth.instance;

class LoginAuthForm extends StatefulWidget {
  const LoginAuthForm({super.key});

  @override
  State<LoginAuthForm> createState() => _LoginAuthFormState();
}

class _LoginAuthFormState extends State<LoginAuthForm> {
  final _loginForm = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;

  bool _passwordObscured = true;
  bool _staySignedInCheck = true;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _loginForm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _emailController,
            validator: validateEmail,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            decoration: const InputDecoration(
              label: Text('E-Mail'),
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.alternate_email),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            validator: validatePassword,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),

            keyboardType: TextInputType.visiblePassword,
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
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Keep me logged in:',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Checkbox(
                value: _staySignedInCheck,
                onChanged: ((value) {
                  setState(() {
                    _staySignedInCheck = value ?? false;
                  });
                }),
              ),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('Forgot Password'))
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ButtonStyle(elevation: MaterialStateProperty.all(10)),
                onPressed: (!_submitting) ? _submit : null,
                child: (!_submitting)
                    ? const Text('Login')
                    : const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(),
                      ),
              )
            ],
          ),
          const SizedBox(height: 30),
          // const SocialLoginRow(),
        ],
      ),
    );
  }

  void _submit() async {
    final isValid = _loginForm.currentState!.validate();
    if (!isValid) {
      return;
    }
    try {
      setState(() {
        _submitting = true;
      });
      final credentials = await firebaseAuth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim());
      final token = await getPushNotificationsToken();
      updateDeviceToken(credentials.user!.uid, token ?? '');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email' ||
          e.code == 'user-disabled' ||
          e.code == 'user-not-found' ||
          e.code == 'wrong-password') {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Check the entered details'),
                content: const Text(
                    'The entered email address or password looks incorrect.'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Okay!'))
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

      print('yhhdgo');
    }
  }
}
