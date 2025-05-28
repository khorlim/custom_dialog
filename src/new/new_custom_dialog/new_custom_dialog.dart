import 'package:flutter/material.dart';
import '../../../../../tunai_style/extension/build_context_extension.dart';
import '../../../../dump/keyboard_size_provider/keyboard_size_provider.dart';
import '../../custom_dialog.dart';
import '../../triangle.dart';

part 'dialog_position_calculator.dart';

/// A highly customizable dialog widget that can be positioned relative to target widgets
/// with optional arrow indicators and keyboard-aware behavior.
class NewCustomDialog extends StatefulWidget {
  /// The context where the dialog will be displayed
  final BuildContext context;

  /// The content widget to display inside the dialog
  final Widget child;

  /// Optional fixed height for the dialog
  final double? height;

  /// Optional fixed width for the dialog
  final double? width;

  /// Context of the target widget to align the dialog to
  final BuildContext? targetWidgetContext;

  /// How to align the dialog relative to the target widget
  final AlignTargetWidget alignment;

  /// Whether to show an arrow pointing to the target widget
  final bool showArrow;

  /// Width of the arrow (default: 30)
  final double arrowWidth;

  /// Height of the arrow (default: 15)
  final double arrowHeight;

  /// Additional offset adjustment for fine-tuning position
  final Offset positionOffset;

  /// Distance between the dialog and target widget
  final double targetDistance;

  /// Callback when user taps outside the dialog
  final VoidCallback? onTapOutside;

  /// Whether to move dialog above keyboard when it appears
  final bool avoidKeyboard;

  /// Whether to resize dialog when keyboard appears
  final bool resizeForKeyboard;

  /// Border radius for the dialog corners
  final double borderRadius;

  /// Whether to show shadow around the dialog
  final bool hasShadow;

  /// Callback when dialog is dismissed
  final VoidCallback? onDismiss;

  /// Whether the dialog can be dismissed by tapping outside
  final bool dismissible;

  const NewCustomDialog({
    super.key,
    required this.context,
    required this.child,
    this.height,
    this.width,
    this.targetWidgetContext,
    this.alignment = AlignTargetWidget.right,
    this.showArrow = false,
    this.arrowWidth = 30,
    this.arrowHeight = 15,
    this.positionOffset = Offset.zero,
    this.targetDistance = 0,
    this.onTapOutside,
    this.avoidKeyboard = false,
    this.resizeForKeyboard = true,
    this.borderRadius = 10,
    this.hasShadow = false,
    this.onDismiss,
    this.dismissible = true,
  });

  @override
  State<NewCustomDialog> createState() => _NewCustomDialogState();
}

