import 'package:flutter/cupertino.dart';

/// 顺序 prepareData -> afterLayout -> onLazyLoad
mixin LazyLoadState<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    prepareData();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      afterLayout();
      var route = ModalRoute.of(context);
      void handler(status) {
        if (status == AnimationStatus.completed) {
          route?.animation?.removeStatusListener(handler);
          onLazyLoad();
        }
      }

      if (route == null ||
          route.animation == null ||
          route.animation!.status == AnimationStatus.completed) {
        onLazyLoad();
      } else {
        route.animation!.addStatusListener(handler);
      }
    });
  }

  void onLazyLoad() {}

  void afterLayout() {}

  void prepareData() {}
}
