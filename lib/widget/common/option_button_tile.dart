import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OptionButtonTile extends StatelessWidget {
  const OptionButtonTile({
    super.key,
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String description;
  final Icon icon;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: ListTile(
          title: Text(label),
          subtitle: Text(description),
          leading: icon,
          // col
          shape: const StadiumBorder(),
          onTap: onTap,
        ),
      ),
    );
  }
}
