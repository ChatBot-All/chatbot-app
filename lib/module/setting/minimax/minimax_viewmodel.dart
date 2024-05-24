import 'package:chat_bot/hive_bean/local_chat_history.dart';

import '../../../base.dart';

final miniMaxApiServerAddressProvider =
    StateProvider.autoDispose<String>((ref) {
  return APIType.miniMax.host;
}, name: "miniMaxApiServerAddressProvider");
