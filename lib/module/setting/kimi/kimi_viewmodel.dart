import 'package:chat_bot/hive_bean/local_chat_history.dart';

import '../../../base.dart';

final kimiApiServerAddressProvider = StateProvider.autoDispose<String>((ref) {
  return APIType.kimi.host;
}, name: "kimiApiServerAddressProvider");

