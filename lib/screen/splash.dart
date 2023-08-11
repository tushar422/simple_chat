import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(
            FontAwesomeIcons.solidComments,
            size: 150,
            color: Theme.of(context).cardColor,
          ),
          const SizedBox(height: 10),
          Text(
            'Simple Chat',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
            ).copyWith(
              color: Theme.of(context).cardColor,
              fontSize: 50,
            ),
          ),
        ],
      ),
    );
  }
}
