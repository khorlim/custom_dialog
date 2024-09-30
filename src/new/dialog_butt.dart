import 'package:flutter/material.dart';

import 'new_dialog.dart';

class DialogButt extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context) dialogBuilder;
  final double dialogHeight;
  final double dialogWidth;
  const DialogButt({
    super.key,
    required this.child,
    required this.dialogBuilder,
    required this.dialogHeight,
    required this.dialogWidth,
  });
  @override
  State<DialogButt> createState() => _DialogButtState();
}

class _DialogButtState extends State<DialogButt> {
  final GlobalKey _key = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _key,
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => NewDialog(
            targetWidgetKey: _key,
            width: widget.dialogWidth,
            height: widget.dialogHeight,
            child: widget.dialogBuilder(context),
          ),
        );
      },
      child: widget.child,
    );
  }
}
