import 'package:tunaipro/general_module/order_module/import_path.dart';

class PositionCalculator {
  final BuildContext context;
  final Size dialogSize;
  final Size targetWidgetSize;
  final Offset targetWidgetPos;
  final double distance;
  final Size? arrowSize;

  PositionCalculator({
    required this.context,
    required this.dialogSize,
    required this.targetWidgetSize,
    required this.targetWidgetPos,
    required this.arrowSize,
    this.distance = 0,
  });
  Size get _tscreenSize => MediaQueryData.fromView(View.of(context)).size;
  double get _paddingTop =>
      MediaQueryData.fromView(View.of(context)).padding.top;
  double get _paddingBottom =>
      MediaQueryData.fromView(View.of(context)).padding.bottom;
  late Size _screenSize = Size(
      _tscreenSize.width, _tscreenSize.height - _paddingTop - _paddingBottom);

  late final LeftPosCalcualor leftPosCalcualor = LeftPosCalcualor(
    dialogSize: dialogSize,
    targetWidgetSize: targetWidgetSize,
    targetWidgetPos: targetWidgetPos,
    screenSize: _screenSize,
    distance: distance,
    arrowSize: arrowSize,
  );

  late final TopPosCalculator topPosCalcualor = TopPosCalculator(
    dialogSize: dialogSize,
    targetWidgetSize: targetWidgetSize,
    targetWidgetPos: targetWidgetPos,
    screenSize: _screenSize,
    distance: distance,
    screenPaddingBottom: _paddingBottom,
    screenPaddingTop: _paddingTop,
    arrowSize: arrowSize,
  );

  bool isExceedRight(double leftPos) => leftPosCalcualor.isExceedRight(leftPos);
  bool isExceedLeft(double leftPos) => leftPosCalcualor.isExceedLeft(leftPos);

  Offset preventOverflow(Offset dialogPos) {
    double newleftPos = leftPosCalcualor.preventOverflow(dialogPos.dx);
    double newTopPos = topPosCalcualor.preventOverflow(dialogPos.dy);
    return Offset(newleftPos, newTopPos);
  }

  Offset getAlignRight() {
    double leftPos = leftPosCalcualor.getAlignRight();
    double topPos = topPosCalcualor.getAlignRightOrLeftCenter();
    return Offset(leftPos, topPos);
  }

  Offset getAlignLeft() {
    double leftPos = leftPosCalcualor.getAlignLeft();
    double topPos = topPosCalcualor.getAlignRightOrLeftCenter();
    return Offset(leftPos, topPos);
  }

  Offset getAlignTop() {
    double leftPos = leftPosCalcualor.getAlignTopOrBottomCenter();
    double topPos = topPosCalcualor.getAlignTop();
    return Offset(leftPos, topPos);
  }

  Offset getAlignBottom() {
    double leftPos = leftPosCalcualor.getAlignTopOrBottomCenter();
    double topPos = topPosCalcualor.getAlignBottom();
    return Offset(leftPos, topPos);
  }

  Offset getAlignBottomLeft() {
    double leftPos = leftPosCalcualor.getAlignTopOrBottomLeft();
    double topPos = topPosCalcualor.getAlignBottom();
    return Offset(leftPos, topPos);
  }
}

class LeftPosCalcualor {
  final Size screenSize;
  final Size dialogSize;
  final Size targetWidgetSize;
  final Offset targetWidgetPos;
  final double distance;
  final Size? arrowSize;

  LeftPosCalcualor({
    required this.dialogSize,
    required this.targetWidgetSize,
    required this.targetWidgetPos,
    required this.screenSize,
    this.arrowSize,
    this.distance = 0,
  });

  bool isExceedRight(double leftPos) {
    return (leftPos + dialogSize.width) > screenSize.width - 5;
  }

  bool isExceedLeft(double leftPos) {
    return leftPos < 5;
  }

  double preventOverflow(double leftPos) {
    if (isExceedRight(leftPos)) {
      leftPos = screenSize.width - dialogSize.width - 5;
    } else if (isExceedLeft(leftPos)) {
      leftPos = 5;
    }
    return leftPos;
  }

  double getAlignRight() {
    double leftPos = (targetWidgetSize.width +
        targetWidgetPos.dx +
        distance +
        (arrowSize?.height ?? 0));
    return leftPos;
  }

  double getAlignLeft() {
    double leftPos = (targetWidgetPos.dx -
        dialogSize.width -
        distance -
        (arrowSize?.height ?? 0));
    return leftPos;
  }

  double getAlignTopOrBottomCenter() {
    double leftPos = (targetWidgetPos.dx +
        targetWidgetSize.width / 2 -
        dialogSize.width / 2);

    if (leftPos < 5) {
      leftPos = 5;
    } else if ((leftPos + dialogSize.width) > screenSize.width - 5) {
      leftPos = screenSize.width - dialogSize.width - 5;
    }

    return leftPos;
  }

  double getAlignTopOrBottomLeft() {
    double leftPos =
        (targetWidgetPos.dx - dialogSize.width + targetWidgetSize.width);

    if (leftPos < 5) {
      leftPos = 5;
    } else if ((leftPos + dialogSize.width) > screenSize.width - 5) {
      leftPos = screenSize.width - dialogSize.width - 5;
    }

    return leftPos;
  }
}

class TopPosCalculator {
  final Size screenSize;
  final Size dialogSize;
  final Size targetWidgetSize;
  final Offset targetWidgetPos;
  final double distance;
  final double screenPaddingTop;
  final double screenPaddingBottom;
  final Size? arrowSize;

  TopPosCalculator({
    required this.dialogSize,
    required this.targetWidgetSize,
    required this.targetWidgetPos,
    required this.screenSize,
    this.arrowSize,
    this.screenPaddingBottom = 0,
    this.screenPaddingTop = 0,
    this.distance = 0,
  });

  bool isExceedTop(double topPos) {
    return topPos < 5;
  }

  bool isExceedBottom(double topPos) {
    return (topPos + dialogSize.height) > screenSize.height - 5;
  }

  double preventOverflow(double topPos) {
    if (isExceedTop(topPos)) {
      topPos = 5;
    } else if (isExceedBottom(topPos)) {
      topPos = screenSize.height - dialogSize.height - 5;
    }
    return topPos;
  }

  double getAlignTop() {
    double topPos = (targetWidgetPos.dy -
        dialogSize.height -
        distance -
        (arrowSize?.height ?? 0) -
        screenPaddingTop);
    return topPos;
  }

  double getAlignBottom() {
    double topPos = (targetWidgetPos.dy +
        targetWidgetSize.height +
        distance +
        (arrowSize?.height ?? 0) -
        screenPaddingTop);
    return topPos;
  }

  double getAlignRightOrLeftCenter() {
    double topPos = (screenSize.height - dialogSize.height) / 2;

    //follow target widget
    if (targetWidgetPos.dy <= topPos) {
      topPos = targetWidgetPos.dy - screenPaddingTop - 10;
    } else if ((targetWidgetPos.dy + targetWidgetSize.height - 20) >=
        topPos + dialogSize.height) {
      topPos = targetWidgetPos.dy + targetWidgetSize.height - dialogSize.height;
    }

    //prevent vertical overflow
    if ((topPos + dialogSize.height) >= screenSize.height - 5) {
      topPos = screenSize.height - dialogSize.height - 10;
    } else if (topPos < 5) {
      topPos = 5;
    }
    return topPos;
  }
}
