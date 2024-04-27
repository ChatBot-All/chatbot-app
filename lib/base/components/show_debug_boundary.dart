import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class ShowDebugBoundary extends SingleChildRenderObjectWidget {
  const ShowDebugBoundary({
    super.key,
    this.enabled = true,
    required super.child,
  });

  final bool enabled;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderShowDebugBoundary(enabled: enabled);
  }

  @override
  void updateRenderObject(BuildContext context, RenderShowDebugBoundary renderObject) {
    renderObject.enabled = enabled;
  }
}

class RenderShowDebugBoundary extends RenderProxyBox {
  RenderShowDebugBoundary({
    required bool enabled,
    RenderBox? child,
  })  : _enabled = enabled,
        super(child);

  bool _enabled;

  bool get enabled => _enabled;

  set enabled(bool value) {
    if (_enabled != value) {
      _enabled = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final previousState = debugPaintSizeEnabled;
    debugPaintSizeEnabled = enabled;
    super.paint(context, offset);
    debugPaintSizeEnabled = previousState;
  }
}
