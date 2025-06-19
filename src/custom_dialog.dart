import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../tunai_style/extension/build_context_extension.dart';
import 'utils/position_calculator.dart';
import '../../dump/keyboard_size_provider/keyboard_size_provider.dart';
import 'triangle.dart';

part 'enum.dart';

class CustomDialog extends StatefulWidget {
  final BuildContext context;
  final double? height;
  final double? width;
  final Widget child;
  final BuildContext? targetWidgetContext;
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
  final GlobalKey? targetWidgetKey;
  final void Function()? onDismiss;
  final bool hasShadow;

  CustomDialog({
    super.key,
    required this.context,
    required this.child,
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
    this.overflowLeft = 0,
    this.pushDialogAboveWhenKeyboardShow = false,
    this.followArrow = false,
    this.distanceBetweenTargetWidget = 0,
    this.adjustSizeWhenKeyboardShow = true,
    this.static = true,
    this.borderRadius = 10,
    this.targetWidgetKey,
    this.onDismiss,
    this.hasShadow = false,
  }) {
    safeAreaTopHeight = MediaQueryData.fromView(View.of(context)).padding.top;
  }

  late final double safeAreaTopHeight;

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
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

  bool? isDismissible;

  late Orientation oldOrientation;

  // Consider memoizing position calculations
  final _positionCache = <String, Offset>{};

