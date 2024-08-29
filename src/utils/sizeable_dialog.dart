import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../custom_dialog.dart';
import 'custom_route.dart';

Future<T?> showSizeableDialog<T>({
  required BuildContext context,
  required Widget child,
}) {
  return Navigator.push(
    context,
    CustomPageRoute(
        isPopupMenu: true,
        targetWidgetContext: context,
        builder: (context) => SizedBox.shrink(),
        customDialogBuilder: CheckSizeBuilder(
            child: child,
            builder: (context, size) {
              print('size from check size builder : $size');
              return CustomDialog(
                context: context,
                height: size!.height,
                width: size!.width,
                child: child,
              );
            })),
  );
}

class CheckSizeBuilder extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Size? size) builder;
  const CheckSizeBuilder({
    super.key,
    required this.child,
    required this.builder,
  });

  @override
  State<CheckSizeBuilder> createState() => _CheckSizeBuilderState();
}

class _CheckSizeBuilderState extends State<CheckSizeBuilder> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      // opacity: 0,
      child: Stack(
        fit: StackFit.loose,
        children: [
          Builder(
              key: widgetKey,
              builder: (context) {
                return widget.child;
              }),
        ],
      ),
    );
  }

  var widgetKey = GlobalKey();
  Size? oldSize;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;

    var newSize = renderBox!.size;
    if (oldSize == newSize) return;

    oldSize = newSize;
    widget.builder(context, newSize);
  }
}
