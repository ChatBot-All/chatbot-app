import 'dart:convert';
import 'dart:io';

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

class OllamaImpl extends APIImpl {
  @override
  Future<String> generateChatTitle(String temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) async {
    Dio dio = initOllama(bean);

    var response = await dio.post("/api/chat", data: {
      "model": modelType,
      "messages": [
        ...chatItems
            .map((e) => {
                  "role": e.role == ChatType.bot.index ? "assistant" : "user",
                  "content": e.content.join(","),
                })
            .toList(),
        {"role": "user", "content": S.current.title_promot},
      ],
      "stream": false,
      "options": {
        "seed": 101,
        "temperature": double.tryParse(temperature) ?? 0.5,
      }
    });

    if (response.statusCode == 200) {
      return response.data["message"]["content"] ?? "";
    } else {
      throw Exception("result is empty");
    }
  }

  @override
  Future<GenerateContentBean> generateContent(double temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) async {
    Dio dio = initOllama(bean);

    var response = await dio.post("/api/chat", data: {
      "model": modelType,
      "messages": chatItems
          .map((e) => {
                "role": e.role == ChatType.bot.index ? "assistant" : "user",
                "content": e.content.join(","),
              })
          .toList(),
      "stream": false,
      "options": {
        "temperature": temperature,
      }
    });

    if (response.statusCode == 200) {
      return GenerateContentBean(content: response.data["message"]["content"] ?? "");
    } else {
      throw Exception("result is empty");
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
      Dio dio = initOllama(bean);

      var response = await dio.get("/api/tags");
      if (response.statusCode == 200) {
        var models = response.data["models"] as List?;

        return models
                ?.map<SupportedModels>((e) => SupportedModels(
                      id: e["model"],
                      ownedBy: e["name"],
                    ))
                .toList() ??
            [];
      } else {
        return [];
      }
    } on DioException catch (e) {
      e.message.fail();
      return [];
    } catch (e) {
      e.toString().fail();
      return [];
    }
  }

  @override
  Future<void> initAPI(AllModelBean bean) {
    throw UnimplementedError();
  }

  @override
  Future<Stream<GenerateContentBean>> streamGenerateContent(String temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems, bool withoutHistoryMessage) async {
    return _streamGenerateContent(temperature, bean, modelType, originalChatItem, chatItems, withoutHistoryMessage);
  }

  final splitter = const LineSplitter();

  Stream<GenerateContentBean> _streamGenerateContent(String temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems, bool withoutHistoryMessage) async* {
    Dio dio = initOllama(bean, stream: true);

    var response = await dio.post("/api/chat", data: {
      "model": modelType,
      "messages": chatItems
          .map((e) => {
                "role": e.role == ChatType.bot.index ? "assistant" : "user",
                "content": e.content.join(","),
              })
          .toList(),
      "stream": true,
      "options": {
        "temperature": double.tryParse(temperature) ?? 0.5,
      }
    });

    if (response.statusCode == 200) {
      final ResponseBody rb = response.data;
      int index = 0;
      String modelStr = '';
      List<int> cacheUnits = [];
      List<int> list = [];

      await for (final itemList in rb.stream) {
        list = cacheUnits + itemList;

        cacheUnits.clear();

        String res = "";
        try {
          res = utf8.decode(list);
        } catch (e) {
          cacheUnits = list;
          continue;
        }

        res = res.trim();

        if (index == 0 && res.startsWith("[")) {
          res = res.replaceFirst('[', '');
        }
        if (res.startsWith(',')) {
          res = res.replaceFirst(',', '');
        }
        if (res.endsWith(']')) {
          res = res.substring(0, res.length - 1);
        }

        res = res.trim();

        for (final line in splitter.convert(res)) {
          if (modelStr == '' && line == ',') {
            continue;
          }
          modelStr += line;
          try {
            final content = (jsonDecode(modelStr)["message"]["content"]);
            yield GenerateContentBean(content: content);
            modelStr = '';
          } catch (e) {
            continue;
          }
        }
        index++;
      }
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
      Dio dio = initOllama(bean);

      var response = await dio.get("/api/tags");

      if (response.statusCode == 200) {
        return (response.data["models"] as List?)?.isNotEmpty ?? false;
      } else {
        return false;
      }
    } on DioException catch (e) {
      e.message.fail();
      return false;
    } catch (e) {
      e.toString().fail();
      return false;
    }
  }

  Dio initOllama(AllModelBean bean, {bool stream = false}) {
    return Dio(BaseOptions(
      baseUrl: bean.apiKey ?? "",
      connectTimeout: const Duration(minutes: 30),
      receiveTimeout: const Duration(minutes: 30),
      headers: {
        "Content-Type": "application/json",
      },
      responseType: stream ? ResponseType.stream : ResponseType.json,
    ))
      ..interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
        compact: true,
      ));
  }
}
