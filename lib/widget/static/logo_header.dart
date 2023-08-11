import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class LogoHeader extends StatelessWidget {
  const LogoHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 0, 19, 76),
            Color.fromARGB(255, 0, 84, 152)
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              FontAwesomeIcons.solidComments,
              size: 70,
              color: Theme.of(context).cardColor,
            ),
            const SizedBox(height: 10),
            Text(
              'Simple Chat',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ).copyWith(
                color: Theme.of(context).cardColor,
                fontSize: 30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
