import 'dart:convert';
import 'dart:io';

import 'package:chat_bot/base.dart';
import 'package:chat_bot/base/api.dart';
import 'package:chat_bot/base/api_impl/api_impl.dart';
import 'package:chat_bot/base/db/chat_item.dart';
import 'package:chat_bot/hive_bean/generate_content.dart';
import 'package:chat_bot/hive_bean/openai_bean.dart';
import 'package:chat_bot/hive_bean/supported_models.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class ZhiPuImpl extends APIImpl {
  @override
  Future<String> generateChatTitle(String temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) async {
    Dio dio = initZhiQu(bean);

    var response = await dio.post("/api/paas/v4/chat/completions", data: {
      "model": modelType,
      "messages": chatItems
          .map((e) => {
                "role": getZhiKuTypeByRole(e.role),
                "content": e.content.join(","),
              })
          .toList(),
      "temperature": double.tryParse(temperature.toString()) ?? 1.0,
      "stream": false,
    });

    if (response.statusCode == 200) {
      return response.data["choices"][0]["message"]["content"];
    } else {
      throw Exception("result is empty");
    }
  }

  String getZhiKuTypeByRole(int role) {
    if (role == ChatType.user.code) {
      return "user";
    }

    if (role == ChatType.system.code) {
      return "system";
    }

    return "assistant";
  }

  @override
  Future<GenerateContentBean> generateContent(double temperature, AllModelBean bean, String modelType,
      List<ChatItem> originalChatItem, List<RequestParams> chatItems) async {
    Dio dio = initZhiQu(bean);

    var response = await dio.post("/api/paas/v4/chat/completions", data: {
      "model": modelType,
      "messages": chatItems
          .map((e) => {
                "role": getZhiKuTypeByRole(e.role),
                "content": e.content.join(","),
              })
          .toList(),
      "temperature": double.tryParse(temperature.toString()) ?? 1.0,
      "stream": false,
    });

    if (response.statusCode == 200) {
      String? data = response.data["choices"][0]["message"]["content"];
      return GenerateContentBean(content: data);
    } else {
      throw Exception("result is empty");
    }
  }

  @override
  Future<List<OpenAIImageData>> generateOpenAIImage(
      AllModelBean bean, String prompt, OpenAIImageStyle style, OpenAIImageSize size) async {
    try {
      Dio dio = initZhiQu(bean);

      var response = await dio.post("/api/paas/v4/images/generations", data: {
        "model": bean.getPaintModels.first.id,
        "prompt": prompt,
      });

      if (response.statusCode == 200) {
        String? data = response.data["data"][0]["url"];
        return [OpenAIImageData(url: data, b64Json: '', revisedPrompt: '')];
      } else {
        throw Exception("result is empty");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data["error"]["message"]);
    }
  }

  @override
  Future<List<SupportedModels>> getSupportModules(AllModelBean bean) async {
    try {
      return ["glm-4", "glm-4v", "glm-3-turbo", "cogview-3"]
          .map((e) => SupportedModels(id: e, ownedBy: "zhiqu"))
          .toList();
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
    Dio dio = initZhiQu(bean, stream: true);

    var response = await dio.post("/api/paas/v4/chat/completions", data: {
      "model": modelType,
      "messages": chatItems
          .map((e) => {
                "role": getZhiKuTypeByRole(e.role),
                "content": e.content.join(","),
              })
          .toList(),
      "temperature": double.tryParse(temperature.toString()) ?? 1.0,
      "stream": true,
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
            if (modelStr.startsWith("data:")) {
              modelStr = modelStr.replaceAll("data:", "").trim();
              final content = (jsonDecode(modelStr)["choices"][0]["delta"]["content"]);
              yield GenerateContentBean(content: content);
              modelStr = '';
            } else {
              if (modelStr.startsWith("{") && modelStr.trim().endsWith("}")) {
                var result = jsonDecode(modelStr.trim());
                yield GenerateContentBean(content: result["error"]["message"]);
              }
            }
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
      return true;
    } on DioException catch (e) {
      e.message.fail();
      return false;
    } catch (e) {
      e.toString().fail();
      return false;
    }
  }

  Dio initZhiQu(AllModelBean bean, {bool stream = false}) {
    return Dio(BaseOptions(
      baseUrl: bean.apiServer ?? "",
      connectTimeout: const Duration(minutes: 30),
      receiveTimeout: const Duration(minutes: 30),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer ${bean.apiKey}",
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
