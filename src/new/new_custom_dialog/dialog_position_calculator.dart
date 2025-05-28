part of 'new_custom_dialog.dart';

/// Handles all position calculations for the dialog and arrow
class _DialogPositionCalculator {
  Size? _targetSize;
  Offset? _targetPosition;

  bool get hasTarget => _targetSize != null && _targetPosition != null;

  void updateTarget(Size size, Offset position) {
    _targetSize = size;
    _targetPosition = position;
  }

  void clearTarget() {
    _targetSize = null;
    _targetPosition = null;
  }

  /// Calculates the optimal position for the dialog
  Offset calculatePosition({
    required Size dialogSize,
    required Size screenSize,
    required EdgeInsets safeArea,
    required AlignTargetWidget alignment,
    required double targetDistance,
    required Offset positionOffset,
    Size? arrowSize,
  }) {
    if (!hasTarget) {
      return _getCenterPosition(dialogSize, screenSize, safeArea);
    }

    final calculator = _PositionCalculatorHelper(
      dialogSize: dialogSize,
      targetSize: _targetSize!,
      targetPosition: _targetPosition!,
      screenSize: screenSize,
      safeArea: safeArea,
      targetDistance: targetDistance,
      arrowSize: arrowSize,
    );

    Offset position = _calculateAlignmentPosition(calculator, alignment);
    position = calculator.preventOverflow(position);

    // Apply manual offset adjustment
    position = Offset(
      position.dx + positionOffset.dx,
      position.dy + positionOffset.dy,
    );

    return position;
  }

  /// Calculates the arrow position based on dialog position and alignment
  Offset calculateArrowPosition({
    required Offset dialogPosition,
    required Size dialogSize,
    required AlignTargetWidget alignment,
    required Size arrowSize,
  }) {
    if (!hasTarget) return Offset.zero;

    final targetCenter = Offset(
      _targetPosition!.dx + _targetSize!.width / 2,
      _targetPosition!.dy + _targetSize!.height / 2,
    );

    switch (alignment) {
      case AlignTargetWidget.left:
      case AlignTargetWidget.leftCenter:
        return Offset(
          dialogPosition.dx + dialogSize.width,
          targetCenter.dy - arrowSize.width / 2,
        );

      case AlignTargetWidget.right:
      case AlignTargetWidget.rightCenter:
        return Offset(
          dialogPosition.dx - arrowSize.height,
          targetCenter.dy - arrowSize.width / 2,
        );

      case AlignTargetWidget.topCenter:
        return Offset(
          targetCenter.dx - arrowSize.width / 2,
          dialogPosition.dy + dialogSize.height,
        );

      case AlignTargetWidget.bottomCenter:
      case AlignTargetWidget.bottomLeft:
      case AlignTargetWidget.centerBottomRight:
        return Offset(
          targetCenter.dx - arrowSize.width / 2,
          dialogPosition.dy - arrowSize.height,
        );
    }
  }

  Offset _getCenterPosition(
      Size dialogSize, Size screenSize, EdgeInsets safeArea) {
    final availableHeight = screenSize.height - safeArea.top - safeArea.bottom;
    final availableWidth = screenSize.width - safeArea.left - safeArea.right;

    return Offset(
      (availableWidth - dialogSize.width) / 2 + safeArea.left,
      (availableHeight - dialogSize.height) / 2,
    );
  }

  Offset _calculateAlignmentPosition(
      _PositionCalculatorHelper calculator, AlignTargetWidget alignment) {
    switch (alignment) {
      case AlignTargetWidget.right:
      case AlignTargetWidget.rightCenter:
        return calculator.getAlignRight();
      case AlignTargetWidget.left:
      case AlignTargetWidget.leftCenter:
        return calculator.getAlignLeft();
      case AlignTargetWidget.topCenter:
        return calculator.getAlignTop();
      case AlignTargetWidget.bottomCenter:
        return calculator.getAlignBottom();
      case AlignTargetWidget.bottomLeft:
        return calculator.getAlignBottomLeft();
      case AlignTargetWidget.centerBottomRight:
        return calculator.getAlignBottomRight();
    }
  }
}

