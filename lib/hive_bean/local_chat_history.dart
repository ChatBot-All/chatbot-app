import 'package:hive/hive.dart';

import '../base/db/chat_item.dart';

part 'local_chat_history.g.dart';

///moduleName 1是OPENAI， 2是gemini
enum APIType {
  openAI(1, "ChatGPT","api.openai.com"),
  gemini(2, "Gemini","generativelanguage.googleapis.com"),
  ollama(3, "Ollama","/");

  final int code;
  final String name;
  final String host;

  const APIType(this.code, this.name,this.host);

  static APIType fromCode(int code) {
    return APIType.values.firstWhere((element) => element.code == code,orElse: () => APIType.openAI);
  }
}

enum ChatParentItemType {
  text(0, "文本"),
  voice(1, "语音");

  final int code;
  final String name;

  const ChatParentItemType(this.code, this.name);

  static ChatParentItemType fromCode(int code) {
    switch (code) {
      case 1:
        return ChatParentItemType.text;
      case 2:
        return ChatParentItemType.voice;
      default:
        return ChatParentItemType.text;
    }
  }
}

///消息列表页面
@HiveType(typeId: 0)
class ChatParentItem {
  @HiveField(3)
  String? moduleType; //模型版本
  @HiveField(2)
  int? moduleName; //服务商
  @HiveField(6)
  String? apiKey; //API Key
  @HiveField(1)
  String? title; //标题
  @HiveField(0)
  int? id; //id主键
  @HiveField(7)
  String? temperature = "1.0";

  @HiveField(8)
  int? historyMessageCount = 4;

  @HiveField(9)
  bool? pin = false; //是否置顶

  @HiveField(10)
  int? chatParentType = ChatParentItemType.text.code; //0是普通聊天，1是语音聊天

  ChatItem? chatItem; //最后一条消息

  String get idKey => id.toString();

  ChatParentItem({
    this.moduleType,
    this.id,
    this.moduleName,
    this.pin,
    this.title,
    this.chatItem,
    this.apiKey,
    this.temperature,
    this.historyMessageCount,
    this.chatParentType,
  });

  ChatParentItem copyWith({
    String? moduleType,
    int? id,
    int? moduleName,
    String? title,
    String? apiKey,
    String? temperature,
    int? historyMessageCount,
    ChatItem? chatItem,
    int? chatParentType,
    bool? pin,
  }) {
    return ChatParentItem(
      moduleType: moduleType ?? this.moduleType,
      id: id ?? this.id,
      moduleName: moduleName ?? this.moduleName,
      title: title ?? this.title,
      pin: pin ?? this.pin,
      chatItem: chatItem ?? this.chatItem,
      apiKey: apiKey ?? this.apiKey,
      temperature: temperature?.toString() ?? this.temperature,
      historyMessageCount: historyMessageCount ?? this.historyMessageCount,
      chatParentType: chatParentType ?? this.chatParentType,
    );
  }
}
