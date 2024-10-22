import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'utils/position_calculator.dart';
import '../../dump/keyboard_size_provider/keyboard_size_provider.dart';
import 'custom_dialog.dart';
import 'triangle.dart';

class CustomPositionDialog extends StatefulWidget {
  final BuildContext context;
  final double? height;
  final double? width;
  final Widget? appBar;
  final Widget child;
  final AlignTargetWidget alignTargetWidget;
  final bool enableArrow;
  final double arrowWidth;
  final double arrowHeight;
  final Offset adjustment;
  final Function? onTapOutside;
  final bool showOverFlowArrow;
  final double overflowLeft;
  final bool pushDialogAboveWhenKeyboardShow;
  final bool followArrow;
  final double distanceBetweenTargetWidget;
  final bool adjustSizeWhenKeyboardShow;
  final bool static;
  final double borderRadius;
  late final Offset targetWidgetPos;
  final GlobalKey targetWidgetKey;

  CustomPositionDialog({
    super.key,
    required this.context,
    required this.child,
    this.appBar,
    this.width,
    this.height,
    this.alignTargetWidget = AlignTargetWidget.right,
    this.enableArrow = false,
    this.arrowWidth = 30,
    this.arrowHeight = 15,
    this.onTapOutside,
    this.adjustment = const Offset(0, 0),
    this.showOverFlowArrow = true,
    this.overflowLeft = 0,
    this.pushDialogAboveWhenKeyboardShow = false,
    this.followArrow = false,
    this.distanceBetweenTargetWidget = 0,
    this.adjustSizeWhenKeyboardShow = true,
    this.static = true,
    this.borderRadius = 10,
    required this.targetWidgetKey,
  }) {
    safeAreaTopHeight = MediaQueryData.fromView(View.of(context)).padding.top;
  }

  late final double safeAreaTopHeight;

  @override
  State<CustomPositionDialog> createState() => _CustomPositionDialogState();
}

class _CustomPositionDialogState extends State<CustomPositionDialog> {
  late AlignTargetWidget alignTargetWidget = widget.alignTargetWidget;
  late bool static = widget.static;
  late bool enableArrow = widget.enableArrow;

  late double dialogHeight;
  late double dialogWidth;
  late double oriHeight;

  late double screenHeight = MediaQuery.of(widget.context).size.height;
  late double screenWidth = MediaQuery.of(widget.context).size.width;

  RenderBox? targetWidgetRBox;
  Offset? targetWidgetPos;
  Size? targetWidgetSize;

  ValueNotifier<bool> isKeyboardVisibleNotifier = ValueNotifier<bool>(false);

  Offset dialogPos = Offset.zero;
  Offset arrowPos = Offset.zero;

  late Orientation oldOrientation;

  void updateDialogPos(BuildContext context, {bool forceCenter = false}) {
    calculatePos(alignTargetWidget, context);
    calculateArrowPos(alignTargetWidget, context);
  }

  void getDialogHeight(Orientation orientation) {
    double height =
        screenHeight * (orientation == Orientation.landscape ? 0.78 : 0.55);

    // double manualRatioHeight = screenHeight * (widget.heightRatio ?? 1);

    dialogHeight = widget.height ?? height;

    oriHeight = dialogHeight;
  }

  void getDialogWidth(Orientation orientation) {
    double width =
        screenWidth * (orientation == Orientation.landscape ? 0.35 : 0.47);

    //  double manualRatioWidth = screenWidth * (widget.widthRatio ?? 1);

    dialogWidth = widget.width ?? width;

    if (widget.width == null && dialogWidth < 350) {
      dialogWidth = 350;
    }
  }

  void updateRenderBox() {
    targetWidgetRBox =
        widget.targetWidgetKey.currentContext!.findRenderObject() as RenderBox;

    targetWidgetSize = targetWidgetRBox!.size;

    targetWidgetPos = targetWidgetRBox!.localToGlobal(Offset.zero);
  }

