import 'package:chat_bot/hive_bean/local_chat_history.dart';

import '../../../base.dart';

final zeroOneApiServerAddressProvider =
    StateProvider.autoDispose<String>((ref) {
  return APIType.zeroOne.host;
}, name: "zeroOneApiServerAddressProvider");
