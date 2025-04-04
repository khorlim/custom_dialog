import 'package:flutter/material.dart';

import '../src/custom_dialog.dart';
import 'dialog_manager.dart';

mixin ShowDialogMixin on Widget {
  Future<T?> showDialog<T>({
    BuildContext? context,
    BuildContext? targetWidgetContext,
    ValueNotifier<bool>? dismissible,
    GlobalKey<State<StatefulWidget>>? targetWidgetKey,
    DialogType dialogType = DialogType.adaptivePosition,
    DialogShape dialogShape = DialogShape.slimRectangle,
    AlignTargetWidget? alignTargetWidget,
  }) {
    return DialogManager(
      child: this,
      dialogType: dialogType,
      dialogShape: dialogShape,
      context: context,
      targetWidgetContext: targetWidgetContext,
      dismissible: dismissible,
      targetWidgetKey: targetWidgetKey,
      alignTargetWidget: alignTargetWidget,
    ).show<T>();
  }
}