  @override
  void initState() {
    super.initState();
    oldOrientation = MediaQuery.of(widget.context).orientation;
    getDialogHeight(oldOrientation);
    getDialogWidth(oldOrientation);

    updateRenderBox();
    updateDialogPos(widget.context);

    isKeyboardVisibleNotifier.addListener(() {
      if (widget.pushDialogAboveWhenKeyboardShow &&
          !isKeyboardVisibleNotifier.value) {
        Future.delayed(Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              enableArrow = true;
            });
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomPositionDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    getDialogHeight(MediaQuery.of(widget.context).orientation);
    getDialogWidth(MediaQuery.of(widget.context).orientation);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      updateRenderBox();
      updateDialogPos(widget.context);
      setState(() {});
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void calculatePos(AlignTargetWidget alignment, BuildContext context) {
    PositionCalculator calculator = PositionCalculator(
      dialogSize: Size(dialogWidth, dialogHeight),
      targetWidgetSize: targetWidgetSize!,
      targetWidgetPos: targetWidgetPos!,
      context: context,
      distance: widget.distanceBetweenTargetWidget,
      arrowSize:
          enableArrow ? Size(widget.arrowWidth, widget.arrowHeight) : null,
    );

    switch (alignment) {
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

  void calculateArrowPos(AlignTargetWidget alignment, BuildContext context) {
    double screenPaddingTop =
        MediaQueryData.fromView(View.of(context)).padding.top;
    double leftPos = 0;
    double topPos = 0;
    if (alignment == AlignTargetWidget.left ||
        alignment == AlignTargetWidget.leftCenter) {
      leftPos = dialogPos.dx + dialogWidth;
      topPos = targetWidgetPos!.dy +
          (targetWidgetSize!.height / 2) -
          screenPaddingTop -
          (widget.arrowWidth / 2);
    } else if (alignment == AlignTargetWidget.right ||
        alignment == AlignTargetWidget.rightCenter) {
      leftPos = dialogPos.dx - widget.arrowHeight;
      topPos = targetWidgetPos!.dy +
          (targetWidgetSize!.height / 2) -
          (widget.arrowWidth / 2) -
          screenPaddingTop;
    } else if (alignment == AlignTargetWidget.topCenter) {
      leftPos = targetWidgetPos!.dx -
          (widget.arrowWidth / 2) +
          targetWidgetSize!.width / 2;
      topPos = dialogPos.dy + dialogHeight;
    } else {
      leftPos = targetWidgetPos!.dx -
          (widget.arrowWidth / 2) +
          targetWidgetSize!.width / 2;
      topPos = dialogPos.dy - widget.arrowHeight;
    }

    //hide arrow if overflow
    if (alignment != AlignTargetWidget.topCenter &&
        alignment != AlignTargetWidget.bottomCenter &&
        alignment != AlignTargetWidget.bottomLeft &&
        topPos + widget.arrowWidth > dialogPos.dy + dialogHeight) {
      enableArrow = false;
    }

    arrowPos = Offset(leftPos, topPos);
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

          double newDialogTop = dialogPos.dy + y;
          double newDialogLeft = dialogPos.dx + x;
          double newArrowLeft = arrowPos.dx + x;

          dialogPos = Offset(newDialogLeft, newDialogTop);
          arrowPos = Offset(newArrowLeft, arrowPos.dy);
        }

        break;

      case AlignTargetWidget.bottomLeft ||
            AlignTargetWidget.bottomCenter ||
            AlignTargetWidget.centerBottomRight ||
            AlignTargetWidget.topCenter:
        if (adjustment != Offset(0, 0)) {
          double y = widget.adjustment.dy;
          double x = widget.adjustment.dx;

          double newDialogTop = dialogPos.dy + y;
          double newDilogLeft = dialogPos.dx + x;
          double newArrowTop = arrowPos.dy + y;

          dialogPos = Offset(newDilogLeft, newDialogTop);
          arrowPos = Offset(arrowPos.dx, newArrowTop);
        }

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    // print('-------');
    // print('dialogPos: $dialogPos');

    return OrientationBuilder(builder: (context, orientation) {
      getDialogHeight(orientation);
      getDialogWidth(orientation);

      // print('dialogHeight: $dialogHeight, dialogWidth: $dialogWidth');

      //   print('dialog left pos: $dialogPos.dx, dialog top pos: $dialogPos.dy');

      if (oldOrientation != orientation) {
        updateDialogPos(context, forceCenter: true);
        // Future.delayed(Duration(milliseconds: 500), () {
        //   if (mounted) {
        //     setState(() {
        //       static = false;
        //       enableArrow = false;
        //     });
        //     updateDialogPos();
        //   }
        // });
      }
      oldOrientation = orientation;

      return KeyboardSizeProvider(
        child: SafeArea(
          child:
              Consumer<ScreenHeight>(builder: (context, screenHeight, child) {
            bool isKeyboardVisible = screenHeight.isOpen;
            double paddingWhenKeyboardShow = screenHeight.keyboardHeight;
            isKeyboardVisibleNotifier.value = isKeyboardVisible;
            return LayoutBuilder(builder: (context, constraints) {
              if (isKeyboardVisible) {
                double screenHeight = constraints.maxHeight;

                double newHeight = oriHeight -
                    (paddingWhenKeyboardShow -
                        (screenHeight - (oriHeight + dialogPos.dy)));

                if (widget.pushDialogAboveWhenKeyboardShow) {
                  newHeight = oriHeight -
                      (paddingWhenKeyboardShow -
                          (screenHeight - (oriHeight + 10)));
                  enableArrow = false;
                }
                if (widget.adjustSizeWhenKeyboardShow) {
                  if (newHeight <= dialogHeight) {
                    dialogHeight = newHeight > 0 ? newHeight - 5 : oriHeight;
                  }
                }
              } else {
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
                    curve: Curves.fastEaseInToSlowEaseOut,
                    top: isKeyboardVisible &&
                            widget.pushDialogAboveWhenKeyboardShow
                        ? 10
                        : dialogPos.dy,
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
                          borderRadius:
                              BorderRadius.circular(widget.borderRadius),
                        ),
                        child: AnimatedContainer(
                          duration: 50.ms,
                          clipBehavior: Clip.antiAlias,
                          padding: EdgeInsets.zero,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft:
                                    Radius.circular(widget.borderRadius),
                                bottomRight:
                                    Radius.circular(widget.borderRadius)),
                          ),
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
                  ),
                  Positioned(
                    top: arrowPos.dy,
                    left: arrowPos.dx,
                    child: !enableArrow
                        ? SizedBox.shrink()
                        : Animate(
                            effects: [
                              ScaleEffect(
                                  duration: Duration(milliseconds: 200),
                                  alignment: getArrowAnimationAlignment())
                            ],
                            child: PhysicalModel(
                              color: Colors.transparent,
                              elevation: 3,
                              shadowColor: Colors.grey.withOpacity(0.06),
                              shape: BoxShape.circle,
                              child: CustomPaint(
                                painter: _getArrowPainter(getArrowPointing()),
                                child: Container(
                                  width:
                                      getArrowPointing() == ArrowPointing.top ||
                                              getArrowPointing() ==
                                                  ArrowPointing.bottom
                                          ? widget.arrowWidth
                                          : widget.arrowHeight,
                                  height:
                                      getArrowPointing() == ArrowPointing.top ||
                                              getArrowPointing() ==
                                                  ArrowPointing.bottom
                                          ? widget.arrowHeight
                                          : widget.arrowWidth,
                                ),
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

  @override
  void dispose() {
    isKeyboardVisibleNotifier.dispose();
    super.dispose();
  }

  ArrowPointing getArrowPointing() {
    if (alignTargetWidget == AlignTargetWidget.left ||
        alignTargetWidget == AlignTargetWidget.leftCenter) {
      return ArrowPointing.right;
    } else if (alignTargetWidget == AlignTargetWidget.right ||
        alignTargetWidget == AlignTargetWidget.rightCenter) {
      return ArrowPointing.left;
    } else if (alignTargetWidget == AlignTargetWidget.bottomCenter ||
        alignTargetWidget == AlignTargetWidget.bottomLeft) {
      return ArrowPointing.top;
    } else if (alignTargetWidget == AlignTargetWidget.topCenter) {
      return ArrowPointing.bottom;
    } else {
      return ArrowPointing.right;
    }
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

  Alignment getArrowAnimationAlignment() {
    if (alignTargetWidget == AlignTargetWidget.left ||
        alignTargetWidget == AlignTargetWidget.leftCenter) {
      return Alignment.centerLeft;
    } else if (alignTargetWidget == AlignTargetWidget.right ||
        alignTargetWidget == AlignTargetWidget.rightCenter) {
      return Alignment.centerRight;
    } else if (alignTargetWidget == AlignTargetWidget.bottomCenter ||
        alignTargetWidget == AlignTargetWidget.bottomLeft) {
      return Alignment.bottomCenter;
    } else if (alignTargetWidget == AlignTargetWidget.topCenter) {
      return Alignment.topCenter;
    } else {
      return Alignment.centerRight;
    }
  }
}
