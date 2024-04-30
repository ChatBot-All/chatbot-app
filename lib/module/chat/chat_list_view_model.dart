import 'package:ChatBot/base/db/chat_item.dart';
import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/utils/hive_box.dart';

import '../../base.dart';

///全局生成图片使用的parentID
var specialGenerateImageChatParentItemTime = 100000;

///全局随便聊聊使用的parentID
var specialGenerateTextChatParentItemTime = 100001;

///全局语音聊天使用的parentID
var specialGenerateAudioChatParentItemTime = 100002;

///全局翻译聊天使用的parentID
var specialGenerateTranslateChatParentItemTime = 100003;

final chatParentListProvider = StateNotifierProvider<ChatParentListNotify, AsyncValue<List<ChatParentItem>>>((ref) {
  return ChatParentListNotify(const AsyncValue.loading(), ref);
});

class ChatParentListNotify extends StateNotifier<AsyncValue<List<ChatParentItem>>> {
  final StateNotifierProviderRef ref;

  ChatParentListNotify(super.state, this.ref) {
    load();
  }

  void add(ChatParentItem chatParentItem) {
    HiveBox().chatHistory.put(chatParentItem.idKey, chatParentItem);
    load();
  }

  List<ChatParentItem>? get list => state.value;

  void remove(ChatParentItem chatParentItem) {
    ChatItemProvider().deleteAll(chatParentItem.id ?? 0);
    HiveBox().chatHistory.delete(chatParentItem.idKey);
    load();
  }

  void update(ChatParentItem chatParentItem) async {
    HiveBox().chatHistory.put(chatParentItem.idKey, chatParentItem);
    load();
  }

  void clear() {
    state = const AsyncValue.data([]);
    HiveBox().chatHistory.clear();
  }

  Future<void> load() async {
    state = await AsyncValue.guard(() async {
      try {
        var list = HiveBox().chatHistory.values.toList();
        var openAIs = HiveBox().openAIConfig.values.toList();

        //检查list中的openAI字段是否真的存在，不存在则设置为空
        for (var i = 0; i < list.length; i++) {
          var openAI = getModelByApiKey(list[i].apiKey!);
          if (openAI.apiKey == null || openAIs.isEmpty) {
            list[i].apiKey = null;
          }
        }

        //再查找最新的一条消息记录
        for (var i = 0; i < list.length; i++) {
          var chatItem = await ChatItemProvider().getLatestChatItem(list[i].id ?? 0);
          list[i].chatItem = chatItem;
        }

        list.removeWhere((element) => element.id == specialGenerateTextChatParentItemTime);
        return list;
      } catch (e) {
        HiveBox().chatHistory.clear();
        return [];
      }
    });
  }

  void pin(ChatParentItem item) {
    item.pin = !(item.pin ?? false);
    update(item);
  }
}
