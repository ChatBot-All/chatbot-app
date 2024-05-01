import 'package:ChatBot/hive_bean/openai_bean.dart';
import '../../../base.dart';
import '../../../base/db/chat_item.dart';
import '../../../hive_bean/local_chat_history.dart';

///语音模式，还是录入文字模式
final inputModeProvider = StateProvider.autoDispose<bool>((ref) {
  return true;
});

///当前是发送按钮，还是选择图片按钮
final sendButtonVisibleProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

///是否正在生成内容
final isGeneratingContentProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});

///当前的聊天Parent信息，只有ChatParentItem真实存在才有数据，像special相关的id是没有数据的
final currentChatParentItemProvider = StateProvider.autoDispose<ChatParentItem?>((ref) {
  return null;
});

///生成图片页面正在使用的模型
final currentGenerateImageModelProvider = StateProvider<AllModelBean?>((ref) {
  return null;
});

///语音聊天页面正在使用的模型
final currentGenerateAudioChatModelProvider = StateProvider<AllModelBean?>((ref) {
  return null;
});


///语音聊天中的文本解析模型
final currentGenerateAudioChatTextParserProvider = StateProvider<AllModelBean?>((ref) {
  return null;
});


///语音聊天页面正在使用的模型
final currentGenerateTranslateChatModelProvider = StateProvider<AllModelBean?>((ref) {
  return null;
});

///当前的聊天信息正在选择的图片列表
final imagesProvider = StateProvider<List<String>>((ref) {
  return [];
});

///针对parentID所关联的所有的聊天信息
final chatProvider =
    StateNotifierProvider.autoDispose.family<ChatNotify, AsyncValue<List<ChatItem>>, int>((ref, parentID) {
  return ChatNotify(const AsyncValue.loading(), ref, parentID);
});

class ChatNotify extends StateNotifier<AsyncValue<List<ChatItem>>> {
  final AutoDisposeStateNotifierProviderRef ref;
  final int parentID;

  ChatNotify(super.state, this.ref, this.parentID) {
    loadData();
  }

  List<ChatItem> add(ChatItem chatItem) {
    state = AsyncValue.data([...state.value ?? [], chatItem]);
    ChatItemProvider().insert(chatItem);
    return state.value ?? [];
  }

  List<ChatItem> get chats => state.value ?? [];

  void remove(ChatItem chatItem, {bool connectOtherTimeID = false}) async {
    state.value?.removeWhere((element) => element.time == chatItem.time);

    state = AsyncValue.data(state.value ?? []);
    await ChatItemProvider().delete(chatItem.time ?? 0);
    if (connectOtherTimeID) {
      state.value?.removeWhere((element) => element.requestID == chatItem.time);

      state = AsyncValue.data(state.value ?? []);
      await ChatItemProvider().deleteRequestIDByTime(chatItem.time ?? 0);
    }
  }

  void update(ChatItem chatItem) async {
    state.value?.removeWhere((element) => element.time == chatItem.time);
    state = AsyncValue.data([...state.value ?? [], chatItem]);
    await ChatItemProvider().update(chatItem);
  }

  void clear() async {
    state = const AsyncValue.data([]);
    await ChatItemProvider().deleteAll(parentID);
  }

  void loadData() async {
    state = await AsyncValue.guard(() async {
      return await ChatItemProvider().getChatItems(parentID);
    });
  }

  @override
  void dispose() {
    //把数据库所有的状态为0的全部置为3，用户关闭了页面，所有正在请求的内容将被移除，异常状态会被重置为错误的状态
    ChatItemProvider().updateStatus(parentID, 0, 3);
    super.dispose();
  }
}
