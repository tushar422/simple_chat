import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Or choose one of these',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.google),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.facebookF),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(FontAwesomeIcons.twitter),
            ),
          ],
        ),
      ],
    );
  }
}
