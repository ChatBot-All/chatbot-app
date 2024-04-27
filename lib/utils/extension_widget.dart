import 'package:flutter/cupertino.dart';

extension ExtensionWidget on Widget {
  Widget gesture(VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: this,
    );
  }

  Widget click(VoidCallback onPressed, {bool enable = true}) {
    if (enable == false) {
      return Opacity(
        opacity: 0.5,
        child: this,
      );
    }
    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      minSize: 1,
      child: this,
    );
  }

  Widget padding(EdgeInsetsGeometry padding) {
    return Padding(
      padding: padding,
      child: this,
    );
  }

  Widget visible(bool visible) {
    return Visibility(
      visible: visible,
      child: this,
    );
  }

  Widget gone(bool gone) {
    return Opacity(
      opacity: gone ? 0 : 1,
      child: this,
    );
  }

  Widget expanded({int flex = 1}) {
    return Expanded(
      flex: flex,
      child: this,
    );
  }

  Widget flexible({int flex = 1}) {
    return Flexible(
      fit: FlexFit.loose,
      flex: flex,
      child: this,
    );
  }

  Widget container({
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    AlignmentGeometry? alignment,
  }) {
    return Container(
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      alignment: alignment,
      child: this,
    );
  }
}

extension ExtensionContext on BuildContext {
  Future<T?> cPushAndReplace<T, T0>(Widget widget,
      {bool needLogin = false}) async {
    return Navigator.of(this).pushReplacement<T, T0>(
        CupertinoPageRoute(builder: (context) => widget));
  }

  Future<T?> cPush<T>(Widget widget, {bool needLogin = false}) async {
    return Navigator.of(this)
        .push<T>(CupertinoPageRoute(builder: (context) => widget));
  }

  Future<T?> cPushAndRemoveAll<T>(Widget widget,
      {bool needLogin = false}) async {
    return Navigator.of(this).pushAndRemoveUntil<T>(
        CupertinoPageRoute(builder: (context) => widget), (route) => false);
  }
}
