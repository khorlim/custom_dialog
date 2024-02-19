import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tunaipro/share_code/custom_dialog/custom_dialog.dart';
import 'package:tunaipro/share_code/custom_dialog/utils/custom_modal_bottom_sheet.dart';
import 'package:tunaipro/share_code/function/dialog_manager.dart';
import 'package:tunaipro/share_code/responsive/device_type.dart';
import 'package:tunaipro/theme/app_style.dart';

class CustomPageRoute<T> extends PopupRoute<T> {
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

  final Function? onTapOutside;

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
  final bool isPopupMenu;

  CustomPageRoute({
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
    this.isPopupMenu = false,
  });

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  Color get barrierColor => backgroundColor ?? black.withOpacity(0.2);

  @override
  String get barrierLabel => 'CustomPageRoute';

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

    Widget modalBottomSheet = SafeArea(
      bottom: false,
      child: CustomModalBottomSheet(
        enableDrag: false,
        route: this,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    double manaulDialogHeight = screenHeight * (heightRatio ?? 0.8);
    double manualDialogWidth = screenWidth * (widthRatio ?? 0.8);

    BuildContext? targetCtxt;
    if (targetWidgetContext != null && targetWidgetContext!.mounted) {
      targetCtxt = targetWidgetContext;
    }

    Widget dialog = OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.portrait) {
        manaulDialogHeight = screenHeight * (heightRatioInPortrait ?? 0.5);
        manualDialogWidth = screenWidth * (widthRatioInPortrait ?? 0.8);
      }
      return CustomDialog(
        context: context,
        distanceBetweenTargetWidget: distanceBetweenTargetWidget ?? 0,
        height: height ??
            ((heightRatio != null || isCenterDialog)
                ? manaulDialogHeight
                : null),
        width: width ??
            ((widthRatio != null || isCenterDialog) ? manualDialogWidth : null),
        alignTargetWidget: alignTargetWidget ?? AlignTargetWidget.right,
        enableArrow: enableArrow ?? true,
        targetWidgetContext: targetCtxt,
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
        child: builder(context),
      );
    });

    if (showModalBottom) {
      return modalBottomSheet;
    } else {
      return dialog;
    }
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    deviceType = getDeviceType(context);
    if (useSlideTransition) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.linearToEaseOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    } else if (isPopupMenu) {
      var sizeTween = Tween<double>(begin: 0.0, end: 1.0)
          .chain(CurveTween(curve: Curves.linearToEaseOut));
      var fadeTween = Tween<double>(begin: 0.3, end: 1.0)
          .chain(CurveTween(curve: Curves.linearToEaseOut));

      var closingSizeTween = Tween<double>(begin: 0.0, end: 1)
          .chain(CurveTween(curve: Curves.easeOutBack));

      RenderBox? renderBox =
          targetWidgetContext?.findRenderObject() as RenderBox?;
      Size size = renderBox?.size ?? Size.zero;
      Offset targetPosition =
          renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
      Offset centerPos = Offset(targetPosition.dx + (size.width / 2),
          targetPosition.dy + (size.height / 2));
      Size screenSize = MediaQuery.of(context).size;

      double fractionHorizontal = (2 * centerPos.dx / screenSize.width) - 1;
      double fractionVertical = (2 * centerPos.dy / screenSize.height) - 1;

      if (animation.status == AnimationStatus.reverse) {
        return ScaleTransition(
          alignment: Alignment(fractionHorizontal, fractionVertical),
          scale: animation.drive(closingSizeTween),
          child: child,
        );
      }

      return FadeTransition(
        opacity: animation.drive(fadeTween),
        child: ScaleTransition(
          alignment: Alignment(fractionHorizontal, fractionVertical),
          scale: animation.drive(sizeTween),
          child: child,
        ),
      );
    } else {
      final CurvedAnimation fadeAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      if (animation.status == AnimationStatus.reverse) {
        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      }
      return FadeTransition(
        opacity: fadeAnimation,
        child: ScaleTransition(
          scale: animation.drive(_dialogScaleTween),
          child: child,
        ),
      );
    }
  }

  final Animatable<double> _dialogScaleTween =
      Tween<double>(begin: 1.3, end: 1.0)
          .chain(CurveTween(curve: Curves.linearToEaseOut));

  @override
  bool get barrierDismissible => false;
}
