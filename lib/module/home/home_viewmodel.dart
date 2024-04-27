import 'package:flutter/cupertino.dart';

import '../../base.dart';

final homeIndexProvider = StateProvider<int>((ref) {
  return 0;
}, name: "homeIndex");

final homeNavigationProvider = Provider<List<Pair<IconData, IconData, String>>>((ref) {
  return [
    Pair(CupertinoIcons.chat_bubble_fill, CupertinoIcons.chat_bubble, S.current.home_chat),
    Pair(CupertinoIcons.hammer_fill, CupertinoIcons.hammer, S.current.home_factory),
    Pair(CupertinoIcons.settings_solid, CupertinoIcons.settings, S.current.home_setting),
  ];
}, name: "homeNavigation");

class Pair<A, B, C> {
  final A first;
  final B second;
  final C last;

  Pair(this.first, this.second, this.last);
}
