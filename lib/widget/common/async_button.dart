import 'package:flutter/material.dart';

class AsyncButton extends StatefulWidget {
  const AsyncButton({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 15),
    this.enabled = true,
    this.elevation = 0,
    this.onComplete,
  });

  final Future<dynamic> Function() onTap;
  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;
  final bool enabled;
  final double elevation;
  final void Function(dynamic)? onComplete;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

class _AsyncButtonState extends State<AsyncButton> {
  bool _processing = false;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.enabled ? ((_processing) ? null : _execute) : null,
      style: ElevatedButton.styleFrom(
        elevation: widget.elevation,
        padding: widget.padding,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      child: (_processing)
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
              ))
          : widget.child,
    );
  }

  void _execute() async {
    setState(() {
      _processing = true;
    });
    final result = await widget.onTap();
    widget.onComplete ?? (result);

    setState(() {
      _processing = false;
    });
  }
}
