import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surfaceVariant,
            // Color.fromARGB(255, 0, 19, 76),
            // Color.fromARGB(255, 0, 84, 152)
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.7,
              child: Image.asset(
                (Theme.of(context).brightness == Brightness.dark)
                    ? 'assets/logo-primary-dark.png'
                    : 'assets/logo-primary-light.png',
              ),
            ),
            //  Image.asset(),
          ],
        ),
      ),
    );
  }
}
