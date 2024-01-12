import 'package:flutter/material.dart';
import 'package:tunaipro/share_code/keyboard_size_provider/keyboard_size_provider.dart';
import 'dart:ui' as ui;
import 'triangle.dart';

part 'enum.dart';

class CustomDialog extends StatefulWidget {
  final BuildContext context;
  final double? height;
  final double? width;
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
  final bool adjustSizeWhenKeyboardShow;

  CustomDialog({
    required this.context,
    required this.child,
    this.appBar,
    this.width,
    this.height,
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
    this.adjustSizeWhenKeyboardShow = true,
  }) {
    safeAreaTopHeight = MediaQueryData.fromView(ui.window).padding.top;
  }

  late final double safeAreaTopHeight;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  late AlignTargetWidget alignTargetWidget;
  ArrowPointing arrowPointing = ArrowPointing.left;
  bool enableArrow = false;

  late double dialogHeight;
  late double dialogWidth;
  late double oriHeight;

  late double screenHeight;
  late double screenWidth;

  void updateDialogPos({double? old}) {
    alignTargetWidget = widget.alignTargetWidget;
    //Get essential data to calculate position yes
    enableArrow = widget.enableArrow;
    if (widget.targetWidgetContext != null &&
        !widget.targetWidgetContext!.mounted) {
      // Navigator.pop(context);
      return;
    }
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
        if ((arrowTopPos! + widget.arrowWidth) >= (dialogTopPos! + oriHeight)) {
          dialogTopPos = arrowTopPos! - oriHeight + widget.arrowWidth + 5;
        }

        if (dialogTopPos! < 5) {
          alignTargetWidget = AlignTargetWidget.bottomCenter;
          calculatePos(
              size: widgetBoxSize,
              pos: targetWidgetPos,
              alignment: alignTargetWidget,
              safeAreaTopHeight: widget.safeAreaTopHeight);
        }
        dialogTopPos = preventVerticalOverflow(dialogTopPos!, oriHeight);
      }

