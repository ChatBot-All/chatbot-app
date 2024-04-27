import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExpandTapArea extends SingleChildRenderObjectWidget {
  const ExpandTapArea({
    Key? key,
    Widget? child,
    required this.onTap,
    required this.tapPadding,
  }) : super(key: key, child: child);

  final VoidCallback onTap;
  final EdgeInsets tapPadding;

  @override
  RenderObject createRenderObject(BuildContext context) => _ExpandTapRenderBox(
        onTap: onTap,
        tapPadding: tapPadding,
      );
}

class _TmpGestureArenaMember extends GestureArenaMember {
  _TmpGestureArenaMember({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  void acceptGesture(int key) {
    onTap();
  }

  @override
  void rejectGesture(int key) {}
}

class _ExpandTapRenderBox extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  _ExpandTapRenderBox({
    required this.onTap,
    this.tapPadding = EdgeInsets.zero,
  });

  final VoidCallback onTap;
  final EdgeInsets tapPadding;

  @override
  void performLayout() {
    child!.layout(constraints, parentUsesSize: true);
    size = child!.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      final BoxParentData childParentData = child!.parentData! as BoxParentData;
      context.paintChild(child!, childParentData.offset + offset);
    }
  }

  @override
  void handleEvent(PointerEvent event, BoxHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _TmpGestureArenaMember member = _TmpGestureArenaMember(onTap: onTap);
      GestureBinding.instance.gestureArena.add(event.pointer, member);
    } else if (event is PointerUpEvent) {
      GestureBinding.instance.gestureArena.sweep(event.pointer);
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {Offset? position}) {
    visitChildren((child) {
      if (child is RenderBox) {
        final BoxParentData parentData = child.parentData! as BoxParentData;
        if (child.hitTest(result, position: position! - parentData.offset)) {
          return;
        }
      }
    });
    return false;
  }

  @override
  bool hitTest(BoxHitTestResult result, {Offset? position}) {
    Rect expandRect = Rect.fromLTWH(
      0 - tapPadding.left,
      0 - tapPadding.top,
      size.width + tapPadding.right + tapPadding.left,
      size.height + tapPadding.top + tapPadding.bottom,
    );
    if (expandRect.contains(position!)) {
      bool hitTarget =
          hitTestChildren(result, position: position) || hitTestSelf(position);
      if (hitTarget) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return false;
  }
}
