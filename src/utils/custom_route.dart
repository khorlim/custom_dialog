import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../custom_dialog.dart';
import '../custom_position_dialog.dart';
import 'custom_modal_bottom_sheet.dart';
import '../../dialog_manager/dialog_manager.dart';
import '../../../../tunai_style/responsive/device_type.dart';
import '../../../../tunai_style/old/theme/old_app_style.dart';

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

  final double? maxHeight;
  final double? maxWidth;

  final double borderRadius;

  final Widget? customDialogBuilder;
  final GlobalKey? targetWidgetKey;

  // Define tweens as static final to avoid recreation
  static final _sizeTween = Tween<double>(begin: 0.0, end: 1.0)
      .chain(CurveTween(curve: Curves.linearToEaseOut));
  static final _fadeTween = Tween<double>(begin: 0.3, end: 1.0)
      .chain(CurveTween(curve: Curves.linearToEaseOut));
  static final _closingFadeTween = Tween<double>(begin: 0, end: 1)
      .chain(CurveTween(curve: Curves.linearToEaseOut));
  static final _closingSizeTween = Tween<double>(begin: 0.0, end: 1)
      .chain(CurveTween(curve: Curves.easeOutBack));

  // Cache RenderBox calculations
  RenderBox? _cachedRenderBox;
  Size? _cachedSize;
  Offset? _cachedPosition;
  Alignment? _cachedAlignment;

  void _updateCachedValues(BuildContext context) {
    RenderBox? renderBox;
    if (targetWidgetKey != null &&
        targetWidgetKey?.currentContext != null &&
        targetWidgetKey!.currentContext!.mounted) {
      renderBox =
          targetWidgetKey?.currentContext?.findRenderObject() as RenderBox?;
    } else if (targetWidgetContext != null && targetWidgetContext!.mounted) {
      renderBox = targetWidgetContext?.findRenderObject() as RenderBox?;
    }

    if (renderBox != _cachedRenderBox) {
      _cachedRenderBox = renderBox;
      _cachedSize = renderBox?.size ?? Size.zero;
      _cachedPosition = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

      Size screenSize = MediaQuery.of(context).size;
      Offset centerPos = Offset(_cachedPosition!.dx + (_cachedSize!.width / 2),
          _cachedPosition!.dy + (_cachedSize!.height / 2));

      double fractionHorizontal = (2 * centerPos.dx / screenSize.width) - 1;
      double fractionVertical = (2 * centerPos.dy / screenSize.height) - 1;
      _cachedAlignment = Alignment(fractionHorizontal, fractionVertical);
    }
  }

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
    this.maxHeight,
    this.maxWidth,
    this.borderRadius = 10,
    this.customDialogBuilder,
    this.targetWidgetKey,
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

          if (targetWidgetKey != null) {
            return CustomPositionDialog(
              targetWidgetKey: targetWidgetKey!,
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
              child: builder(context),
            );
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
            targetWidgetContext: targetCtxt,
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
            child: builder(context),
            onDismiss: () {
              if (dismissible != null) {
                dismissible?.dispose();
              }
            },
          );
        });

    return DisplayFeatureSubScreen(
      child: showModalBottom ? modalBottomSheet : dialog,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    deviceType = getDeviceType(context);
    if (useSlideTransition) {
      return buildSlideTransition(
          context, animation, secondaryAnimation, child);
    } else if (isPopupMenu) {
      return buildPopupTransition(
          context, animation, secondaryAnimation, child);
    } else {
      return buildDialogTransition(
          context, animation, secondaryAnimation, child);
    }
  }

  Widget buildSlideTransition(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    const curve = Curves.linearToEaseOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }

  Widget buildPopupTransition(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    _updateCachedValues(context);

    if (animation.status == AnimationStatus.reverse) {
      return FadeTransition(
        opacity: animation.drive(_closingFadeTween),
        child: ScaleTransition(
          alignment: _cachedAlignment!,
          scale: animation.drive(_closingSizeTween),
          child: child,
        ),
      );
    }

    return FadeTransition(
      opacity: animation.drive(_fadeTween),
      child: ScaleTransition(
        alignment: _cachedAlignment!,
        scale: animation.drive(_sizeTween),
        child: child,
      ),
    );
  }

  Widget buildDialogTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    final CurvedAnimation fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    final Animatable<double> _dialogScaleTween =
        Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.linearToEaseOut));
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
  // Widget buildDialogTransition(
  //     BuildContext context,
  //     Animation<double> animation,
  //     Animation<double> secondaryAnimation,
  //     Widget child) {
  //   final CurvedAnimation fadeAnimation = CurvedAnimation(
  //     parent: animation,
  //     curve: Curves.fastLinearToSlowEaseIn,
  //   );
  //   final Animatable<double> scaleTween = Tween<double>(begin: 0.5, end: 1.0)
  //       .chain(CurveTween(curve: Curves.linearToEaseOut));
  //   final Animatable<double> closeScaleTween = Tween<double>(begin: 0.9, end: 1)
  //       .chain(CurveTween(curve: Curves.linearToEaseOut));
  //   final Animatable<Offset> slideTween = Tween<Offset>(
  //     begin: const Offset(0.0, 0.2),
  //     end: Offset.zero,
  //   ).chain(CurveTween(curve: Curves.linearToEaseOut));
  //   if (animation.status == AnimationStatus.reverse) {
  //     return FadeTransition(
  //       opacity: fadeAnimation,
  //       child: child,
  //     );
  //   }

  //   return SlideTransition(
  //     position: animation.drive(slideTween),
  //     child: FadeTransition(
  //       opacity: fadeAnimation,
  //       child: child,
  //     ),
  //   );
  // }

  @override
  bool get barrierDismissible => false;
}
