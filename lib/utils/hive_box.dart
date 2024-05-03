import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:hive_flutter/adapters.dart';

import '../base/theme.dart';
import '../const.dart';

class HiveBox {
  static const String cAppConfig = 'appConfig';
  static const String cAppConfigDefaultApiServerKey = 'defaultApiServerKey';
  static const String cChatHistory = 'chatHistory';
  static const String cOpenAIConfig = 'openAIConfig';
  static const String cDefaultApiServerKey = 'defaultApiServerKey'; //默认的模型的key
  static const String cDefaultTemperature = 'defaultTemperature'; //默认的温度参数

  static const String cApiServerHistory = 'apiServerHistory'; //OPENAI 添加第三方服务器历史记录
  static const String cGeminiApiServerHistory = 'geminiApiServerHistory'; //OPENAI 添加第三方服务器历史记录
  ///子key
  static const String cAppConfigAutoGenerateTitle = 'autoGenerateTitle'; //自动生成标题
  static const String cAppConfigFromLanguage = 'fromLanguage'; //翻译默认的语言
  static const String cAppConfigToLanguage = 'toLanguage'; //翻译默认的目标语言
  static const String cAppConfigGlobalLanguageCode = 'globalLanguageCode'; //默认语言

  Box<String> get appConfig => _appConfig;

  Box<ChatParentItem> get chatHistory => _chatHistory;

  Box<AllModelBean> get openAIConfig => _openAIConfig;

  Box<String> get apiServerHistory => _apiServerHistory;

  Box<String> get geminiApiServerHistory => _geminiApiServerHistory;

  String get temperature => _appConfig.get(cDefaultTemperature, defaultValue: "0.5") ?? "0.5";

  String get fromLanguage =>
      _appConfig.get(cAppConfigFromLanguage, defaultValue: getLocaleLanguages()['zh-Hans']!) ??
          getLocaleLanguages()['zh-Hans']!;

  String get toLanguage =>
      _appConfig.get(cAppConfigToLanguage, defaultValue: getLocaleLanguages()['en']!) ?? getLocaleLanguages()['en']!;

  String get globalLanguageCode =>
      _appConfig.get(cAppConfigGlobalLanguageCode, defaultValue: 'auto') ?? 'en';

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