/// Helper class for position calculations
class _PositionCalculatorHelper {
  final Size dialogSize;
  final Size targetSize;
  final Offset targetPosition;
  final Size screenSize;
  final EdgeInsets safeArea;
  final double targetDistance;
  final Size? arrowSize;

  const _PositionCalculatorHelper({
    required this.dialogSize,
    required this.targetSize,
    required this.targetPosition,
    required this.screenSize,
    required this.safeArea,
    required this.targetDistance,
    this.arrowSize,
  });

  double get _arrowHeight => arrowSize?.height ?? 0;
  double get _padding => 5.0;
  double get _availableWidth =>
      screenSize.width - safeArea.left - safeArea.right;
  double get _availableHeight =>
      screenSize.height - safeArea.top - safeArea.bottom;

  Offset getAlignRight() {
    final leftPos =
        targetPosition.dx + targetSize.width + targetDistance + _arrowHeight;
    final topPos = _getCenterVerticalPosition();
    return Offset(leftPos, topPos);
  }

  Offset getAlignLeft() {
    final leftPos =
        targetPosition.dx - dialogSize.width - targetDistance - _arrowHeight;
    final topPos = _getCenterVerticalPosition();
    return Offset(leftPos, topPos);
  }

  Offset getAlignTop() {
    final leftPos = _getCenterHorizontalPosition();
    final topPos = targetPosition.dy -
        dialogSize.height -
        targetDistance -
        _arrowHeight -
        safeArea.top;
    return Offset(leftPos, topPos);
  }

  Offset getAlignBottom() {
    final leftPos = _getCenterHorizontalPosition();
    final topPos = targetPosition.dy +
        targetSize.height +
        targetDistance +
        _arrowHeight -
        safeArea.top;
    return Offset(leftPos, topPos);
  }

  Offset getAlignBottomLeft() {
    final leftPos = targetPosition.dx - dialogSize.width + targetSize.width;
    final topPos = targetPosition.dy +
        targetSize.height +
        targetDistance +
        _arrowHeight -
        safeArea.top;
    return Offset(leftPos, topPos);
  }

  Offset getAlignBottomRight() {
    final leftPos = targetPosition.dx;
    final topPos =
        targetPosition.dy + targetDistance + _arrowHeight - safeArea.top;
    return Offset(leftPos, topPos);
  }

  double _getCenterVerticalPosition() {
    double topPos = targetPosition.dy +
        (targetSize.height / 2) -
        (dialogSize.height / 2) -
        safeArea.top;

    // Follow target widget if it's near the edges
    if (targetPosition.dy - safeArea.top <= topPos + 20) {
      topPos = targetPosition.dy - safeArea.top - 15;
    } else if ((targetPosition.dy + targetSize.height - 20) >=
        topPos + dialogSize.height) {
      topPos = targetPosition.dy +
          targetSize.height -
          dialogSize.height -
          safeArea.top;
    }

    return topPos;
  }

  double _getCenterHorizontalPosition() {
    double leftPos =
        targetPosition.dx + (targetSize.width / 2) - (dialogSize.width / 2);
    return leftPos;
  }

  Offset preventOverflow(Offset position) {
    double newLeft = position.dx;
    double newTop = position.dy;

    // Prevent horizontal overflow
    if (newLeft < _padding) {
      newLeft = _padding;
    } else if (newLeft + dialogSize.width > _availableWidth - _padding) {
      newLeft = _availableWidth - dialogSize.width - _padding;
    }

    // Prevent vertical overflow
    if (newTop < _padding) {
      newTop = _padding;
    } else if (newTop + dialogSize.height > _availableHeight - _padding) {
      newTop = _availableHeight - dialogSize.height - _padding;
    }

    return Offset(newLeft, newTop);
  }

  bool isExceedingRight(double leftPos) {
    return (leftPos + dialogSize.width) > _availableWidth - _padding;
  }

  bool isExceedingLeft(double leftPos) {
    return leftPos < _padding;
  }
}
