import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'dart:ui' as ui;
import 'triangle.dart';

part 'enum.dart';

class CustomDialog extends StatefulWidget {
  final BuildContext context;
  final double height;
  final double width;
  final Widget? appBar;
  final Widget child;
  final BuildContext? targetWidgetContext;
  final AlignTargetWidget alignTargetWidget;
  final bool enableArrow;
  final double arrowWidth;
  final double arrowHeight;
  final Offset adjustment;
  final Function? onTapOutside;
  final bool showOverFlowArrow;
  final bool jumpWhenOverflow;
  final double overflowLeft;
  final bool pushDialogAboveWhenKeyboardShow;
  final bool followArrow;

  CustomDialog({
    required this.context,
    required this.child,
    this.appBar,
    this.width = 400,
    this.height = 650,
    this.alignTargetWidget = AlignTargetWidget.right,
    this.enableArrow = false,
    this.arrowWidth = 30,
    this.arrowHeight = 15,
    this.targetWidgetContext,
    this.onTapOutside,
    this.adjustment = const Offset(0, 0),
    this.showOverFlowArrow = true,
    this.jumpWhenOverflow = true,
    this.overflowLeft = 0,
    this.pushDialogAboveWhenKeyboardShow = false,
    this.followArrow = false,
  })  : dialogHeight = height,
        screenHeight = MediaQuery.of(context).size.height,
        screenWidth = MediaQuery.of(context).size.width,
        safeAreaTopHeight = MediaQueryData.fromView(ui.window).padding.top,
        paddingWhenKeyboardShow = MediaQuery.of(context).viewInsets.bottom;

  final double screenHeight;
  final double screenWidth;
  final double safeAreaTopHeight;
  final double paddingWhenKeyboardShow;

  double dialogHeight;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  ArrowPointing arrowPointing = ArrowPointing.left;
  bool enableArrow = false;

  @override
  void initState() {
    super.initState;
    //Get essential data to calculate position yes
    enableArrow = widget.enableArrow;
    RenderBox? targetWidgetRBox =
        widget.targetWidgetContext?.findRenderObject() as RenderBox?;

    Size? widgetBoxSize = targetWidgetRBox?.size;
    Offset? targetWidgetPos = targetWidgetRBox?.localToGlobal(Offset.zero);
    bool arrowOverflowed = false;
    if (targetWidgetRBox != null) {
      calculatePos(
          size: widgetBoxSize!,
          pos: targetWidgetPos!,
          alignment: widget.alignTargetWidget,
          safeAreaTopHeight: widget.safeAreaTopHeight);

      addAdjustment(widget.alignTargetWidget, widget.adjustment);

      //follow arrow
      if(widget.followArrow) {
       
        if(dialogTopPos! >= arrowTopPos!) {
          dialogTopPos = arrowTopPos! - widget.arrowWidth;
        }
        if((arrowTopPos! + widget.arrowWidth) >= (dialogTopPos! + widget.height)){
          dialogTopPos = arrowTopPos! - widget.height + widget.arrowWidth + 5;
        }
      }

      //if show overflow arrow = false
      arrowOverflowed =
          arrowTopPos! + widget.arrowWidth >= (dialogTopPos! + widget.height);
      if (!widget.showOverFlowArrow && arrowOverflowed) {
        enableArrow = false;
      }
    } else {
      //Default toppos is middle
      dialogTopPos = (widget.screenHeight / 2) -
          (widget.height / 2) -
          widget.safeAreaTopHeight;
    }
  }

  void calculatePos({
    required Size size,
    required Offset pos,
    required AlignTargetWidget alignment,
    required double safeAreaTopHeight,
  }) {
    switch (alignment) {
      case AlignTargetWidget.bottomCenter:
        dialogTopPos = pos.dy - safeAreaTopHeight + size.height;
        dialogLeftPos = pos.dx + (size.width / 2) - (widget.width / 2);
        arrowTopPos = dialogTopPos! - widget.arrowHeight;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.top;

        //Prevent dialog overflow to right
        if (dialogLeftPos! + widget.width > widget.screenWidth) {
          dialogLeftPos = widget.screenWidth - widget.width - 5;
        }

        break;
      case AlignTargetWidget.topCenter:
        dialogTopPos =
            pos.dy - safeAreaTopHeight - widget.height - widget.arrowHeight;
        dialogLeftPos = pos.dx + (size.width / 2) - (widget.width / 2);
        arrowTopPos = dialogTopPos! + widget.height;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.bottom;

        //Prevent dialog overflow to right
        if (dialogLeftPos! + widget.width > widget.screenWidth) {
          dialogLeftPos = widget.screenWidth - widget.width - 5;
        }

        break;
      case AlignTargetWidget.right:
        dialogLeftPos = pos.dx + size.width + widget.arrowHeight;
        dialogTopPos =
            (widget.screenHeight / 2) - (widget.height / 2) - safeAreaTopHeight;

        arrowTopPos = (pos.dy - safeAreaTopHeight) +
            (size.height / 2) -
            (widget.arrowWidth / 2);
        arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
        arrowPointing = ArrowPointing.left;

        //If dialog exceed right screen
        if (dialogLeftPos! + widget.width >= widget.screenWidth) {
          if (widget.jumpWhenOverflow) {
            //Move the dialog to left
            dialogLeftPos = pos.dx - widget.width - widget.arrowHeight;
            arrowLeftPos = pos.dx - widget.arrowHeight;
            arrowPointing = ArrowPointing.right;
          } else {
            //Keep the dialog to right but move it to left abit
            dialogLeftPos = widget.screenWidth - widget.width - 5;
            arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
          }
        } else if (dialogLeftPos! < widget.overflowLeft) {
          //If dialog exceed left screen check overeflowLeft (default 0)
          dialogLeftPos = widget.overflowLeft + widget.arrowHeight;
          arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
        }

        break;

      case AlignTargetWidget.left:
        dialogLeftPos = pos.dx - widget.width - widget.arrowHeight;
        dialogTopPos =
            (widget.screenHeight / 2) - (widget.height / 2) - safeAreaTopHeight;

        arrowTopPos = (pos.dy - safeAreaTopHeight) +
            (size.height / 2) -
            (widget.arrowWidth / 2);
        arrowLeftPos = dialogLeftPos! + widget.width;
        arrowPointing = ArrowPointing.right;

        //Prevent dialog overflow
        if (dialogLeftPos! < 0) {
          //Jump the dialog to right
          dialogLeftPos = pos.dx + size.width + widget.arrowHeight;
          arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
          arrowPointing = ArrowPointing.left;

          //if jump to right still oveflow stay right but move to left
          if(dialogLeftPos! + widget.width > (widget.screenWidth - 10)){
            dialogLeftPos = widget.screenWidth - widget.width - 10;
            arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
          }
        }

        break;

      case AlignTargetWidget.bottomLeft:
        dialogTopPos = pos.dy - safeAreaTopHeight + size.height;
        dialogLeftPos = pos.dx - widget.width + size.width;
        arrowTopPos = dialogTopPos! - widget.arrowHeight;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.top;

        //Prevent dialog overflow to right
        if (dialogLeftPos! + widget.width > widget.screenWidth) {
          dialogLeftPos = widget.screenWidth - widget.width - 5;
        } else if (dialogLeftPos! < 5) {
          //Prevent dialog overflow to left
          dialogLeftPos = 5;
        }

        break;
    }
  }

