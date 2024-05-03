import 'dart:convert';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/api.dart';
import 'package:ChatBot/base/api_impl/api_impl.dart';
import 'package:ChatBot/base/db/chat_item.dart';
import 'package:ChatBot/hive_bean/generate_content.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../api_bean/claude_content_bean.dart';

class ClaudeImpl extends APIImpl {
  //单例
  static final ClaudeImpl _instance = ClaudeImpl._internal();

  factory ClaudeImpl() => _instance;

  ClaudeImpl._internal();

  Dio? _dio;
  final splitter = const LineSplitter();

  @override
  Future<String> generateChatTitle(String temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) async {
    var result =
        await generateContent(double.tryParse(temperature) ?? 1.0, bean, modelType, originalChatItem, chatItems);
    return result.content ?? "";
  }

  @override
  Future<GenerateContentBean> generateContent(double temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) async {
    initAPI(bean);

    var params = chatItems
        .map((e) => {
              "role": e.role == ChatType.bot.index ? "assistant" : "user",
              "top_p": 1,
              "temperature": temperature,
              "content": [
                if (e.images.isNotEmpty)
                  e.images.map((e) => {
                        "type": "image",
                        "source": {
                          "type": "base64",
                          "media_type": "image/jpeg",
                          "data": e,
                        }
                      }),
                if (e.content.isNotEmpty)
                  e.content.map((e) => {
                        "type": "text",
                        "text": e,
                      }),
              ],
            })
        .toList();

    var result = await _dio!.post("/v1/messages", data: {
      "model": modelType,
      "max_tokens": 1024,
      "messages": params,
    });

    if (result.statusCode == 200) {
      var json = result.data;

      var data = ClaudeContentBean.fromJson(json);
      return GenerateContentBean(
        content: data.content?.first.text ?? "",
      );
    } else {
      throw Exception("Failed to generate content");
    }
  }

  @override
  Future<List<OpenAIImageData>> generateOpenAIImage(
      AllModelBean bean, String prompt, OpenAIImageStyle style, OpenAIImageSize size) {
    throw UnimplementedError();
  }

  @override
  Future<List<SupportedModels>> getSupportModules(AllModelBean bean) async {
    try {
      var result = await generateContent(1.0, bean, "Claude 3 Haiku", [], [
        RequestParams(role: ChatType.user.index, content: ["hello, Claude"], images: [])
      ]);
      eDismiss();
      if (result.content != null && result.content!.isNotEmpty) {
        return [
          SupportedModels(
            id: "Claude 3 Haiku",
            ownedBy: "Claude",
          ),
          SupportedModels(
            id: "Claude 3 Sonnet",
            ownedBy: "Claude",
          ),
          SupportedModels(
            id: "Claude 3 Opus",
            ownedBy: "Claude",
          ),
        ];
      }
      return [];
    } catch (e) {
      e.toString().fail();
      return [];
    }
  }

  @override
  Future<void> initAPI(AllModelBean bean) async {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 600),
      headers: {
        "x-api-key": "${bean.apiKey}",
        "Content-Type": "application/json",
        "anthropic-version": "2023-06-01",
      },
    ));
    _dio!.interceptors.add(PrettyDioLogger());
  }

  @override
  Future<Stream<GenerateContentBean>> streamGenerateContent(String temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems, bool withoutHistoryMessage) async {
    initAPI(bean);

    var params = chatItems
        .map((e) => {
              "role": e.role == ChatType.bot.index ? "assistant" : "user",
              "content": [
                if (e.images.isNotEmpty)
                  e.images.map((e) => {
                        "type": "image",
                        "source": {
                          "type": "base64",
                          "media_type": "image/jpeg",
                          "data": e,
                        }
                      }),
                if (e.content.isNotEmpty)
                  e.content.map((e) => {
                        "type": "text",
                        "text": e,
                      }),
              ],
            })
        .toList();
    var response = await _dio!.post(
      "/v1/messages",
      data: params,
      options: Options(responseType: ResponseType.stream),
    );
    throw UnimplementedError();
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
      var result = await generateContent(1.0, bean, "Claude 3 Haiku", [], [
        RequestParams(role: ChatType.user.index, content: ["hello, Claude"], images: [])
      ]);
      eDismiss();
      if (result.content != null && result.content!.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