  void updateDialogPos(BuildContext context, {bool forceCenter = false}) {
    if (targetWidgetRBox != null && !forceCenter) {
      calculatePos(alignTargetWidget, context);
      calculateArrowPos(alignTargetWidget, context);
    } else {
      //Default position (center)
      enableArrow = false;
      double middleTopPos =
          (screenHeight / 2) - (dialogHeight / 2) - widget.safeAreaTopHeight;
      double middleLeftPos = (screenWidth / 2) - (dialogWidth / 2);
      dialogPos = Offset(middleLeftPos, middleTopPos);
    }
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
    try {
      if (widget.targetWidgetContext != null &&
          widget.targetWidgetContext!.mounted) {
        final renderObject = widget.targetWidgetContext?.findRenderObject();

        // Check if the render object is a RenderBox and has been laid out
        if (renderObject is RenderBox && renderObject.hasSize) {
          updateRenderObj(renderObject);
        } else {
          // Schedule a post-frame callback to try again after layout
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final renderObject =
                  widget.targetWidgetContext?.findRenderObject();
              updateRenderObj(renderObject as RenderBox);
              updateDialogPos(widget.context);
              setState(() {});
            }
          });
        }
      } else {
        targetWidgetRBox = null;
        targetWidgetSize = null;
        targetWidgetPos = null;
      }
    } catch (e) {
      debugPrint('Error in updateRenderBox: $e');
      targetWidgetRBox = null;
      targetWidgetSize = null;
      targetWidgetPos = null;
    }
  }

  void updateRenderObj(RenderObject renderObject) {
    targetWidgetRBox = renderObject as RenderBox;
    targetWidgetSize = targetWidgetRBox?.size;
    targetWidgetPos = targetWidgetRBox?.localToGlobal(Offset.zero);
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
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            setState(() {
              enableArrow = widget.targetWidgetContext != null ? true : false;
            });
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant CustomDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.height != oldWidget.height || widget.width != oldWidget.width) {
      final mediaQuery = MediaQuery.of(widget.context);
      getDialogHeight(mediaQuery.orientation);
      getDialogWidth(mediaQuery.orientation);

      updateRenderBox();
      updateDialogPos(widget.context);
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void calculatePos(AlignTargetWidget alignment, BuildContext context) {
    // Create a cache key based on relevant parameters
    final cacheKey =
        '$alignment-$dialogWidth-$dialogHeight-${targetWidgetPos?.toString()}';

    // Check if we already calculated this position
    if (_positionCache.containsKey(cacheKey)) {
      dialogPos = _positionCache[cacheKey]!;
      return;
    }

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

        if (calculator.isExceedLeft(dialogPos.dx)) {
          alignTargetWidget = AlignTargetWidget.right;
          dialogPos = calculator.getAlignRight();
        }

        break;

      case AlignTargetWidget.left || AlignTargetWidget.leftCenter:
        dialogPos = calculator.getAlignLeft();

        if (calculator.isExceedLeft(dialogPos.dx)) {
          alignTargetWidget = AlignTargetWidget.right;
          dialogPos = calculator.getAlignRight();
        }

        if (calculator.isExceedRight(dialogPos.dx)) {
          alignTargetWidget = AlignTargetWidget.left;
          dialogPos = calculator.getAlignLeft();
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

    // Cache the result
    _positionCache[cacheKey] = dialogPos;
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
        if (adjustment != const Offset(0, 0)) {
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
        if (adjustment != const Offset(0, 0)) {
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
    final mediaQuery = MediaQuery.of(context);
    screenHeight = mediaQuery.size.height;
    screenWidth = mediaQuery.size.width;

    // print('-------');
    // print('dialogPos: $dialogPos');

    return DialogDismissible(
      onUpdate: (isDismissible) {
        this.isDismissible = isDismissible;
        print('Custom dialog dismissible updated: $isDismissible');
      },
      child: OrientationBuilder(
        builder: (context, orientation) {
          // print('dialogHeight: $dialogHeight, dialogWidth: $dialogWidth');

          //   print('dialog left pos: $dialogPos.dx, dialog top pos: $dialogPos.dy');

          if (oldOrientation != orientation) {
            getDialogHeight(orientation);
            getDialogWidth(orientation);
            updateDialogPos(context, forceCenter: true);
          }
          oldOrientation = orientation;

          return KeyboardSizeProvider(
            child: SafeArea(
              child: Consumer<ScreenHeight>(
                builder: (context, screenHeight, child) {
                  bool isKeyboardVisible = screenHeight.isOpen;
                  double paddingWhenKeyboardShow = screenHeight.keyboardHeight;
                  isKeyboardVisibleNotifier.value = isKeyboardVisible;
                  return LayoutBuilder(
                    builder: (context, constraints) {
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
                            dialogHeight =
                                newHeight > 0 ? newHeight - 5 : oriHeight;
                          }
                        }
                      } else {
                        dialogHeight = oriHeight;
                      }
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isDismissible != null) {
                                if (isDismissible!) {
                                  Navigator.of(context, rootNavigator: true)
                                      .pop();
                                }
                                return;
                              }
                              if (widget.onTapOutside != null) {
                                widget.onTapOutside?.call();
                                return;
                              }
                              Navigator.pop(context);
                            },
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 0),
                            curve: Curves.easeOut,
                            top: isKeyboardVisible &&
                                    widget.pushDialogAboveWhenKeyboardShow
                                ? 10
                                : dialogPos.dy,
                            left: dialogPos.dx,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              height: dialogHeight,
                              width: dialogWidth,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                color: context.colorScheme.surface,
                                borderRadius: BorderRadius.only(
                                  bottomLeft:
                                      Radius.circular(widget.borderRadius),
                                  bottomRight:
                                      Radius.circular(widget.borderRadius),
                                  topLeft: Radius.circular(widget.borderRadius),
                                  topRight:
                                      Radius.circular(widget.borderRadius),
                                ),
                                boxShadow: [
                                  if (widget.hasShadow)
                                    BoxShadow(
                                      color:
                                          Colors.grey.withValues(alpha: 0.08),
                                      spreadRadius: 3,
                                      blurRadius: 5,
                                      offset: const Offset(0, 0),
                                    ),
                                ],
                              ),
                              child: widget.child,
                            ),
                          ),
                          Positioned(
                            top: arrowPos.dy,
                            left: arrowPos.dx,
                            child: !enableArrow
                                ? const SizedBox.shrink()
                                : Animate(
                                    effects: [
                                      ScaleEffect(
                                          duration:
                                              const Duration(milliseconds: 200),
                                          alignment:
                                              getArrowAnimationAlignment())
                                    ],
                                    child: PhysicalModel(
                                      color: Colors.transparent,
                                      elevation: 3,
                                      shadowColor:
                                          Colors.grey.withValues(alpha: 0.06),
                                      shape: BoxShape.circle,
                                      child: CustomPaint(
                                        painter: _getArrowPainter(
                                            getArrowPointing()),
                                        child: SizedBox(
                                          width: getArrowPointing() ==
                                                      ArrowPointing.top ||
                                                  getArrowPointing() ==
                                                      ArrowPointing.bottom
                                              ? widget.arrowWidth
                                              : widget.arrowHeight,
                                          height: getArrowPointing() ==
                                                      ArrowPointing.top ||
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
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    isKeyboardVisibleNotifier.dispose();
    widget.onDismiss?.call();
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

class DialogDismissible extends InheritedWidget {
  final void Function(bool isDismissible) onUpdate;
  const DialogDismissible({
    super.key,
    required this.onUpdate,
    required super.child,
  });

  static DialogDismissible? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DialogDismissible>();
  }

  void update(bool isDismissible) {
    onUpdate(isDismissible);
  }

  @override
  bool updateShouldNotify(DialogDismissible oldWidget) {
    return false;
  }
}
