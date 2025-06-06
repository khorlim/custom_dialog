import 'package:flutter/material.dart';
import '../../../core_utils/tunai_navigator/tunai_navigator.dart';
import '../src/custom_dialog.dart';
import '../src/routes/adaptive_dialog_route.dart';
import '../../../tunai_style/responsive/device_type.dart';

/*
  DialogManager: A class for managing and displaying dialogs.
  Example Usage:
  
  ? Example 1: Show a basic dialog
  DialogManager(
    context: context,
    child: YourDialogContentWidget(),
  ).show();

  ? Example 2: Show a dialog with an app bar and custom width
  DialogManager(
    context: context,
    child: YourDialogContentWidget(),
    appBar: YourAppBarWidget(),
    width: 500,
  ).show();

  ? Example 3: Show a dialog with arrow pointing to a target widget
  DialogManager(
    context: context,
    child: YourDialogContentWidget(),
    alignTargetWidget: AlignTargetWidget.right,
    enableArrow: true,
    arrowWidth: 30,
    arrowHeight: 15,
    targetWidgetContext: yourTargetWidgetContext,
  ).show();
*/

enum DialogType {
  center,
  position,
  modalBottomSheet,
  adaptivePosition,
  adaptiveCenter,
  ;

  bool get isPosition =>
      this == DialogType.position || this == DialogType.adaptivePosition;
}

enum DialogShape {
  slimRectangle,
  regularRectangle,
  fatRectangle,
  obesityRectangle,
  expandedRectangle;

  Size getLandscapeRatioSize() {
    switch (this) {
      case DialogShape.slimRectangle:
        return const Size(0.36, 0.82);
      case DialogShape.regularRectangle:
        return const Size(0.43, 0.82);
      case DialogShape.fatRectangle:
        return const Size(0.5, 0.82);
      case DialogShape.obesityRectangle:
        return const Size(0.63, 0.82);
      case DialogShape.expandedRectangle:
        return const Size(0.8, 0.82);
    }
  }

  Size getPortraitRatioSize() {
    switch (this) {
      case DialogShape.slimRectangle:
        return const Size(0.55, 0.6);
      case DialogShape.regularRectangle:
        return const Size(0.65, 0.6);
      case DialogShape.fatRectangle:
        return const Size(0.7, 0.6);
      case DialogShape.obesityRectangle:
        return const Size(0.75, 0.6);
      case DialogShape.expandedRectangle:
        return const Size(0.9, 0.7);
    }
  }

  Size getMaxSize() {
    switch (this) {
      case DialogShape.slimRectangle:
        return const Size(430, 650);
      case DialogShape.regularRectangle:
        return const Size(520, 650);
      case DialogShape.fatRectangle:
        return const Size(600, 650);
      case DialogShape.obesityRectangle:
        return const Size(800, 650);
      case DialogShape.expandedRectangle:
        return const Size(1500, 800);
    }
  }
}

class DialogManager {
  // Context in which the dialog is displayed
  final BuildContext? context;

  final DialogType dialogType;

  final DialogShape dialogShape;

  // final double? heightRatio;
  // final double? widthRatio;
  // final double? heightRatioInPortrait;
  // final double? widthRatioInPortrait;

  // Widget to be displayed inside the dialog
  final Widget child;

  // Optional app bar widget for the dialog
  final Widget? appBar;

  // Width of the dialog
  final double? width;

  // Height of the dialog
  final double? height;

  // Alignment target widget for positioning the dialog
  final AlignTargetWidget? alignTargetWidget;

  // Option to enable arrow pointing to the target widget
  final bool? enableArrow;

  // Width of the arrow
  final double? arrowWidth;

  // Height of the arrow
  final double? arrowHeight;

  // Context of the target widget
  final BuildContext? targetWidgetContext;

  // Callback function triggered when tapping outside the dialog
  final void Function()? onTapOutside;

  // Offset adjustment for fine-tuning the dialog position
  final Offset? adjustment;

  // Option to show overflow arrow when content overflows
  final bool? showOverFlowArrow;

  // Left offset for overflow arrow
  final double? overflowLeft;

  final double? bottomSheetHeight;

  /// Option to push the dialog above when the keyboard is displayed
  ///
  final bool? pushDialogAboveWhenKeyboardShow;

  // Option to make the dialog follow the arrow's direction
  final bool? followArrow;

  // Distance between the target widget and the dialog
  final double? distanceBetweenTargetWidget;

  // Variable to store the device type based on the context
  final DeviceType deviceType;

