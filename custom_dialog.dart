import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:tunaipro/share_code/keyboard_size_provider/keyboard_size_provider.dart';
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
  final double distanceBetweenTargetWidget;

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
    this.distanceBetweenTargetWidget = 0,
  })  : dialogHeight = height,
        screenHeight = MediaQuery.of(context).size.height,
        screenWidth = MediaQuery.of(context).size.width,
        safeAreaTopHeight = MediaQueryData.fromView(ui.window).padding.top;

  final double screenHeight;
  final double screenWidth;
  final double safeAreaTopHeight;

  double dialogHeight;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late AlignTargetWidget alignTargetWidget;
  ArrowPointing arrowPointing = ArrowPointing.left;
  bool enableArrow = false;

  @override
  void initState() {
    super.initState;
    alignTargetWidget = widget.alignTargetWidget;
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
          alignment: alignTargetWidget,
          safeAreaTopHeight: widget.safeAreaTopHeight);

      addAdjustment(alignTargetWidget, widget.adjustment);

      //follow arrow
      if (widget.followArrow &&
          alignTargetWidget != AlignTargetWidget.bottomCenter &&
          alignTargetWidget != AlignTargetWidget.bottomLeft &&
          alignTargetWidget != AlignTargetWidget.topCenter) {
        if (dialogTopPos! >= arrowTopPos!) {
          dialogTopPos = arrowTopPos! - widget.arrowWidth;
        }
        if ((arrowTopPos! + widget.arrowWidth) >=
            (dialogTopPos! + widget.height)) {
          dialogTopPos = arrowTopPos! - widget.height + widget.arrowWidth + 5;
        }

        if (dialogTopPos! < 5) {
          alignTargetWidget = AlignTargetWidget.bottomCenter;
          calculatePos(
              size: widgetBoxSize,
              pos: targetWidgetPos,
              alignment: alignTargetWidget,
              safeAreaTopHeight: widget.safeAreaTopHeight);
        }
      }

      //if show overflow arrow = false
      arrowOverflowed = arrowTopPos! <= (dialogTopPos! + 5) ||
          arrowTopPos! + widget.arrowWidth >=
              (dialogTopPos! + widget.height - 5);
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
        dialogTopPos = getBottomOfWidgetTopPos(
            pos.dy, size.height, enableArrow ? widget.arrowHeight : 0);
        dialogLeftPos =
            getAlignCenterBottomLeftPos(pos.dx, size.width, widget.width);
        arrowTopPos = dialogTopPos! - widget.arrowHeight;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.top;

        dialogLeftPos = preventHorizontalOverflow(dialogLeftPos!, widget.width);

        break;
      case AlignTargetWidget.topCenter:
        dialogTopPos =
            pos.dy - safeAreaTopHeight - widget.height - widget.arrowHeight;
        dialogTopPos = getTopOfWidgetTopPos(
            pos.dy, widget.height, enableArrow ? widget.arrowHeight : 0);
        dialogLeftPos =
            getAlignCenterBottomLeftPos(pos.dx, size.width, widget.width);
        arrowTopPos = dialogTopPos! + widget.height;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.bottom;

        //Prevent dialog overflow to right
        dialogLeftPos = preventHorizontalOverflow(dialogLeftPos!, widget.width);

        if (dialogTopPos! < 10) {
          alignTargetWidget = AlignTargetWidget.right;
          calculatePos(
              size: size,
              pos: pos,
              alignment: alignTargetWidget,
              safeAreaTopHeight: widget.safeAreaTopHeight);
        }

        break;
      case AlignTargetWidget.right || AlignTargetWidget.rightCenter:
        dialogLeftPos = getAlignRightPos(
            pos.dx, size.width, enableArrow == true ? widget.arrowHeight : 0);
        dialogTopPos = getCenterOfScreenTopPos(widget.height);

        if (alignment == AlignTargetWidget.rightCenter) {
          dialogTopPos =
              getCenterOfWidgetTopPos(pos.dy, size.height, widget.height);
          dialogTopPos = preventVerticalOverflow(dialogTopPos!, widget.height);
        }

        arrowTopPos = (pos.dy - safeAreaTopHeight) +
            (size.height / 2) -
            (widget.arrowWidth / 2);
        arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
        arrowPointing = ArrowPointing.left;

        //If dialog exceed right screen
        if (dialogLeftPos! + widget.width >= widget.screenWidth) {
          if (widget.jumpWhenOverflow) {
            //Move the dialog to left
            dialogLeftPos = getAlignLeftPos(
                pos.dx, enableArrow ? widget.arrowHeight : 0, widget.width);
            arrowLeftPos = pos.dx - widget.arrowHeight;
            arrowPointing = ArrowPointing.right;
            dialogLeftPos =
                preventHorizontalOverflow(dialogLeftPos!, widget.width);
            arrowLeftPos = dialogLeftPos! + widget.width;
          } else {
            //Keep the dialog to right but move it to left abit
            dialogLeftPos =
                preventHorizontalOverflow(dialogLeftPos!, widget.width);
            arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
          }
        } else if (dialogLeftPos! < widget.overflowLeft) {
          //If dialog exceed left screen check overeflowLeft (default 0)
          dialogLeftPos = widget.overflowLeft + widget.arrowHeight;
          arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
        }

        break;

      case AlignTargetWidget.left || AlignTargetWidget.leftCenter:
        dialogLeftPos = getAlignLeftPos(
            pos.dx, enableArrow ? widget.arrowHeight : 0, widget.width);
        dialogTopPos = getCenterOfScreenTopPos(widget.height);

        if (alignment == AlignTargetWidget.leftCenter) {
          dialogTopPos =
              getCenterOfWidgetTopPos(pos.dy, size.height, widget.height);
          dialogTopPos = preventVerticalOverflow(dialogTopPos!, widget.height);
        }

        arrowTopPos = (pos.dy - safeAreaTopHeight) +
            (size.height / 2) -
            (widget.arrowWidth / 2);
        arrowLeftPos = dialogLeftPos! + widget.width;
        arrowPointing = ArrowPointing.right;

        //Prevent dialog overflow
        if (dialogLeftPos! < 0) {
          //Jump the dialog to right
          dialogLeftPos = getAlignRightPos(
              pos.dx, size.width, enableArrow ? widget.arrowHeight : 0);
          arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
          arrowPointing = ArrowPointing.left;

          //if jump to right still oveflow stay right but move to left
          dialogLeftPos =
              preventHorizontalOverflow(dialogLeftPos!, widget.width);
          arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
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
      case AlignTargetWidget.right ||
            AlignTargetWidget.left ||
            AlignTargetWidget.rightCenter ||
            AlignTargetWidget.leftCenter:

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
    return KeyboardSizeProvider(
      child: SafeArea(
        child: Consumer<ScreenHeight>(builder: (context, screenHeight, child) {
          bool isKeyboardVisible = screenHeight.isOpen;
          double paddingWhenKeyboardShow = screenHeight.keyboardHeight;
          return LayoutBuilder(builder: (context, constraints) {
            if (isKeyboardVisible) {
              double screenHeight = constraints.maxHeight;

              double newHeight = widget.height -
                  (paddingWhenKeyboardShow -
                      (screenHeight - (widget.height + dialogTopPos!)));

              if (widget.pushDialogAboveWhenKeyboardShow) {
                newHeight = widget.height -
                    (paddingWhenKeyboardShow -
                        (screenHeight - (widget.height + 10)));
                enableArrow = false;
              }

              widget.dialogHeight =
                  newHeight > 0 ? newHeight - 5 : widget.height;
            } else {
              if (widget.pushDialogAboveWhenKeyboardShow) {
                Future.delayed(Duration(milliseconds: 200), () {
                  enableArrow =
                      widget.targetWidgetContext != null ? true : false;
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
                  top: isKeyboardVisible &&
                          widget.pushDialogAboveWhenKeyboardShow
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
      ),
    );
  }

  double preventVerticalOverflow(double dialogTopPos, double dialogHeight) {
    double newTopPos = dialogTopPos;
    if ((dialogTopPos + dialogHeight) >=
        widget.screenHeight - widget.safeAreaTopHeight) {
      newTopPos =
          widget.screenHeight - widget.height - widget.safeAreaTopHeight - 20;
    }
    if ((dialogTopPos < 5)) {
      newTopPos = 5;
    }

    return newTopPos;
  }

  double preventHorizontalOverflow(double dialogLeftPos, double dialogWidth) {
    double newLeftPos = dialogLeftPos;
    if (dialogLeftPos < 5) {
      newLeftPos = 5;
    }
    if (dialogLeftPos + dialogWidth > widget.screenWidth - 5) {
      newLeftPos = widget.screenWidth - dialogWidth - 5;
    }

    return newLeftPos;
  }

  double getAlignRightPos(
      double targetBoxXpos, double targetBoxWidth, double space) {
    return (targetBoxWidth + targetBoxXpos + space) +
        widget.distanceBetweenTargetWidget;
  }

  double getAlignLeftPos(
      double targetBoxXpos, double arrowWidth, double space) {
    return (targetBoxXpos - space - arrowWidth) -
        widget.distanceBetweenTargetWidget;
  }

  double getAlignCenterBottomLeftPos(
      double targetBoxXpos, double targetBoxWidth, double dialogWidth) {
    return targetBoxXpos + (targetBoxWidth / 2) - (dialogWidth / 2);
  }

  double getBottomOfWidgetTopPos(
      double targetBoxYpos, double targetBoxHeight, double arrowHeight) {
    return ((targetBoxYpos - widget.safeAreaTopHeight) +
            targetBoxHeight +
            arrowHeight) +
        widget.distanceBetweenTargetWidget;
  }

  double getTopOfWidgetTopPos(
      double targetBoxYpos, double dialogHeight, double arrowHeight) {
    return targetBoxYpos -
        widget.safeAreaTopHeight -
        dialogHeight -
        arrowHeight -
        widget.distanceBetweenTargetWidget;
  }

  double getCenterOfScreenTopPos(double dialogHeight) {
    return (widget.screenHeight / 2) -
        (dialogHeight / 2) -
        widget.safeAreaTopHeight;
  }

  double getCenterOfWidgetTopPos(
      double targetBoxXpos, double targetBoxHeight, double dialogHeight) {
    return (targetBoxXpos + (targetBoxHeight / 2)) -
        (dialogHeight / 2) -
        widget.safeAreaTopHeight;
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
