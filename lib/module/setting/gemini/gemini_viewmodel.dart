import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:hive/hive.dart';

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

final geminiListProvider = StateNotifierProvider.autoDispose<GeminiListNotify, AsyncValue<List<AllModelBean>>>((ref) {
  return GeminiListNotify(ref);
});

class GeminiListNotify extends StateNotifier<AsyncValue<List<AllModelBean>>> {
  final AutoDisposeStateNotifierProviderRef ref;

  GeminiListNotify(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  List<AllModelBean>? get list => state.value;

  bool add(AllModelBean openAi) {
    //校验别名是否重复
    if (state.value?.where((element) => element.alias == openAi.alias).isNotEmpty ?? false) {
      "别名不可以重复".fail();
      return false;
    }

    //apiKey不能重复
    if (state.value?.where((element) => element.apiKey == openAi.apiKey).isNotEmpty ?? false) {
      "apiKey不可以重复".fail();
      return false;
    }
    var defApiKey = getDefaultApiKey();
    if (defApiKey.isEmpty) {
      setDefaultApiKey(openAi.apiKey ?? "");
    }
    HiveBox().openAIConfig.put(openAi.time.toString(), openAi);
    load();
    return true;
  }

  void remove(AllModelBean openAi) {
    HiveBox().openAIConfig.delete(openAi.time.toString());
    var defApiKey = getDefaultApiKey();
    if (defApiKey == openAi.apiKey) {
      if (HiveBox().openAIConfig.values.isEmpty) {
        setDefaultApiKey("");
      } else {
        setDefaultApiKey(HiveBox().openAIConfig.values.first.apiKey ?? "");
      }
    }
    load();
  }

  bool update(AllModelBean openAi) {
    HiveBox().openAIConfig.put(openAi.time.toString(), openAi);
    load();
    return true;
  }

  void clear() {
    state = const AsyncValue.data([]);
    HiveBox().openAIConfig.clear();
  }

  Future<void> load() async {
    state = await AsyncValue.guard(() async {
      var list = HiveBox().openAIConfig.values.where((element) => element.model == APIType.gemini.code).toList();
      ref.watch(geminiCountProvider.notifier).state = list.length;
      return list;
    });
  }
}

final geminiCountProvider = StateProvider<int>((ref) {
  return HiveBox().openAIConfig.values.where((element) => element.model == APIType.gemini.code).length;
});
