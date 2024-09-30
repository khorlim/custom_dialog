import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../custom_dialog.dart';
import '../utils/position_calculator.dart';

class NewDialog extends StatefulWidget {
  final double height;
  final double width;
  final GlobalKey targetWidgetKey;
  final Widget child;
  final AlignTargetWidget alignTargetWidget;
  final void Function()? onTapOutside;
  final double borderRadius;

  const NewDialog({
    super.key,
    required this.targetWidgetKey,
    required this.child,
    required this.width,
    required this.height,
    this.alignTargetWidget = AlignTargetWidget.right,
    this.onTapOutside,
    this.borderRadius = 10,
  });

  @override
  State<NewDialog> createState() => NewDialogState();
}

class NewDialogState extends State<NewDialog> {
  late AlignTargetWidget alignTargetWidget = widget.alignTargetWidget;

  Offset dialogPos = Offset.zero;

  late Size dialogSize = Size(widget.width, widget.height);

  @override
  void initState() {
    super.initState();
    calculatePos(dialogSize);
  }

  @override
  void didUpdateWidget(covariant NewDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void calculatePos(Size dialogSize) {
    final RenderBox renderBox =
        widget.targetWidgetKey.currentContext!.findRenderObject() as RenderBox;
    PositionCalculator calculator = PositionCalculator(
      context: widget.targetWidgetKey.currentContext!,
      dialogSize: dialogSize,
      targetWidgetSize: renderBox.size,
      targetWidgetPos: renderBox.localToGlobal(Offset.zero),
      arrowSize: null,
    );

    switch (widget.alignTargetWidget) {
      case AlignTargetWidget.bottomCenter:
        dialogPos = calculator.getAlignBottom();

        break;
      case AlignTargetWidget.topCenter:
        dialogPos = calculator.getAlignTop();

        break;
      case AlignTargetWidget.right || AlignTargetWidget.rightCenter:
        dialogPos = calculator.getAlignRight();

        if (calculator.isExceedRight(dialogPos.dx)) {
          alignTargetWidget = AlignTargetWidget.left;
          dialogPos = calculator.getAlignLeft();
        }

        break;

      case AlignTargetWidget.left || AlignTargetWidget.leftCenter:
        dialogPos = calculator.getAlignLeft();

        if (calculator.isExceedLeft(dialogPos.dx)) {
          alignTargetWidget = AlignTargetWidget.right;
          dialogPos = calculator.getAlignRight();
        }

        break;

      case AlignTargetWidget.bottomLeft:
        dialogPos = calculator.getAlignBottomLeft();
        break;
      case AlignTargetWidget.centerBottomRight:
        dialogPos = calculator.getAlignTargetWidgetBottomRight();
        break;
    }
    dialogPos = calculator.preventOverflow(dialogPos);
  }

  void updateDialogSize(Size size) {
    dialogSize = size;
    calculatePos(size);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // print('-------');
    // print('dialogPos: $dialogPos');

    return OrientationBuilder(builder: (context, orientation) {
      return Stack(
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: widget.onTapOutside != null
                ? () => widget.onTapOutside?.call()
                : () {
                    Navigator.pop(context);
                  },
          ),
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.fastEaseInToSlowEaseOut,
            top: dialogPos.dy,
            left: dialogPos.dx,
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  spreadRadius: 20,
                  blurRadius: 30,
                  offset: Offset(0, 0),
                ),
              ]),
              child: Material(
                clipBehavior: Clip.antiAlias,
                elevation: 0.0,
                shadowColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                ),
                child: AnimatedContainer(
                  duration: 50.ms,
                  clipBehavior: Clip.antiAlias,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(widget.borderRadius),
                        bottomRight: Radius.circular(widget.borderRadius)),
                  ),
                  height: dialogSize.height,
                  width: dialogSize.width,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }
}
