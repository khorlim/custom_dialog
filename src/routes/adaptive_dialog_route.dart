import 'package:flutter/material.dart';
import 'package:pos_dialog/pos_dialog.dart';
import '../custom_dialog.dart';
import '../../dialog_manager/dialog_manager.dart';
import '../../../../tunai_style/responsive/device_type.dart';

class AdaptiveDialogRoute<T> extends BaseAdaptivePosDialogRoute<T> {
  final WidgetBuilder builder;
  final DialogType dialogType;

  final double? width;
  final double? height;

  final double? heightRatio;
  final double? widthRatio;
  final double? heightRatioInPortrait;
  final double? widthRatioInPortrait;

  final AlignTargetWidget? alignTargetWidget;

  final bool? enableArrow;

  final double? arrowWidth;

  final double? arrowHeight;

  final BuildContext? targetWidgetContext;

  final void Function()? onTapOutside;

  final Offset? adjustment;

  final bool? showOverFlowArrow;

  final bool? jumpWhenOverflow;

  final double? overflowLeft;

  final double? bottomSheetHeight;

  final bool? pushDialogAboveWhenKeyboardShow;

  final bool? followArrow;

  final double? distanceBetweenTargetWidget;

  final bool keepDialogOnMobile;
  final ValueNotifier<bool>? dismissible;
  final Color? backgroundColor;

  final double? maxHeight;
  final double? maxWidth;

  final double borderRadius;

  final Widget? customDialogBuilder;
  final GlobalKey? targetWidgetKey;
  final bool enableDrag;

  final bool adjustSizeWhenKeyboardShow;

  AdaptiveDialogRoute({
    required this.builder,
    this.dialogType = DialogType.adaptivePosition,
    this.width,
    this.height,
    this.alignTargetWidget,
    this.enableArrow,
    this.arrowWidth,
    this.arrowHeight,
    this.targetWidgetContext,
    this.onTapOutside,
    this.adjustment,
    this.showOverFlowArrow,
    this.jumpWhenOverflow,
    this.overflowLeft,
    this.bottomSheetHeight,
    this.pushDialogAboveWhenKeyboardShow,
    this.followArrow,
    this.distanceBetweenTargetWidget,
    this.heightRatio,
    this.widthRatio,
    this.keepDialogOnMobile = false,
    this.heightRatioInPortrait,
    this.widthRatioInPortrait,
    this.dismissible,
    this.backgroundColor,
    this.maxHeight,
    this.maxWidth,
    this.borderRadius = 10,
    this.customDialogBuilder,
    this.targetWidgetKey,
    this.enableDrag = true,
    this.adjustSizeWhenKeyboardShow = true,
    super.duration = const Duration(milliseconds: 200),
  });

  @override
  Color get barrierColor =>
      backgroundColor ?? Colors.black.withValues(alpha: 0.2);

  @override
  String get barrierLabel => 'AdaptiveDialogRoute';

  @override
  bool get maintainState => true;

  bool get isCenterDialog =>
      dialogType == DialogType.center ||
      dialogType == DialogType.adaptiveCenter;

  late DeviceType deviceType;

  bool get useSlideTransition =>
      (deviceType == DeviceType.mobile ||
          dialogType == DialogType.adaptiveCenter) &&
      keepDialogOnMobile == false &&
      dialogType != DialogType.position;

  bool get showModalBottom =>
      deviceType == DeviceType.mobile &&
      keepDialogOnMobile == false &&
      dialogType != DialogType.position;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    deviceType = getDeviceType(context);

