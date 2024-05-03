import 'dart:math';

import 'package:flutter/cupertino.dart';

import '../base.dart';
import 'fimpl/animation_dialog.dart';
import 'fimpl/special_routes.dart';

final F = _FImpl();

class _FImpl {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();

  get context => _navigatorKey.currentContext;

  get navigatorKey => _navigatorKey;

  static final _FImpl _singleton = _FImpl._internal();

  ///常用工具方法
  get width => MediaQuery.sizeOf(context).width;

  get height => MediaQuery.sizeOf(context).height;

  String formatTime(int ms) {
    return DateUtil.formatDateMs(ms, format: "yyyy-MM-dd HH:mm:ss");
  }

  void hideKeyboard() {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<T?> push<T extends Object?>(Widget page) {
    return Navigator.of(context).push(CupertinoPageRoute(builder: (context) => page));
  }

  Future<T?> pushTransparent<T extends Object?>(Widget page) {
    return Navigator.of(context).push(TransparentMaterialPageRoute(
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return page;
    }));
  }

  //replace
  Future<T?> pushReplacement<T extends Object?, TO extends Object?>(Widget page, {TO? result}) {
    return Navigator.of(context).pushReplacement(CupertinoPageRoute(builder: (context) => page), result: result);
  }

  Future<T?> pushReplacementNoAnimation<T extends Object?, TO extends Object?>(Widget page, {TO? result}) {
    return Navigator.of(context).pushReplacement(NoAnimationPageRoute(builder: (context) => page), result: result);
  }

  void popUntil(RoutePredicate predicate) {
    Navigator.of(context).popUntil(predicate);
  }

  //pop
  void pop<T extends Object?>([T? result]) {
    Navigator.of(context).pop(result);
  }

  /// 常用工具方法 结束

  factory _FImpl() {
    return _singleton;
  }

  _FImpl._internal();

  Future<T?> animatedDialog<T>(
    Widget widget, {
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useSafeArea = true,
    GlobalKey<NavigatorState>? navigatorKey,
    Object? arguments,
    Duration? transitionDuration,
    Curve? transitionCurve,
    String? name,
    RouteSettings? routeSettings,
    EDialogTransition transition = EDialogTransition.scale,
  }) async {
    assert(debugCheckHasMaterialLocalizations(context));

    final theme = Theme.of(context);

    return generalDialog<T>(
      pageBuilder: (buildContext, animation, secondaryAnimation) {
        final pageChild = widget;
        Widget dialog = Builder(builder: (context) {
          return Theme(data: theme, child: pageChild);
        });
        if (useSafeArea) {
          dialog = SafeArea(child: dialog);
        }
        return dialog;
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black45,
      transitionDuration: transitionDuration ?? const Duration(milliseconds: 300),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = transitionCurve ?? Curves.easeOutQuad;
        switch (transition) {
          case EDialogTransition.fadeScale:
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(parent: animation, curve: curve),
                child: child,
              ),
            );

          case EDialogTransition.rotation3d:
            return Rotation3DTransition(
                Tween<double>(begin: pi, end: 2.0 * pi).animate(CurvedAnimation(parent: animation, curve: curve)),
                child: child);

          default:
            return ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: curve,
              ),
              child: child,
            );
        }
      },
      navigatorKey: navigatorKey,
      routeSettings: routeSettings ?? RouteSettings(arguments: arguments, name: name),
      context: context,
    );
  }
}

//NoAnimationPageRoute
class NoAnimationPageRoute<T> extends PageRoute<T> {
  NoAnimationPageRoute({
    required this.builder,
    RouteSettings? settings,
    this.maintainState = true,
    bool fullscreenDialog = false,
  }) : super(settings: settings, fullscreenDialog: fullscreenDialog);

  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is NoAnimationPageRoute || previousRoute is CupertinoPageRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is NoAnimationPageRoute || nextRoute is CupertinoPageRoute;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }

  @override
  Color? get barrierColor => const Color(0x18000000);

  @override
  String? get barrierLabel => null;
}
