import 'package:flutter/material.dart';
import '../custom_dialog.dart';
import '../../dialog_manager/dialog_manager.dart';

class PopupMenuRoute<T> extends PopupRoute<T> {
  final WidgetBuilder builder;
  final DialogType dialogType;

  final double? width;
  final double? height;

  final AlignTargetWidget? alignTargetWidget;

  final BuildContext targetWidgetContext;

  final double borderRadius;
  final GlobalKey? targetWidgetKey;

  static final _sizeTween = Tween<double>(begin: 0.0, end: 1.0)
      .chain(CurveTween(curve: Curves.linearToEaseOut));
  static final _fadeTween = Tween<double>(begin: 0.3, end: 1.0)
      .chain(CurveTween(curve: Curves.linearToEaseOut));
  static final _closingFadeTween = Tween<double>(begin: 0, end: 1)
      .chain(CurveTween(curve: Curves.linearToEaseOut));
  static final _closingSizeTween = Tween<double>(begin: 0.0, end: 1)
      .chain(CurveTween(curve: Curves.easeOutBack));

  PopupMenuRoute({
    required this.builder,
    this.dialogType = DialogType.adaptivePosition,
    this.width,
    this.height,
    this.alignTargetWidget,
    required this.targetWidgetContext,
    this.borderRadius = 10,
    this.targetWidgetKey,
  });

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  @override
  Color get barrierColor => Colors.black.withValues(alpha: 0.1);

  @override
  String get barrierLabel => 'PopupMenuRoute';

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    BuildContext targetCtxt = _getTargetContext();

    return CustomDialog(
      context: context,
      height: height,
      width: width,
      alignTargetWidget: alignTargetWidget ?? AlignTargetWidget.right,
      targetWidgetContext: targetCtxt,
      borderRadius: borderRadius,
      onTapOutside: () {
        Navigator.pop(context);
      },
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    RenderBox? renderBox = _getRenderBox();

    final size = renderBox?.size ?? Size.zero;
    final position = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

    Size screenSize = MediaQuery.of(context).size;
    Offset centerPos =
        Offset(position.dx + (size.width / 2), position.dy + (size.height / 2));

    double fractionHorizontal = (2 * centerPos.dx / screenSize.width) - 1;
    double fractionVertical = (2 * centerPos.dy / screenSize.height) - 1;
    final alignment = Alignment(fractionHorizontal, fractionVertical);

    if (animation.status == AnimationStatus.reverse) {
      return FadeTransition(
        opacity: animation.drive(_closingFadeTween),
        child: ScaleTransition(
          alignment: alignment,
          scale: animation.drive(_closingSizeTween),
          child: child,
        ),
      );
    }

    return FadeTransition(
      opacity: animation.drive(_fadeTween),
      child: ScaleTransition(
        alignment: alignment,
        scale: animation.drive(_sizeTween),
        child: child,
      ),
    );
  }

  BuildContext _getTargetContext() {
    if (targetWidgetKey != null &&
        (targetWidgetKey?.currentContext?.mounted ?? false)) {
      return targetWidgetKey!.currentContext!;
    }

    return targetWidgetContext;
  }

  RenderBox? _getRenderBox() {
    BuildContext targetCtxt = _getTargetContext();

    if (!targetCtxt.mounted) return null;

    return targetCtxt.findRenderObject() as RenderBox?;
  }

  @override
  bool get barrierDismissible => false;
}
