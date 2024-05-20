import 'package:chat_bot/hive_bean/local_chat_history.dart';

import '../../../base.dart';

final deepSeekApiServerAddressProvider = StateProvider.autoDispose<String>((ref) {
  return APIType.deepSeek.host;
}, name: "deepSeekApiServerAddressProvider");

