import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:hive_flutter/adapters.dart';

class HiveBox {
  static const String cAppConfig = 'appConfig';
  static const String cAppConfigDefaultApiServerKey = 'defaultApiServerKey';
  static const String cChatHistory = 'chatHistory';
  static const String cOpenAIConfig = 'openAIConfig';
  static const String cDefaultApiServerKey = 'defaultApiServerKey';
  static const String cDefaultTemperature = 'defaultTemperature';

  static const String cApiServerHistory = 'apiServerHistory'; //OPENAI 添加第三方服务器历史记录
  static const String cGeminiApiServerHistory = 'geminiApiServerHistory'; //OPENAI 添加第三方服务器历史记录
  ///子key
  static const String cAppConfigAutoGenerateTitle = 'autoGenerateTitle';

  Box<String> get appConfig => _appConfig;

  Box<ChatParentItem> get chatHistory => _chatHistory;

  Box<AllModelBean> get openAIConfig => _openAIConfig;

  Box<String> get apiServerHistory => _apiServerHistory;

  Box<String> get geminiApiServerHistory => _geminiApiServerHistory;

  String get temperature => _appConfig.get(cDefaultTemperature, defaultValue: "0.5") ?? "0.5";

  late Box<String> _appConfig;
  late Box<String> _apiServerHistory;
  late Box<String> _geminiApiServerHistory;
  late Box<AllModelBean> _openAIConfig;
  late Box<ChatParentItem> _chatHistory;

  static final HiveBox _instance = HiveBox._internal();

  factory HiveBox() {
    return _instance;
  }

  HiveBox._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ChatParentItemAdapter());
    Hive.registerAdapter(AllModelBeanAdapter());
    Hive.registerAdapter(SupportedModelsAdapter());
    _appConfig = await Hive.openBox(cAppConfig);
    _chatHistory = await Hive.openBox(cChatHistory);
    _openAIConfig = await Hive.openBox(cOpenAIConfig);
    _apiServerHistory = await Hive.openBox(cApiServerHistory);
    _geminiApiServerHistory = await Hive.openBox(cGeminiApiServerHistory);
  }
}
