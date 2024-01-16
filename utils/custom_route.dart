import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tunaipro/share_code/custom_dialog/custom_dialog.dart';
import 'package:tunaipro/share_code/custom_dialog/utils/custom_modal_bottom_sheet.dart';
import 'package:tunaipro/share_code/function/dialog_manager.dart';
import 'package:tunaipro/share_code/responsive/device_type.dart';

class CustomPageRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final DialogType dialogType;

  final double? width;
  final double? height;

  final double? heightRatio;
  final double? widthRatio;

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
  });

  @override
  Color get barrierColor => Colors.black.withOpacity(0.2);

  @override
  String get barrierLabel => 'CustomPageRoute';

  @override
  bool get maintainState => true;

  bool get isCenterDialog =>
      dialogType == DialogType.center ||
      dialogType == DialogType.adaptiveCenter;

  late DeviceType deviceType;

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

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

    double manaulDialogHeight =
        MediaQuery.of(context).size.height * (heightRatio ?? 0.8);
    double manualDialogWidth =
        MediaQuery.of(context).size.width * (widthRatio ?? 0.8);

    BuildContext? targetCtxt;
    if (targetWidgetContext != null && targetWidgetContext!.mounted) {
      targetCtxt = targetWidgetContext;
    }

    Widget dialog = CustomDialog(
      context: context,
      height: height ?? (isCenterDialog ? manaulDialogHeight : null),
      width: width ?? (isCenterDialog ? manualDialogWidth : null),
      alignTargetWidget: alignTargetWidget ?? AlignTargetWidget.right,
      enableArrow: enableArrow ?? true,
      targetWidgetContext: targetCtxt,
      onTapOutside: onTapOutside,
      adjustment: adjustment ?? Offset.zero,
      showOverFlowArrow: showOverFlowArrow ?? true,
      overflowLeft: overflowLeft ?? 0,
      followArrow: followArrow ?? false,
      pushDialogAboveWhenKeyboardShow: pushDialogAboveWhenKeyboardShow ?? false,
      child: builder(context),
    );

    return deviceType == DeviceType.mobile ? modalBottomSheet : dialog;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    deviceType = getDeviceType(context);
    if (deviceType == DeviceType.mobile || isCenterDialog) {
      const begin = Offset(0.0, 1.0);
      const end = Offset.zero;
      const curve = Curves.easeInOut;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
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