  //Keep dialog size when on mobile view
  final bool keepDialogOnMobile;

  final ValueNotifier<bool>? dismissible;

  final GlobalKey? targetWidgetKey;

  final bool enableDrag;

  final bool adjustSizeWhenKeyboardShow;

  // Constructor with required parameters and optional parameters with default values
  DialogManager({
    this.context,
    required this.child,
    this.appBar,
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
    this.overflowLeft,
    this.pushDialogAboveWhenKeyboardShow,
    this.followArrow,
    this.distanceBetweenTargetWidget,
    this.bottomSheetHeight,
    this.dialogType = DialogType.adaptivePosition,
    this.keepDialogOnMobile = false,
    this.dialogShape = DialogShape.slimRectangle,
    this.dismissible,
    this.targetWidgetKey,
    this.enableDrag = true,
    this.adjustSizeWhenKeyboardShow = true,
  }) : deviceType = getDeviceType(context ?? TunaiNavigator.currentContext);

  final pageIndexNotifier = ValueNotifier(0);

  // Function to show the dialog based on the device type
  Future<T?> show<T>() async {
    Size landscapeRatioSize = dialogShape.getLandscapeRatioSize();
    Size portraitRatioSize = dialogShape.getPortraitRatioSize();
    Size maxSize = dialogShape.getMaxSize();
    final GlobalKey contentBuilderKey = GlobalKey();
    return Navigator.push(
        TunaiNavigator.currentContext,
        AdaptiveDialogRoute(
          builder: (context) => Builder(
            key: contentBuilderKey,
            builder: (context) {
              return child;
            },
          ),
          adjustSizeWhenKeyboardShow: adjustSizeWhenKeyboardShow,
          enableDrag: enableDrag,
          dialogType: dialogType,
          width: width,
          height: height,
          alignTargetWidget: alignTargetWidget,
          enableArrow: enableArrow,
          arrowWidth: arrowWidth,
          arrowHeight: arrowHeight,
          targetWidgetContext: targetWidgetContext,
          onTapOutside: onTapOutside,
          adjustment: adjustment,
          showOverFlowArrow: showOverFlowArrow,
          overflowLeft: overflowLeft,
          bottomSheetHeight: bottomSheetHeight,
          pushDialogAboveWhenKeyboardShow: pushDialogAboveWhenKeyboardShow,
          followArrow: followArrow,
          distanceBetweenTargetWidget: distanceBetweenTargetWidget,
          keepDialogOnMobile: keepDialogOnMobile,
          dismissible: dismissible,
          heightRatio: landscapeRatioSize.height,
          widthRatio: landscapeRatioSize.width,
          heightRatioInPortrait: portraitRatioSize.height,
          widthRatioInPortrait: portraitRatioSize.width,
          maxHeight: maxSize.height,
          maxWidth: maxSize.width,
          targetWidgetKey: targetWidgetKey,
        ));

    // if (dialogType == DialogType.modalBottomSheet) {
    //   return showModalSheet();
    // }

    // // Check if the device is not a mobile device
    // if (deviceType != DeviceType.mobile) {
    //   // Show adaptive dialog for non-mobile devices
    //   if (dialogType == DialogType.adaptivePosition) {
    //     return showPositionDialog();
    //   } else {
    //     return showGeneralDialog(
    //       barrierLabel: "Barrier", // Used for semantics
    //       barrierDismissible: true,
    //       barrierColor: black.withValues(alpha: 0.2), // Background color
    //       transitionDuration: const Duration(milliseconds: 300),
    //       context: context,
    //       pageBuilder: (context, __, ___) {
    //         double dialogHeight = MediaQuery.of(context).size.height * 0.8;
    //         double dialogWidth = MediaQuery.of(context).size.width * 0.8;
    //         return CustomDialog(
    //             context: context,
    //             pushDialogAboveWhenKeyboardShow:
    //                 pushDialogAboveWhenKeyboardShow ?? false,
    //             height: height ?? dialogHeight,
    //             width: width ?? dialogWidth,
    //             child: child);
    //       },
    //       transitionBuilder: (_, anim, __, child) {
    //         return SlideTransition(
    //           position: Tween<Offset>(
    //             begin: const Offset(0, 1), // Start from the bottom
    //             end: Offset.zero, // End at the center
    //           ).animate(
    //             CurvedAnimation(
    //               parent: anim,
    //               curve: Curves.easeOut,
    //             ),
    //           ),
    //           child: child,
    //         );
    //       },
    //     );
    //   }
    // } else {
    //   return showModalSheet();
    // }
  }

