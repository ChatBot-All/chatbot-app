import 'package:ChatBot/hive_bean/local_chat_history.dart';

import '../../../base.dart';
import '../../../utils/hive_box.dart';

final geminiApiServerHistoryProvider =
    StateNotifierProvider.autoDispose<GeminiApiServerHistoryNotify, List<String>>((ref) {
  return GeminiApiServerHistoryNotify();
}, name: "geminiApiServerHistoryProvider");

final geminiApiServerAddressProvider = StateProvider.autoDispose<String>((ref) {
  return "https://generativelanguage.googleapis.com";
}, name: "geminiApiServerAddressProvider");

class GeminiApiServerHistoryNotify extends StateNotifier<List<String>> {
  GeminiApiServerHistoryNotify() : super([]) {
    load();
  }

  void add(String? server) {
    if (server == null) {
      return;
    }
    if (state.contains(server)) {
      return;
    }

    state = [...state, server];
    HiveBox().geminiApiServerHistory.put(server, server);
  }

  void remove(String server) {
    state.removeWhere((element) => element == server);
    state = [...state];
    HiveBox().geminiApiServerHistory.delete(server);
  }

  void update(String server) {
    state.removeWhere((element) => element == server);
    state = [...state, server];
    HiveBox().geminiApiServerHistory.put(server, server);
  }

  void clear() {
    state = [];
    HiveBox().geminiApiServerHistory.clear();
  }

  void load() {
    var result = HiveBox().geminiApiServerHistory.values.toList();
    state = ["https://generativelanguage.googleapis.com", ...result];
  }
}
