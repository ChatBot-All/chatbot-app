

import '../../../base.dart';
import '../../../hive_bean/openai_bean.dart';
import '../../../utils/hive_box.dart';

final allModelListProvider = StateNotifierProvider.autoDispose<AllModelListNotify, AsyncValue<List<AllModelBean>>>((ref) {
  return AllModelListNotify(ref);
});

class AllModelListNotify extends StateNotifier<AsyncValue<List<AllModelBean>>> {
  final AutoDisposeStateNotifierProviderRef ref;

  AllModelListNotify(this.ref) : super(const AsyncValue.loading()) {
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

    if (state.value == null || state.value!.isEmpty) {
      setDefaultApiKey(openAi.apiKey ?? "");
    }
    state = AsyncValue.data([...state.value!, openAi]);
    HiveBox().openAIConfig.put(openAi.apiKey, openAi);
    return true;
  }

  void remove(AllModelBean openAi) {
    state.value?.removeWhere((element) => element.apiKey == openAi.apiKey);
    state = AsyncValue.data(state.value ?? []);
    var defApiKey = getDefaultApiKey();

    if (defApiKey == openAi.apiKey) {
      setDefaultApiKey(state.value?.first.apiKey ?? "");
    }
    HiveBox().openAIConfig.delete(openAi.apiKey);
    load();
  }

  bool update(AllModelBean openAi) {
    state.value?.removeWhere((element) => element.apiKey == openAi.apiKey);
    state = AsyncValue.data([...state.value ?? [], openAi]);
    HiveBox().openAIConfig.put(openAi.apiKey, openAi);
    return true;
  }

  void clear() {
    state = const AsyncValue.data([]);
    HiveBox().openAIConfig.clear();
  }

  Future<void> load() async {
    state = await AsyncValue.guard(() async {
      return HiveBox().openAIConfig.values.toList();
    });
  }
}