    if (showModalBottom) {
      return SafeArea(
        bottom: false,
        child: PosBottomSheet<T>(
          closeProgressThreshold: null,
          route: this,
          secondAnimationController: null,
          expanded: true,
          bounce: false,
          enableDrag: enableDrag,
          animationCurve: animationCurve,
          builder: (context) => ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: builder(context)),
        ),
      );
    }

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double manaulDialogHeight = screenHeight * (heightRatio ?? 0.8);
    double manualDialogWidth = screenWidth * (widthRatio ?? 0.8);

    BuildContext? targetCtxt;
    if (targetWidgetContext != null && targetWidgetContext!.mounted) {
      targetCtxt = targetWidgetContext;
    }

    Widget dialog = customDialogBuilder ??
        OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            manaulDialogHeight = screenHeight * (heightRatioInPortrait ?? 0.5);
            manualDialogWidth = screenWidth * (widthRatioInPortrait ?? 0.8);
          }

          if (maxHeight != null && manaulDialogHeight > maxHeight!) {
            //  debugPrint('using max height : $maxHeight');
            manaulDialogHeight = maxHeight!;
          }
          if (maxWidth != null && manualDialogWidth > maxWidth!) {
            // debugPrint('using max width : $maxWidth');
            manualDialogWidth = maxWidth!;
          }

          return CustomDialog(
            context: context,
            distanceBetweenTargetWidget: distanceBetweenTargetWidget ?? 0,
            height: height ??
                ((heightRatio != null || isCenterDialog)
                    ? manaulDialogHeight
                    : null),
            width: width ??
                ((widthRatio != null || isCenterDialog)
                    ? manualDialogWidth
                    : null),
            alignTargetWidget: alignTargetWidget ?? AlignTargetWidget.right,
            enableArrow: enableArrow ?? true,
            targetWidgetContext: targetWidgetKey?.currentContext ?? targetCtxt,
            borderRadius: borderRadius,
            onTapOutside: onTapOutside ??
                () {
                  if (dismissible == null || dismissible?.value == true) {
                    Navigator.pop(context);
                    return;
                  }
                },
            adjustment: adjustment ?? Offset.zero,
            showOverFlowArrow: showOverFlowArrow ?? true,
            overflowLeft: overflowLeft ?? 0,
            followArrow: followArrow ?? false,
            pushDialogAboveWhenKeyboardShow:
                pushDialogAboveWhenKeyboardShow ?? false,
            adjustSizeWhenKeyboardShow: adjustSizeWhenKeyboardShow,
            onDismiss: () {
              if (dismissible != null) {
                dismissible?.dispose();
              }
            },
            child: builder(context),
          );
        });

    return dialog;
  }

  @override
  Widget buildBottomSheet(BuildContext context) {
    // TODO: implement buildBottomSheet
    throw UnimplementedError();
  }

  @override
  Widget buildDialog(BuildContext context) {
    // TODO: implement buildDialog
    throw UnimplementedError();
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    deviceType = getDeviceType(context);
    if (useSlideTransition) {
      return buildSlideTransition(
          context, animation, secondaryAnimation, child);
    } else {
      return buildDialogTransition(
          context, animation, secondaryAnimation, child);
    }
  }

  Widget buildSlideTransition(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // Use a smoother curve combination for more natural movement
    const begin = Offset(0.0, 0.3); // Reduced distance for subtler effect
    const end = Offset.zero;
    const curve = Curves.easeOutCubic; // More natural deceleration

    // Add a fade effect to complement the slide
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve:
          Curves.easeOutQuart, // Slightly different curve for visual interest
    );

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    // Combine slide with fade and subtle scale for a polished effect
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: offsetAnimation,
        child: child,
      ),
    );
  }

  Widget buildDialogTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    // Use a combination of animations for a smoother effect
    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutQuart, // Smoother fade-in curve
      reverseCurve: Curves.easeInQuart, // Smooth fade-out for reverse
    );

    // Define scale tweens with more natural values
    final forwardScaleTween = Tween<double>(begin: 0.95, end: 1.0)
        .chain(CurveTween(curve: Curves.easeOutCubic));

    final reverseScaleTween = Tween<double>(begin: 0.9, end: 1.0)
        .chain(CurveTween(curve: Curves.easeInOutCubic));

    // Add a subtle slide effect for position dialogs
    final slideTween = Tween<Offset>(
      begin: const Offset(0.0, -0.05),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic));

    if (animation.status == AnimationStatus.reverse) {
      // Reverse animation (closing dialog)
      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: animation.drive(reverseScaleTween),
          child: child,
        ),
      );
    }

    // Forward animation (opening dialog)
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: animation.drive(slideTween),
        child: ScaleTransition(
          scale: animation.drive(forwardScaleTween),
          child: child,
        ),
      ),
    );
  }

  @override
  bool get barrierDismissible => false;
}
