import 'package:flutter/material.dart';

enum DialogAlignment {
  right,
  left,
  top,
  bottom,
  center,
}

class TransformFollowerDialog extends StatefulWidget {
  final Widget targetWidget;
  final Widget dialog;
  final DialogAlignment alignment;
  final Offset offset;
  final VoidCallback? onTap;

  const TransformFollowerDialog({
    Key? key,
    required this.targetWidget,
    required this.dialog,
    this.alignment = DialogAlignment.right,
    this.offset = Offset.zero,
    this.onTap,
  }) : super(key: key);

  @override
  _TransformFollowerDialogState createState() =>
      _TransformFollowerDialogState();
}

class _TransformFollowerDialogState extends State<TransformFollowerDialog> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isDialogVisible = false;

  @override
  void dispose() {
    _hideDialog();
    super.dispose();
  }

  void _showDialog() {
    if (_isDialogVisible) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => _DialogFollower(
        link: _layerLink,
        alignment: widget.alignment,
        offset: widget.offset,
        child: widget.dialog,
        onDismiss: _hideDialog,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isDialogVisible = true;
  }

  void _hideDialog() {
    if (!_isDialogVisible) return;

    _overlayEntry?.remove();
    _overlayEntry = null;
    _isDialogVisible = false;
  }

  void _toggleDialog() {
    if (_isDialogVisible) {
      _hideDialog();
    } else {
      _showDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: widget.onTap ?? _toggleDialog,
        child: widget.targetWidget,
      ),
    );
  }
}

class _DialogFollower extends StatelessWidget {
  final LayerLink link;
  final DialogAlignment alignment;
  final Offset offset;
  final Widget child;
  final VoidCallback onDismiss;

  const _DialogFollower({
    Key? key,
    required this.link,
    required this.alignment,
    required this.offset,
    required this.child,
    required this.onDismiss,
  }) : super(key: key);

  Alignment _getTargetAnchor() {
    switch (alignment) {
      case DialogAlignment.right:
        return Alignment(1.0, 0.5);
      case DialogAlignment.left:
        return Alignment(0.0, 0.5);
      case DialogAlignment.top:
        return Alignment(0.5, 0.0);
      case DialogAlignment.bottom:
        return Alignment(0.5, 1.0);
      case DialogAlignment.center:
        return Alignment(0.5, 0.5);
    }
  }

  Alignment _getFollowerAnchor() {
    switch (alignment) {
      case DialogAlignment.right:
        return Alignment(0.0, 0.5);
      case DialogAlignment.left:
        return Alignment(1.0, 0.5);
      case DialogAlignment.top:
        return Alignment(0.5, 1.0);
      case DialogAlignment.bottom:
        return Alignment(0.5, 0.0);
      case DialogAlignment.center:
        return Alignment(0.5, 0.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onDismiss,
      child: SizedBox.expand(
        child: CompositedTransformFollower(
          link: link,
          targetAnchor: _getTargetAnchor(),
          followerAnchor: _getFollowerAnchor(),
          offset: offset,
          child: Material(
            color: Colors.transparent,
            child: child,
          ),
        ),
      ),
    );
  }
}

// High-performance dialog manager
class DialogManager {
  static final Map<String, OverlayEntry> _activeDialogs = {};

  static void showDialog({
    required BuildContext context,
    required String id,
    required LayerLink link,
    required Widget dialog,
    DialogAlignment alignment = DialogAlignment.right,
    Offset offset = Offset.zero,
  }) {
    hideDialog(id); // Remove existing dialog with same ID

    final overlayEntry = OverlayEntry(
      builder: (context) => _DialogFollower(
        link: link,
        alignment: alignment,
        offset: offset,
        child: dialog,
        onDismiss: () => hideDialog(id),
      ),
    );

    Overlay.of(context).insert(overlayEntry);
    _activeDialogs[id] = overlayEntry;
  }

  static void hideDialog(String id) {
    final overlay = _activeDialogs.remove(id);
    overlay?.remove();
  }

  static void hideAllDialogs() {
    for (final overlay in _activeDialogs.values) {
      overlay.remove();
    }
    _activeDialogs.clear();
  }
}

// Usage example
class ExampleTransformFollower extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transform Follower Dialog')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TransformFollowerDialog(
              targetWidget: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.more_vert, color: Colors.white),
              ),
              alignment: DialogAlignment.right,
              offset: Offset(8, 0),
              dialog: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Right Dialog'),
                    TextButton(
                      onPressed: () {},
                      child: Text('Action 1'),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text('Action 2'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            TransformFollowerDialog(
              targetWidget: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.settings, color: Colors.white),
              ),
              alignment: DialogAlignment.top,
              offset: Offset(0, -8),
              dialog: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Text('Top Dialog'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
