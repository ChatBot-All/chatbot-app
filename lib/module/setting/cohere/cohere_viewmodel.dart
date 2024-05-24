import 'package:chat_bot/hive_bean/local_chat_history.dart';

import '../../../base.dart';

final cohereApiServerAddressProvider =
    StateProvider.autoDispose<String>((ref) {
  return APIType.coHere.host;
}, name: "cohereApiServerAddressProvider");
