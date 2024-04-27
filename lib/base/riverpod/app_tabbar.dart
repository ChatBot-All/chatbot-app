import 'package:flutter/material.dart';

import 'app_keep_alive.dart';

typedef TabControllerCallBack = void Function(int index);

class AppTabBar extends StatefulWidget {
  final List<Widget> tabs;
  final List<Widget> views;
  final TabControllerCallBack? callBack;

  const AppTabBar({
    super.key,
    required this.tabs,
    required this.views,
    this.callBack,
  }) : assert(tabs.length == views.length);

  @override
  State<AppTabBar> createState() => _AppTabBarState();
}

class _AppTabBarState extends State<AppTabBar>
    with SingleTickerProviderStateMixin {
  late TabController controller;

  @override
  void initState() {
    controller = TabController(length: widget.tabs.length, vsync: this)
      ..addListener(() {
        if (widget.callBack != null) {
          widget.callBack!(controller.index);
        }
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          child: TabBar(
            labelStyle: const TextStyle(
              fontSize: 17,
              color: Color(0xFF3B3552),
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 17,
              color: Color(0xff767676),
            ),
            labelPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            indicator: const BoxDecoration(),
            isScrollable: false,
            enableFeedback: true,
            tabs: widget.tabs,
            controller: controller,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: controller,
            children: widget.views.map((e) => AppKeepAlive(child: e)).toList(),
          ),
        ),
      ],
    );
  }
}