  void addAdjustment(AlignTargetWidget alignment, Offset adjustment) {
    switch (alignment) {
      case AlignTargetWidget.right || AlignTargetWidget.left:

        //Add adjustment
        if (adjustment != Offset(0, 0)) {
          double y = widget.adjustment.dy;
          double x = widget.adjustment.dx;

          dialogTopPos = dialogTopPos! + y;
          dialogLeftPos = dialogLeftPos! + x;
          arrowLeftPos = arrowLeftPos! + x;
        }

        break;

      case AlignTargetWidget.bottomLeft ||
            AlignTargetWidget.bottomCenter ||
            AlignTargetWidget.topCenter:
        if (adjustment != Offset(0, 0)) {
          double y = widget.adjustment.dy;
          double x = widget.adjustment.dx;

          dialogTopPos = dialogTopPos! + y;
          arrowTopPos = arrowTopPos! + y;
          dialogLeftPos = dialogLeftPos! + x;
        }

        break;
    }
  }

  double? dialogTopPos;
  double? dialogLeftPos;
  double? arrowTopPos;
  double? arrowLeftPos;

  @override
  Widget build(BuildContext context) {
    
    return SafeArea(
      child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return LayoutBuilder(builder: (context, constraints) {
          if (isKeyboardVisible) {
            double screenHeight = constraints.maxHeight;
           
            double newHeight = widget.height -
                (widget.paddingWhenKeyboardShow -
                    (screenHeight - (widget.height + dialogTopPos!)));


            if (widget.pushDialogAboveWhenKeyboardShow) {
              newHeight = widget.height -
                  (widget.paddingWhenKeyboardShow -
                      (screenHeight - (widget.height + 10)));
              enableArrow = false;
            }

            widget.dialogHeight = newHeight > 0 ? newHeight - 5 : widget.height;
          } else {
            if (widget.pushDialogAboveWhenKeyboardShow) {
              Future.delayed(Duration(milliseconds: 200), () {
                enableArrow = true;
              });
            }
            widget.dialogHeight = widget.height;
          }
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
                top: isKeyboardVisible && widget.pushDialogAboveWhenKeyboardShow
                    ? 10
                    : dialogTopPos,
                left: dialogLeftPos,
                child: Material(
                  clipBehavior: Clip.antiAlias,
                  elevation: 5,
                  shadowColor: Colors.grey.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ]),
                    height: widget.dialogHeight,
                    width: widget.width,
                    child: Column(
                      children: [
                        widget.appBar ?? Container(),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ),
              ),
              if (enableArrow)
                Positioned(
                  top: arrowTopPos,
                  left: arrowLeftPos,
                  child: PhysicalModel(
                    color: Colors.transparent,
                    elevation: 3,
                    shadowColor: Colors.grey.withOpacity(0.06),
                    shape: BoxShape.circle,
                    child: CustomPaint(
                      painter: _getArrowPainter(arrowPointing),
                      child: Container(
                        width: arrowPointing == ArrowPointing.top ||
                                arrowPointing == ArrowPointing.bottom
                            ? widget.arrowWidth
                            : widget.arrowHeight,
                        height: arrowPointing == ArrowPointing.top ||
                                arrowPointing == ArrowPointing.bottom
                            ? widget.arrowHeight
                            : widget.arrowWidth,
                      ),
                    ),
                  ),
                )
            ],
          );
        });
      }),
    );
  }

  CustomPainter _getArrowPainter(ArrowPointing arrowPointing) {
    switch (arrowPointing) {
      case ArrowPointing.top:
        return TriangleArrowTop();
      case ArrowPointing.left:
        return TriangleArrowLeft();
      case ArrowPointing.bottom:
        return TriangleArrowDown();
      case ArrowPointing.right:
        return TriangleArrowRight();
    }
  }
}