      //if show overflow arrow = false
      arrowOverflowed = arrowTopPos! <= (dialogTopPos! + 5) ||
          arrowTopPos! + widget.arrowWidth >= (dialogTopPos! + oriHeight - 5);
      if (!widget.showOverFlowArrow && arrowOverflowed) {
        enableArrow = false;
      }
    } else {
      //Default toppos is middle
      dialogTopPos =
          (screenHeight / 2) - (oriHeight / 2) - widget.safeAreaTopHeight;
    }
    if (old != null && dialogLeftPos != old) {
      enableArrow = false;
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          setState(() {
            enableArrow = true;
          });
        }
      });
    }
  }

  void getDialogHeight(Orientation orientation) {
    double height =
        screenHeight * (orientation == Orientation.landscape ? 0.78 : 0.55);
    dialogHeight = widget.height ?? height;
    oriHeight = dialogHeight;
  }

  void getDialogWidth(Orientation orientation) {
    double width =
        screenWidth * (orientation == Orientation.landscape ? 0.35 : 0.47);
    dialogWidth = widget.width ?? width;
  }

  @override
  void initState() {
    super.initState;
    screenHeight = MediaQuery.of(widget.context).size.height;
    screenWidth = MediaQuery.of(widget.context).size.width;
    oldOrientation = MediaQuery.of(widget.context).orientation;
    getDialogHeight(oldOrientation);
    getDialogWidth(oldOrientation);
    updateDialogPos();
  }

  @override
  void didUpdateWidget(covariant CustomDialog oldWidget) {
    updateDialogPos(old: dialogLeftPos);

    Future.delayed(Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() {});
      }
    });
    super.didUpdateWidget(oldWidget);
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
            getAlignCenterBottomLeftPos(pos.dx, size.width, dialogWidth);
        arrowTopPos = dialogTopPos! - widget.arrowHeight;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.top;

        dialogLeftPos = preventHorizontalOverflow(dialogLeftPos!, dialogWidth);

        break;
      case AlignTargetWidget.topCenter:
        dialogTopPos =
            pos.dy - safeAreaTopHeight - oriHeight - widget.arrowHeight;
        dialogTopPos = getTopOfWidgetTopPos(
            pos.dy, oriHeight, enableArrow ? widget.arrowHeight : 0);
        dialogLeftPos =
            getAlignCenterBottomLeftPos(pos.dx, size.width, dialogWidth);
        arrowTopPos = dialogTopPos! + oriHeight;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.bottom;

        //Prevent dialog overflow to right
        dialogLeftPos = preventHorizontalOverflow(dialogLeftPos!, dialogWidth);

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
        dialogTopPos = getCenterOfScreenTopPos(oriHeight);

        if (alignment == AlignTargetWidget.rightCenter) {
          dialogTopPos =
              getCenterOfWidgetTopPos(pos.dy, size.height, oriHeight);
          dialogTopPos = preventVerticalOverflow(dialogTopPos!, oriHeight);
        }

        arrowTopPos = (pos.dy - safeAreaTopHeight) +
            (size.height / 2) -
            (widget.arrowWidth / 2);
        arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
        arrowPointing = ArrowPointing.left;

        //If dialog exceed right screen
        if (dialogLeftPos! + dialogWidth >= screenWidth) {
          if (widget.jumpWhenOverflow) {
            //Move the dialog to left
            dialogLeftPos = getAlignLeftPos(
                pos.dx, enableArrow ? widget.arrowHeight : 0, dialogWidth);
            arrowLeftPos = pos.dx - widget.arrowHeight;
            arrowPointing = ArrowPointing.right;
            dialogLeftPos =
                preventHorizontalOverflow(dialogLeftPos!, dialogWidth);
            arrowLeftPos = dialogLeftPos! + dialogWidth;
          } else {
            //Keep the dialog to right but move it to left abit
            dialogLeftPos =
                preventHorizontalOverflow(dialogLeftPos!, dialogWidth);
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
            pos.dx, enableArrow ? widget.arrowHeight : 0, dialogWidth);
        dialogTopPos = getCenterOfScreenTopPos(oriHeight);

        if (alignment == AlignTargetWidget.leftCenter) {
          dialogTopPos =
              getCenterOfWidgetTopPos(pos.dy, size.height, oriHeight);
          dialogTopPos = preventVerticalOverflow(dialogTopPos!, oriHeight);
        }

        arrowTopPos = (pos.dy - safeAreaTopHeight) +
            (size.height / 2) -
            (widget.arrowWidth / 2);
        arrowLeftPos = dialogLeftPos! + dialogWidth;
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
              preventHorizontalOverflow(dialogLeftPos!, dialogWidth);
          arrowLeftPos = dialogLeftPos! - widget.arrowHeight;
        }

        break;

      case AlignTargetWidget.bottomLeft:
        dialogTopPos = pos.dy - safeAreaTopHeight + size.height;
        dialogLeftPos = pos.dx - dialogWidth + size.width;
        arrowTopPos = dialogTopPos! - widget.arrowHeight;
        arrowLeftPos = pos.dx + (size.width / 2) - (widget.arrowWidth / 2);
        arrowPointing = ArrowPointing.top;

        //Prevent dialog overflow to right
        if (dialogLeftPos! + dialogWidth > screenWidth) {
          dialogLeftPos = screenWidth - dialogWidth - 5;
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

  late Orientation oldOrientation;

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    // print('rebuilding');
    return OrientationBuilder(builder: (context, orientation) {
      getDialogHeight(orientation);
      getDialogWidth(orientation);

      updateDialogPos(old: dialogLeftPos);
      oldOrientation = orientation;
      if (oldOrientation != orientation) {
        enableArrow = false;
      }
      return KeyboardSizeProvider(
        child: SafeArea(
          child:
              Consumer<ScreenHeight>(builder: (context, screenHeight, child) {
            bool isKeyboardVisible = screenHeight.isOpen;
            double paddingWhenKeyboardShow = screenHeight.keyboardHeight;
            return LayoutBuilder(builder: (context, constraints) {
              if (isKeyboardVisible) {
                double screenHeight = constraints.maxHeight;

                double newHeight = oriHeight -
                    (paddingWhenKeyboardShow -
                        (screenHeight - (oriHeight + dialogTopPos!)));

                if (widget.pushDialogAboveWhenKeyboardShow) {
                  newHeight = oriHeight -
                      (paddingWhenKeyboardShow -
                          (screenHeight - (oriHeight + 10)));
                  enableArrow = false;
                }
                if (widget.adjustSizeWhenKeyboardShow) {
                  dialogHeight = newHeight > 0 ? newHeight - 5 : oriHeight;
                }
              } else {
                if (widget.pushDialogAboveWhenKeyboardShow) {
                  Future.delayed(Duration(milliseconds: 200), () {
                    enableArrow =
                        widget.targetWidgetContext != null ? true : false;
                  });
                }
                dialogHeight = oriHeight;
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
                    curve: Curves.easeInOut,
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
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 50),
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
                        height: dialogHeight,
                        width: dialogWidth,
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
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
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
    });
  }

  double preventVerticalOverflow(double dialogTopPos, double dialogHeight) {
    double newTopPos = dialogTopPos;
    if ((dialogTopPos + dialogHeight) >=
        screenHeight - widget.safeAreaTopHeight) {
      newTopPos = screenHeight - oriHeight - widget.safeAreaTopHeight - 20;
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
    if (dialogLeftPos + dialogWidth > screenWidth - 5) {
      newLeftPos = screenWidth - dialogWidth - 5;
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
    return (screenHeight / 2) - (dialogHeight / 2) - widget.safeAreaTopHeight;
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
