import 'package:ChatBot/base/db/prompt_item.dart';

import '../../base.dart';

final promptListProvider = StateNotifierProvider.autoDispose<PromptListNotify, AsyncValue<List<PromptItem>>>((ref) {
  return PromptListNotify(const AsyncValue.loading());
});

class PromptListNotify extends StateNotifier<AsyncValue<List<PromptItem>>> {
  PromptListNotify(AsyncValue<List<PromptItem>> state) : super(state) {
    load();
  }

  void addPrompt(PromptItem promptItem) {
    PromptItemProvider().insert(promptItem);
    load();
  }

  void removePrompt(PromptItem promptItem) {
    PromptItemProvider().delete(promptItem.time!);
    load();
  }

  void updatePrompt(PromptItem promptItem) {
    PromptItemProvider().update(promptItem);
    load();
  }

  Future<void> load() async {
    state = await AsyncValue.guard(() => PromptItemProvider().list());
  }
}
