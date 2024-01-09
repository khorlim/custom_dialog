// import 'package:flutter/material.dart';
// import 'package:tunaipro/share_code/responsive/device_type.dart';

// class CustomRoute<T> extends MaterialPageRoute<T> {
//   final DeviceType deviceType;

//   CustomRoute({
//     required WidgetBuilder builder,
//     required RouteSettings settings,
//     required this.deviceType,
//   }) : super(builder: builder, settings: settings);

//   @override
//   Widget buildTransitions(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation, Widget child) {
//     if (deviceType == DeviceType.mobile) {
//       // Use DialogRoute for phones
//       return DialogRoute<T>(
//     context: context,
//     builder: builder,
//     barrierColor: barrierColor ?? Colors.black54,
//     barrierDismissible: barrierDismissible,
//     barrierLabel: barrierLabel,
//     useSafeArea: useSafeArea,
//     settings: routeSettings,
//     themes: themes,
//     anchorPoint: anchorPoint,
//     traversalEdgeBehavior: traversalEdgeBehavior ?? TraversalEdgeBehavior.closedLoop,
//   )
//     } else {
//       // Use ModalBottomSheetRoute for tablets
//       return new FadeTransition(opacity: animation, child: child);
//     }
//   }
// }
