import 'package:ChatBot/hive_bean/openai_bean.dart';

import '../../../base.dart';
import '../../../hive_bean/local_chat_history.dart';
import '../../../utils/hive_box.dart';
import '../gemini/gemini_viewmodel.dart';

final apiServerHistoryProvider = StateNotifierProvider.autoDispose<ApiServerHistoryNotify, List<String>>((ref) {
  return ApiServerHistoryNotify();
}, name: "apiServerHistoryProvider");

final apiServerAddressProvider = StateProvider.autoDispose<String>((ref) {
  return "https://api.openai.com";
}, name: "apiServerAddressProvider");

class DefaultServerApiKeyProviderNotify extends StateNotifier<String> {
  DefaultServerApiKeyProviderNotify() : super("") {
    load();
  }

  void load() {
    state = HiveBox().appConfig.get(HiveBox.cDefaultApiServerKey) ?? "";
  }

  String get defaultKey => state;

  void update(String? key) {
    state = key ?? "";
    HiveBox().appConfig.put(HiveBox.cDefaultApiServerKey, key ?? "");
  }
}

class ApiServerHistoryNotify extends StateNotifier<List<String>> {
  ApiServerHistoryNotify() : super([]) {
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
    HiveBox().apiServerHistory.put(server, server);
  }

  void remove(String server) {
    state.removeWhere((element) => element == server);
    state = [...state];
    HiveBox().apiServerHistory.delete(server);
  }

  void update(String server) {
    state.removeWhere((element) => element == server);
    state = [...state, server];
    HiveBox().apiServerHistory.put(server, server);
  }

  void clear() {
    state = [];
    HiveBox().apiServerHistory.clear();
  }

  void load() {
    var result = HiveBox().apiServerHistory.values.toList();
    state = ["https://api.openai.com", ...result];
  }
}

final openAiListProvider =
    StateNotifierProvider.family.autoDispose<OpenAIListNotify, AsyncValue<List<AllModelBean>>, APIType>((ref, apiType) {
  return OpenAIListNotify(ref, apiType);
});

class OpenAIListNotify extends StateNotifier<AsyncValue<List<AllModelBean>>> {
  final AutoDisposeStateNotifierProviderRef ref;
  final APIType apiType;

  OpenAIListNotify(this.ref, this.apiType) : super(const AsyncValue.loading()) {
    load();
  }

  bool add(AllModelBean openAi) {
    //校验别名是否重复
    if (state.value?.where((element) => element.alias == openAi.alias).isNotEmpty ?? false) {
      S.current.alias_repeat.fail();
      return false;
    }
    //apiKey不能重复
    if (state.value?.where((element) => element.apiKey == openAi.apiKey).isNotEmpty ?? false) {
      S.current.apikey_repeat.fail();
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

  List<AllModelBean>? get list => state.value;

  Future<void> load() async {
    state = await AsyncValue.guard(() async {
      var list = HiveBox().openAIConfig.values.where((element) => element.model == apiType.code).toList();
      ref.watch(specialModelCountProvider(apiType).notifier).state = list.length;
      return list;
    });
  }
}

final specialModelCountProvider = StateProvider.family<int, APIType>((ref, type) {
  return HiveBox().openAIConfig.values.where((element) => element.model == type.code).length;
});
