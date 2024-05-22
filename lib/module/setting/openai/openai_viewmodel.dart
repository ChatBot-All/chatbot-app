import 'package:chat_bot/hive_bean/openai_bean.dart';
import 'package:chat_bot/utils/icloud_async.dart';

import '../../../base.dart';
import '../../../hive_bean/local_chat_history.dart';
import '../../../hive_bean/supported_models.dart';
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
    StateNotifierProvider.family<OpenAIListNotify, AsyncValue<List<AllModelBean>>, APIType>((ref, apiType) {
  return OpenAIListNotify(ref, apiType);
});

class OpenAIListNotify extends StateNotifier<AsyncValue<List<AllModelBean>>> {
  final StateNotifierProviderRef ref;
  final APIType apiType;

  OpenAIListNotify(this.ref, this.apiType) : super(const AsyncValue.loading()) {
    load();
  }

  Future updateModelType(int time, String modelTypeName) async {
    var openAi = HiveBox().openAIConfig.get(time.toString());
    if (openAi == null) {
      return;
    }
    openAi.supportedModels ??= [];
    //查看模型是否存在
    var exist = openAi.supportedModels?.any((element) => element.id == modelTypeName) ?? false;
    if (exist) {
      "${S.current.model} ${S.current.has_exist}".fail();
      return;
    }
    openAi.supportedModels?.add(SupportedModels(id: modelTypeName, ownedBy: "user"));
    await HiveBox().openAIConfig.put(time.toString(), openAi);
    await ICloudAsync().startAsync();
    load();
  }

  Future<bool> add(AllModelBean openAi, {bool needAsync = true, bool needReload = true}) async {
    //校验别名是否重复
    if (HiveBox().openAIConfig.values.toList().where((element) => element.alias == openAi.alias).isNotEmpty) {
      S.current.alias_repeat.fail();
      return false;
    }
    //apiKey不能重复
    if (HiveBox().openAIConfig.values.toList().where((element) => element.apiKey == openAi.apiKey).isNotEmpty) {
      S.current.apikey_repeat.fail();
      return false;
    }
    var defApiKey = getDefaultApiKey();
    if (defApiKey.isEmpty) {
      setDefaultApiKey(openAi.apiKey ?? "");
    }
    await HiveBox().openAIConfig.put(openAi.time.toString(), openAi);
    if (needAsync) {
      await ICloudAsync().startAsync();
    }
    if (needReload) {
      load();
    }
    return true;
  }

  void remove(AllModelBean openAi) async {
    await HiveBox().openAIConfig.delete(openAi.time.toString());
    var defApiKey = getDefaultApiKey();
    if (defApiKey == openAi.apiKey) {
      if (HiveBox().openAIConfig.values.isEmpty) {
        setDefaultApiKey("");
      } else {
        setDefaultApiKey(HiveBox().openAIConfig.values.first.apiKey ?? "");
      }
    }
    await ICloudAsync().uploadDirectly();
    load();
  }

  Future<bool> update(AllModelBean openAi, {bool needAsync = true, bool needReload = true}) async {
    await HiveBox().openAIConfig.put(openAi.time.toString(), openAi);
    if (needAsync) {
      await ICloudAsync().startAsync();
    }
    if (needReload) {
      await load();
    }
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
