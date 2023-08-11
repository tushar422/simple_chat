import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: const Color.fromARGB(255, 0, 84, 152),
      body: SingleChildScrollView(
        child: Column(children: [
          const LogoHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(35))),
                padding: const EdgeInsets.all(25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hi There!',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                        ).copyWith(
                          color: const Color.fromARGB(255, 0, 19, 76),
                          fontSize: 30,
                        )),
                    InkWell(
                      child: Text((_loginMode)
                          ? 'Not a user? Sign Up'
                          : 'Already a user? Back to Login'),
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
