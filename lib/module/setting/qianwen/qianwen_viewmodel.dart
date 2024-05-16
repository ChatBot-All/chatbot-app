import '../../../base.dart';

final qianwenApiServerAddressProvider = StateProvider.autoDispose<String>((ref) {
  return "https://dashscope.aliyuncs.com";
}, name: "qianwenApiServerAddressProvider");

