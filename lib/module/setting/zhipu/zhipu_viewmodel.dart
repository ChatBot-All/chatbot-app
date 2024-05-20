import 'package:chat_bot/hive_bean/local_chat_history.dart';

import '../../../base.dart';

final zhiPuApiServerAddressProvider = StateProvider.autoDispose<String>((ref) {
  return APIType.zhipu.host;
}, name: "zhiPuApiServerAddressProvider");

