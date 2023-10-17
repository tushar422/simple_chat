import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:simple_chat/screen/chat.dart';
import 'package:simple_chat/screen/home.dart';
import 'package:simple_chat/screen/splash.dart';
import 'package:simple_chat/theme/color_schemes.dart';
import 'package:simple_chat/util/firebase.dart';
import 'firebase_options.dart';
import 'package:simple_chat/screen/auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Chat',
      // darkTheme: ThemeData.dark(),
      // darkTheme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     brightness: Brightness.dark,
      //     seedColor: const Color.fromARGB(255, 0, 19, 76),
      //   ),
      //   useMaterial3: true,
      // ),
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(
      //     seedColor: const Color.fromARGB(255, 0, 19, 76),
      //   ),
      //   useMaterial3: true,
      // ),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            return const ChatsScreen();
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
