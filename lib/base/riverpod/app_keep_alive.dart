import 'package:flutter/material.dart';

class AppKeepAlive extends StatefulWidget {
  final Widget child;

  const AppKeepAlive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AppKeepAlive> createState() => _AppKeepAliveState();
}

class _AppKeepAliveState extends State<AppKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
