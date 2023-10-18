import 'package:flutter/material.dart';
import 'package:simple_chat/widget/form/login_form.dart';
import 'package:simple_chat/widget/form/signup_form.dart';
import 'package:simple_chat/widget/static/logo_header.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _loginMode = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
      body: SingleChildScrollView(
        child: Column(children: [
          const LogoHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
            child: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.all(Radius.circular(35))),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi There!',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              // color: const Color.fromARGB(255, 0, 19, 76),
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            )),
                    InkWell(
                      child: Text(
                        (_loginMode)
                            ? 'Not a user? Sign Up'
                            : 'Already a user? Back to Login',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      onTap: () {
                        setState(() {
                          _loginMode = !_loginMode;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    (_loginMode) ? LoginAuthForm() : SignUpAuthForm(),
                  ],
                )),
          ),
        ]),
      ),
    );
  }
}
