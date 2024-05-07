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
    var list = generateChatTitleListParams(originalChatItem);
    Dio dio = initOllama(bean);

    var response = await dio.post("/api/chat", data: {
      "model": modelType,
      "messages": list
          .map((e) => {
                "role": e.role == ChatType.bot.index ? "assistant" : "user",
                "content": e.content.join(","),
              })
          .toList(),
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
    var list = generateChatTitleListParams(originalChatItem);
    Dio dio = initOllama(bean);

    var response = await dio.post("/api/chat", data: {
      "model": modelType,
      "messages": list
          .map((e) => {
                "role": e.role == ChatType.bot.index ? "assistant" : "user",
                "content": e.content.join(","),
              })
          .toList(),
      "stream": false,
      "options": {
        "seed": 101,
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
    try {
      var list = generateChatHistory(originalChatItem, withoutHistoryMessage);
      Dio dio = initOllama(bean,stream: true);

      var response = await dio.post("/api/chat", data: {
        "model": modelType,
        "messages": list
            .map((e) => {
                  "role": e.role == ChatType.bot.index ? "assistant" : "user",
                  "content": e.content.join(","),
                })
            .toList(),
        "stream": true,
        "options": {
          "seed": 101,
          "temperature": double.tryParse(temperature) ?? 0.5,
        }
      });

      if (response.statusCode == 200) {
        return response.data.stream.map((event) {
          return GenerateContentBean(content: event["message"]["content"] ?? "");
        });
      } else {
        return Stream.error(Exception("result is empty"));
      }
    } on DioException catch (e) {
      e.message.fail();
      return Stream.error(e);
    } catch (e) {
      e.toString().fail();
      return Stream.error(e);
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