class _NewCustomDialogState extends State<NewCustomDialog>
    with TickerProviderStateMixin {
  late final _DialogController _controller;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = _DialogController(widget: widget);
    _initializeAnimations();
    _controller.initialize();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(NewCustomDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_shouldRecalculatePosition(oldWidget)) {
      _controller.updateWidget(widget);
      _controller.recalculatePosition();
    }
  }

  bool _shouldRecalculatePosition(NewCustomDialog oldWidget) {
    return widget.height != oldWidget.height ||
        widget.width != oldWidget.width ||
        widget.alignment != oldWidget.alignment ||
        widget.targetWidgetContext != oldWidget.targetWidgetContext;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSizeProvider(
      child: SafeArea(
        child: Consumer<ScreenHeight>(
          builder: (context, screenHeight, child) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final state = _controller.calculateLayout(
                  MediaQuery.of(context),
                  screenHeight,
                );

                return _DialogOverlay(
                  state: state,
                  scaleAnimation: _scaleAnimation,
                  onTapOutside: _handleTapOutside,
                  child: widget.child,
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _handleTapOutside() {
    if (!widget.dismissible) return;

    if (widget.onTapOutside != null) {
      widget.onTapOutside!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    widget.onDismiss?.call();
    super.dispose();
  }
}

/// Internal controller class that manages dialog state and calculations
class _DialogController extends ChangeNotifier {
  NewCustomDialog widget;
  late _DialogPositionCalculator _positionCalculator;

  // Cached values for performance
  // Size? _cachedDialogSize;
  Offset? _cachedPosition;
  String? _lastCacheKey;

  _DialogController({required this.widget}) {
    _positionCalculator = _DialogPositionCalculator();
  }

  void initialize() {
    _updateTargetWidget();
  }

  void updateWidget(NewCustomDialog newWidget) {
    widget = newWidget;
    _updateTargetWidget();
  }

  void recalculatePosition() {
    _clearCache();
    _updateTargetWidget();
    notifyListeners();
  }

  void _updateTargetWidget() {
    if (widget.targetWidgetContext?.mounted == true) {
      final renderObject = widget.targetWidgetContext!.findRenderObject();
      if (renderObject is RenderBox && renderObject.hasSize) {
        _positionCalculator.updateTarget(
          renderObject.size,
          renderObject.localToGlobal(Offset.zero),
        );
      } else {
        // Schedule update after layout
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (widget.targetWidgetContext?.mounted == true) {
            _updateTargetWidget();
            notifyListeners();
          }
        });
      }
    } else {
      _positionCalculator.clearTarget();
    }
  }

  _DialogLayoutState calculateLayout(
    MediaQueryData mediaQuery,
    ScreenHeight screenHeight,
  ) {
    final screenSize = mediaQuery.size;
    final safeArea = mediaQuery.padding;
    final isKeyboardVisible = screenHeight.isOpen;
    final keyboardHeight = screenHeight.keyboardHeight;

    // Calculate dialog size
    final dialogSize = _calculateDialogSize(screenSize, mediaQuery.orientation);

    // Calculate position with caching
    final cacheKey =
        _generateCacheKey(dialogSize, screenSize, widget.alignment);
    Offset position;

    if (_lastCacheKey == cacheKey && _cachedPosition != null) {
      position = _cachedPosition!;
    } else {
      position = _positionCalculator.calculatePosition(
        dialogSize: dialogSize,
        screenSize: screenSize,
        safeArea: safeArea,
        alignment: widget.alignment,
        targetDistance: widget.targetDistance,
        arrowSize: widget.showArrow
            ? Size(widget.arrowWidth, widget.arrowHeight)
            : null,
        positionOffset: widget.positionOffset,
      );
      _cachedPosition = position;
      _lastCacheKey = cacheKey;
    }

    // Handle keyboard adjustments
    Size adjustedDialogSize = dialogSize;
    Offset adjustedPosition = position;

    if (isKeyboardVisible) {
      final adjustment = _calculateKeyboardAdjustment(
        dialogSize,
        position,
        screenSize,
        keyboardHeight,
        safeArea,
      );
      adjustedDialogSize = adjustment.size;
      adjustedPosition = adjustment.position;
    }

    // Calculate arrow position and visibility
    final arrowState = _calculateArrowState(
      adjustedPosition,
      adjustedDialogSize,
      isKeyboardVisible,
    );

    return _DialogLayoutState(
      dialogSize: adjustedDialogSize,
      dialogPosition: adjustedPosition,
      arrowState: arrowState,
      isKeyboardVisible: isKeyboardVisible,
    );
  }

  Size _calculateDialogSize(Size screenSize, Orientation orientation) {
    final defaultWidth =
        screenSize.width * (orientation == Orientation.landscape ? 0.35 : 0.47);
    final defaultHeight = screenSize.height *
        (orientation == Orientation.landscape ? 0.78 : 0.55);

    double width = widget.width ?? defaultWidth;
    double height = widget.height ?? defaultHeight;

    // Ensure minimum width
    if (widget.width == null && width < 350) {
      width = 350;
    }

    return Size(width, height);
  }

  String _generateCacheKey(
      Size dialogSize, Size screenSize, AlignTargetWidget alignment) {
    return '${dialogSize.width}-${dialogSize.height}-${screenSize.width}-${screenSize.height}-${alignment.name}';
  }

  ({Size size, Offset position}) _calculateKeyboardAdjustment(
    Size dialogSize,
    Offset position,
    Size screenSize,
    double keyboardHeight,
    EdgeInsets safeArea,
  ) {
    Size adjustedSize = dialogSize;
    Offset adjustedPosition = position;

    if (widget.avoidKeyboard) {
      // Move dialog above keyboard
      adjustedPosition = Offset(position.dx, 10);
    } else if (widget.resizeForKeyboard) {
      // Resize dialog to fit above keyboard
      final availableHeight =
          screenSize.height - keyboardHeight - safeArea.top - safeArea.bottom;
      final maxDialogHeight = availableHeight - position.dy - 20; // 20px margin

      if (maxDialogHeight < dialogSize.height && maxDialogHeight > 100) {
        adjustedSize = Size(dialogSize.width, maxDialogHeight);
      }
    }

    return (size: adjustedSize, position: adjustedPosition);
  }

  _ArrowState _calculateArrowState(
    Offset dialogPosition,
    Size dialogSize,
    bool isKeyboardVisible,
  ) {
    if (!widget.showArrow ||
        !_positionCalculator.hasTarget ||
        (widget.avoidKeyboard && isKeyboardVisible)) {
      return _ArrowState(visible: false);
    }

    final arrowPosition = _positionCalculator.calculateArrowPosition(
      dialogPosition: dialogPosition,
      dialogSize: dialogSize,
      alignment: widget.alignment,
      arrowSize: Size(widget.arrowWidth, widget.arrowHeight),
    );

    final arrowDirection = _getArrowDirection(widget.alignment);
    final animationAlignment = _getArrowAnimationAlignment(widget.alignment);

    return _ArrowState(
      visible: true,
      position: arrowPosition,
      direction: arrowDirection,
      animationAlignment: animationAlignment,
      size: Size(widget.arrowWidth, widget.arrowHeight),
    );
  }

  ArrowPointing _getArrowDirection(AlignTargetWidget alignment) {
    switch (alignment) {
      case AlignTargetWidget.left:
      case AlignTargetWidget.leftCenter:
        return ArrowPointing.right;
      case AlignTargetWidget.right:
      case AlignTargetWidget.rightCenter:
        return ArrowPointing.left;
      case AlignTargetWidget.topCenter:
        return ArrowPointing.bottom;
      case AlignTargetWidget.bottomCenter:
      case AlignTargetWidget.bottomLeft:
        return ArrowPointing.top;
      case AlignTargetWidget.centerBottomRight:
        return ArrowPointing.top;
    }
  }

  Alignment _getArrowAnimationAlignment(AlignTargetWidget alignment) {
    switch (alignment) {
      case AlignTargetWidget.left:
      case AlignTargetWidget.leftCenter:
        return Alignment.centerLeft;
      case AlignTargetWidget.right:
      case AlignTargetWidget.rightCenter:
        return Alignment.centerRight;
      case AlignTargetWidget.topCenter:
        return Alignment.topCenter;
      case AlignTargetWidget.bottomCenter:
      case AlignTargetWidget.bottomLeft:
      case AlignTargetWidget.centerBottomRight:
        return Alignment.bottomCenter;
    }
  }

  void _clearCache() {
    _cachedPosition = null;
    // _cachedDialogSize = null;
    _lastCacheKey = null;
  }

  @override
  void dispose() {
    _clearCache();
    super.dispose();
  }
}

/// Represents the complete layout state of the dialog
class _DialogLayoutState {
  final Size dialogSize;
  final Offset dialogPosition;
  final _ArrowState arrowState;
  final bool isKeyboardVisible;

  const _DialogLayoutState({
    required this.dialogSize,
    required this.dialogPosition,
    required this.arrowState,
    required this.isKeyboardVisible,
  });
}

/// Represents the state of the arrow indicator
class _ArrowState {
  final bool visible;
  final Offset position;
  final ArrowPointing direction;
  final Alignment animationAlignment;
  final Size size;

  const _ArrowState({
    required this.visible,
    this.position = Offset.zero,
    this.direction = ArrowPointing.right,
    this.animationAlignment = Alignment.center,
    this.size = const Size(30, 15),
  });
}

/// The overlay widget that renders the dialog and arrow
class _DialogOverlay extends StatelessWidget {
  final _DialogLayoutState state;
  final Animation<double> scaleAnimation;
  final VoidCallback onTapOutside;
  final Widget child;

  const _DialogOverlay({
    required this.state,
    required this.scaleAnimation,
    required this.onTapOutside,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background tap detector
        Positioned.fill(
          child: GestureDetector(
            onTap: onTapOutside,
            child: Container(color: Colors.transparent),
          ),
        ),

        // Dialog container
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          left: state.dialogPosition.dx,
          top: state.dialogPosition.dy,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: _DialogContainer(
              size: state.dialogSize,
              child: child,
            ),
          ),
        ),

        // Arrow indicator
        if (state.arrowState.visible)
          Positioned(
            left: state.arrowState.position.dx,
            top: state.arrowState.position.dy,
            child: ScaleTransition(
              scale: scaleAnimation,
              alignment: state.arrowState.animationAlignment,
              child: _ArrowWidget(
                direction: state.arrowState.direction,
                size: state.arrowState.size,
              ),
            ),
          ),
      ],
    );
  }
}

