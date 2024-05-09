import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/api_impl/ollama_impl.dart';
import 'package:ChatBot/hive_bean/generate_content.dart';
import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:dart_openai/dart_openai.dart';

import 'api_impl/api_impl.dart';
import 'api_impl/chatgpt_impl.dart';
import 'api_impl/gemini_impl.dart';
import 'db/chat_item.dart';

class RequestParams {
  final int role;
  final List<String> content;
  final List<String> images;

  RequestParams({required this.role, required this.content, required this.images});

  @override
  String toString() {
    return 'RequestParams{role: $role, content: ${content.map((e) => e.substring(0, 1)).toList()}, images: $images}';
  }
}

class API extends APIImpl {
  //单例
  static final API _instance = API._internal();

  factory API() => _instance;

  API._internal();

  final Map<int, APIImpl> _apiImpl = {
    APIType.openAI.code: ChatGPTImpl(),
    APIType.gemini.code: GeminiImpl(),
    APIType.ollama.code: OllamaImpl(),
  };

  @override
  Future<String> generateChatTitle(String temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) async {
    var list = generateChatTitleListParams(originalChatItem);

    return _apiImpl[bean.model ?? APIType.openAI.code]!
        .generateChatTitle(temperature, bean, modelType, originalChatItem, list);
  }

  @override
  Future<GenerateContentBean> generateContent(double temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) {
    var requestParams = generateChatHistory(originalChatItem, false);

    return _apiImpl[bean.model ?? APIType.openAI.code]!
        .generateContent(temperature, bean, modelType, originalChatItem, requestParams);
  }

  @override
  Future<List<OpenAIImageData>> generateOpenAIImage(
      AllModelBean bean, String prompt, OpenAIImageStyle style, OpenAIImageSize size) {
    return _apiImpl[bean.model ?? APIType.openAI.code]!.generateOpenAIImage(bean, prompt, style, size);
  }

  @override
  Future<List<SupportedModels>> getSupportModules(AllModelBean bean) {
    return _apiImpl[bean.model ?? APIType.openAI.code]!.getSupportModules(bean);
  }

  @override
  Future<void> initAPI(AllModelBean bean) {
    return _apiImpl[bean.model ?? APIType.openAI.code]!.initAPI(bean);
  }

  @override
  Future<Stream<GenerateContentBean>> streamGenerateContent(
    String temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
    bool withoutHistoryMessage,
  ) {
    var requestParams = generateChatHistory(originalChatItem, withoutHistoryMessage);

    return _apiImpl[bean.model ?? APIType.openAI.code]!
        .streamGenerateContent(temperature, bean, modelType, originalChatItem, requestParams, withoutHistoryMessage);
  }

  @override
  Future<File?> text2TTS(AllModelBean bean, String content, String voice) {
    return _apiImpl[bean.model ?? APIType.openAI.code]!.text2TTS(bean, content, voice);
  }

  @override
  Future<String?> tts2Text(AllModelBean bean, String ttsFile) {
    return _apiImpl[bean.model ?? APIType.openAI.code]!.tts2Text(bean, ttsFile);
  }

  @override
  Future<bool> validateApiKey(AllModelBean bean) {
    return _apiImpl[bean.model ?? APIType.openAI.code]!.validateApiKey(bean);
  }
}

OpenAIChatMessageRole getTypeByRole(int type) {
  if (type == ChatType.user.index) {
    return OpenAIChatMessageRole.user;
  } else if (type == ChatType.bot.index) {
    return OpenAIChatMessageRole.assistant;
  } else {
    return OpenAIChatMessageRole.user;
  }
}
