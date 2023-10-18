import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRCardDialog extends StatelessWidget {
  const QRCardDialog({
    super.key,
    required this.content,
    this.title,
    this.name,
  });
  final String content;
  final String? title;
  final String? name;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(30),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: QrImageView(
              data: content,
              version: QrVersions.auto,
              size: 150.0,
            ),
          ),
          const SizedBox(height: 20),
          if (title != null)
            Text(
              title!,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          if (name != null)
            Text(
              '${name!}\'s QR',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
        ],
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Okay'),
        ),
      ],
    );
  }
}
