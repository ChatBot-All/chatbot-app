import 'dart:convert';

import 'package:ChatBot/base/api.dart';
import 'package:ChatBot/base/api_impl/api_impl.dart';
import 'package:ChatBot/hive_bean/generate_content.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

import '../../base.dart';
import '../db/chat_item.dart';

class GeminiImpl extends APIImpl {
  /// 单例
  static GeminiImpl? _instance;

  factory GeminiImpl() => _instance ??= GeminiImpl._();

  GeminiImpl._();

  @override
  Future<GenerateContentBean> generateContent(
    double temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
  ) async {
    initAPI(bean);

    var contents = chatItems
        .map((e) => Content(
            parts: e.content.map((e) => Parts(text: e)).toList(),
            role: e.role != ChatType.bot.index ? 'user' : 'model'))
        .toList();

    var content = (await Gemini.instance.chat(contents, modelName: modelType));
    return GenerateContentBean(content: content?.content?.parts?.last.text ?? '');
  }

  @override
  Future<List<SupportedModels>> getSupportModules(AllModelBean bean) async {
    try {
      initAPI(bean);
      await Future.delayed(const Duration(milliseconds: 100));
      var models = await Gemini.instance.listModels();
      eDismiss();
      return models.map((e) => SupportedModels(ownedBy: e.version, id: e.name)).toList();
    } on RequestFailedException catch (e) {
      e.message.fail();
      return [];
    } catch (e) {
      e.toString().fail();
      return [];
    }
  }

  @override
  Future<void> initAPI(AllModelBean bean) async {
    Gemini.init(
      apiKey: bean.apiKey ?? "",
      baseURL: "${bean.apiServer}/",
      enableDebugging: kDebugMode,
    );
  }

  @override
  Future<Stream<GenerateContentBean>> streamGenerateContent(
    String temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
    bool withoutHistoryMessage,
  ) async {
    initAPI(bean);
    RequestParams lastOneMessage = chatItems.last;
    if (lastOneMessage.images.isNotEmpty && lastOneMessage.images.where((element) => element.isNotEmpty).isNotEmpty) {
      return Stream.fromFuture(Gemini.instance
          .textAndImage(
        text: lastOneMessage.content.last,
        modelName: modelType,
        images: lastOneMessage.images.map((e) => base64Decode(e)).toList(),
      )
          .then((value) {
        return GenerateContentBean(content: value?.content?.parts?.last.text ?? '');
      }));
    } else {
      var contents = chatItems
          .map((e) => Content(
              parts: e.content.map((e) => Parts(text: e)).toList(),
              role: e.role != ChatType.bot.index ? 'user' : 'model'))
          .toList();

      return Gemini.instance
          .streamChat(contents, modelName: modelType)
          .map((event) => GenerateContentBean(content: event.content?.parts?.last.text));
    }
  }

  @override
  Future<File?> text2TTS(AllModelBean bean, String content, String voice) {
    throw UnimplementedError();
  }

  @override
  Future<String?> tts2Text(AllModelBean bean, String ttsFile) {
    throw UnimplementedError();
  }

  @override
  Future<bool> validateApiKey(AllModelBean bean) async {
    try {
      Gemini gemini = Gemini.init(
        apiKey: bean.apiKey ?? "",
        baseURL: "${bean.apiServer}/",
        enableDebugging: kDebugMode,
      );
      await Future.delayed(const Duration(milliseconds: 100));
      var models = await gemini.listModels();
      eDismiss();
      return models.isNotEmpty;
    } on RequestFailedException catch (e) {
      e.message.fail();
      return false;
    } catch (e) {
      e.toString().fail();
      return false;
    }
  }

  @override
  Future<List<OpenAIImageData>> generateOpenAIImage(
      AllModelBean bean, String prompt, OpenAIImageStyle style, OpenAIImageSize size) {
    throw UnimplementedError();
  }

  @override
  Future<String> generateChatTitle(
    String temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
  ) async {
    try {
      Gemini gemini = Gemini.init(
        apiKey: bean.apiKey ?? "",
        baseURL: "${bean.apiServer}/",
        enableDebugging: kDebugMode,
        generationConfig: GenerationConfig(
          temperature: double.tryParse(temperature) ?? 1.0,
        ),
      );

      if (chatItems.length >= 2) {
        chatItems = chatItems.sublist(0, 2);
      }

      chatItems.add(RequestParams(
        role: 0,
        content: [S.current.title_promot],
        images: [],
      ));

      var contents = chatItems
          .map((e) => Content(
              parts: e.content.map((e) => Parts(text: e)).toList(),
              role: e.role != ChatType.bot.index ? 'user' : 'model'))
          .toList();

      var result = await gemini.chat(contents, modelName: modelType);
      return result?.content?.parts?.last.text ?? "";
    } on RequestFailedException catch (e) {
      e.message.fail();
      return S.current.new_chat;
    } catch (e) {
      e.toString().fail();
      return chatItems.first.content.first;
    }
  }
}