  // Future<T?> showPositionDialog<T>() {
  //   return showAdaptiveDialog<T>(
  //     context: context,
  //     barrierColor: black.withValues(alpha: 0.2),
  //     builder: (_) {
  //       return CustomDialog(
  //         context: context,
  //         width: width,
  //         height: height,
  //         alignTargetWidget: alignTargetWidget ?? AlignTargetWidget.right,
  //         enableArrow: enableArrow ?? false,
  //         arrowWidth: arrowWidth ?? 30,
  //         arrowHeight: arrowHeight ?? 15,
  //         targetWidgetContext: targetWidgetContext,
  //         onTapOutside: onTapOutside,
  //         adjustment: adjustment ?? const Offset(0, 0),
  //         showOverFlowArrow: showOverFlowArrow ?? true,
  //         overflowLeft: overflowLeft ?? 0,
  //         pushDialogAboveWhenKeyboardShow:
  //             pushDialogAboveWhenKeyboardShow ?? false,
  //         followArrow: followArrow ?? false,
  //         distanceBetweenTargetWidget: distanceBetweenTargetWidget ?? 0,
  //         child: child,
  //       );
  //     },
  //   );
  // }

  // Future<T?> showCustomBottomSheet<T>() {
  //   return showGeneralDialog<T>(
  //     context: context,
  //     barrierDismissible: false,
  //     barrierLabel: '',
  //     transitionDuration: const Duration(milliseconds: 300),
  //     pageBuilder: (_, Animation<double> anim1, Animation<double> anim2) {
  //       return SafeArea(
  //         bottom: false,
  //         child: child,
  //       );
  //     },
  //     transitionBuilder: (BuildContext context, Animation<double> anim1,
  //         Animation<double> anim2, Widget child) {
  //       return SlideTransition(
  //         position: Tween<Offset>(
  //           begin: const Offset(0, 1),
  //           end: Offset.zero,
  //         ).animate(anim1),
  //         child: child,
  //       );
  //     },
  //   );
  // }

  // Future<T?> showModalSheet<T>() {
  //   return showModalBottomSheet(
  //     context: context,
  //     useSafeArea: true,
  //     clipBehavior: Clip.antiAlias,
  //     isScrollControlled: true,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(20),
  //         topRight: Radius.circular(20),
  //       ),
  //     ),
  //     builder: (context) {
  //       return SizedBox(height: bottomSheetHeight, child: child);
  //     },
  //   );
  // }

  // Future<T?> showWoltSheet<T>() {
  //  return WoltModalSheet.show<T?>(
  //     pageIndexNotifier: pageIndexNotifier,
  //     context: context,
  //     useSafeArea: true,
  //     showDragHandle: false,
  //     pageListBuilder: (modalSheetContext) {
  //       // final textTheme = Theme.of(context).textTheme;
  //       return [
  //         WoltModalSheetPage(
  //           isTopBarLayerAlwaysVisible: false,
  //           hasTopBarLayer: false,
  //           enableDrag: false,
  //           backgroundColor: Colors.white,
  //           // trailingNavBarWidget: IconButton(
  //           //   padding: const EdgeInsets.all(_pagePadding),
  //           //   icon: const Icon(Icons.close),
  //           //   onPressed: Navigator.of(modalSheetContext).pop,
  //           // ),
  //           child: LayoutBuilder(builder: (context, constraints) {
  //             Size screen = MediaQuery.of(context).size;
  //             double topPadding = MediaQuery.of(context).padding.top;
  //             double btmSheetHeight = screen.height - topPadding;
  //             return SizedBox(
  //                 height:
  //                     deviceType == DeviceType.mobile ? btmSheetHeight : height,
  //                 width: deviceType == DeviceType.mobile ? null : width,
  //                 child: child);
  //           }),
  //         ),
  //       ];
  //     },
  //     modalTypeBuilder: (context) {
  //       if (deviceType == DeviceType.mobile) {
  //         return WoltModalType.bottomSheet;
  //       } else {
  //         return WoltModalType.dialog;
  //       }
  //     },
  //     onModalDismissedWithBarrierTap: () {
  //       debugPrint('Closed modal sheet with barrier tap');
  //       Navigator.of(context).pop();
  //       //  pageIndexNotifier.value = 0;
  //     },
  //     // maxDialogWidth: 560,
  //     // minDialogWidth: 400,
  //     // minPageHeight: 0.5,
  //     maxPageHeight: 1,
  //   );
  // }
}