/// The main dialog container with styling
class _DialogContainer extends StatelessWidget {
  final Size size;
  final Widget child;

  const _DialogContainer({
    required this.size,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.08),
            spreadRadius: 3,
            blurRadius: 5,
            offset: Offset.zero,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Arrow widget with direction-specific painters
class _ArrowWidget extends StatelessWidget {
  final ArrowPointing direction;
  final Size size;

  const _ArrowWidget({
    required this.direction,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 3,
      shadowColor: Colors.grey.withValues(alpha: 0.06),
      shape: BoxShape.circle,
      child: CustomPaint(
        painter: _getArrowPainter(direction),
        size: _getArrowSize(),
      ),
    );
  }

  CustomPainter _getArrowPainter(ArrowPointing direction) {
    switch (direction) {
      case ArrowPointing.top:
        return TriangleArrowTop();
      case ArrowPointing.bottom:
        return TriangleArrowDown();
      case ArrowPointing.left:
        return TriangleArrowLeft();
      case ArrowPointing.right:
        return TriangleArrowRight();
    }
  }

  Size _getArrowSize() {
    switch (direction) {
      case ArrowPointing.top:
      case ArrowPointing.bottom:
        return Size(size.width, size.height);
      case ArrowPointing.left:
      case ArrowPointing.right:
        return Size(size.height, size.width);
    }
  }
}
