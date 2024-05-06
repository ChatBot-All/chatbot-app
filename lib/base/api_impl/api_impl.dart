import 'dart:io';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:dio/dio.dart';

import '../../hive_bean/generate_content.dart';
import '../../hive_bean/supported_models.dart';
import '../api.dart';
import '../db/chat_item.dart';

abstract class APIImpl {
  Future<void> initAPI(AllModelBean bean);

  Future<bool> validateApiKey(AllModelBean bean);

  Future<List<SupportedModels>> getSupportModules(AllModelBean bean);

  Future<List<OpenAIImageData>> generateOpenAIImage(
    AllModelBean bean,
    String prompt,
    OpenAIImageStyle style,
    OpenAIImageSize size,
  );

  Future<GenerateContentBean> generateContent(
    double temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
  );

  Future<String> generateChatTitle(
    String temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
  );

  Future<Stream<GenerateContentBean>> streamGenerateContent(
    String temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
    bool withoutHistoryMessage,
  );

  Future<File?> text2TTS(AllModelBean bean, String content, String voice);

  Future<String?> tts2Text(AllModelBean bean, String ttsFile);

  List<RequestParams> generateChatTitleListParams(List<ChatItem> chatItems) {
    List<RequestParams> requestParams = [
      RequestParams(role: ChatType.user.index, content: [], images: []),
    ];

    List<ChatItem> historyMessages = [];
    //深拷贝一份chatItems
    for (var element in chatItems) {
      historyMessages.add(element.copyWidth());
    }

    for (int j = 0; j < historyMessages.length; j++) {
      //遍历historyMessages里的所有内容，将type为0的内容放到user里，将type为1的内容放到model里，并且保证user和model成对出现

      int role = requestParams.last.role;

      if (j == 0 && historyMessages[j].type == ChatType.system.index) {
        requestParams.last.content.add(historyMessages[j].content ?? "");
        continue;
      }

      if (historyMessages[j].type == role) {
        requestParams.last.content.add(historyMessages[j].content ?? "");
        requestParams.last.images.addAll(historyMessages[j].images ?? []);
      } else {
        requestParams.add(RequestParams(
            role: historyMessages[j].type ?? 0,
            content: [historyMessages[j].content ?? ""],
            images: historyMessages[j].images ?? []));
      }
    }

    int k = 0;
    while (requestParams.isNotEmpty && requestParams[k].role == ChatType.bot.index) {
      requestParams.removeAt(k);
    }

    //最后一条必须是bot
    int l = requestParams.length - 1;
    while (requestParams.isNotEmpty && requestParams[l].role != ChatType.bot.index) {
      requestParams.removeAt(l);
      l = requestParams.length - 1;
    }

    return requestParams;
  }

  List<RequestParams> generateShareGPTListParams(List<ChatItem> chatItems) {
    List<RequestParams> requestParams = [
      RequestParams(role: ChatType.user.index, content: [], images: []),
    ];

    List<ChatItem> historyMessages = [];
    //深拷贝一份chatItems
    for (var element in chatItems) {
      historyMessages.add(element.copyWidth());
    }

    for (int j = 0; j < historyMessages.length; j++) {
      //遍历historyMessages里的所有内容，将type为0的内容放到user里，将type为1的内容放到model里，并且保证user和model成对出现

      int role = requestParams.last.role;

      if (j == 0 && historyMessages[j].type == ChatType.system.index) {
        requestParams.last.content.add(historyMessages[j].content ?? "");
        continue;
      }

      if (historyMessages[j].type == role) {
        requestParams.last.content.add(historyMessages[j].content ?? "");
        requestParams.last.images.addAll(historyMessages[j].images ?? []);
      } else {
        requestParams.add(RequestParams(
            role: historyMessages[j].type ?? 0,
            content: [historyMessages[j].content ?? ""],
            images: historyMessages[j].images ?? []));
      }
    }

    return requestParams;
  }

  List<RequestParams> generateChatHistory(List<ChatItem> chatItems, bool withoutHistoryMessage) {
    List<RequestParams> requestParams = [
      RequestParams(role: ChatType.user.index, content: [], images: []),
    ];

    List<ChatItem> historyMessages = [];
    //深拷贝一份chatItems
    for (var element in chatItems) {
      historyMessages.add(element.copyWidth());
    }

    //去除content为空的内容，状态为失败的内容
    historyMessages.removeWhere((element) =>
        element.content == null || element.content!.isEmpty || element.status != MessageStatus.success.index);

    //去除掉第一条是bot类型的消息
    int i = 0;
    while (historyMessages[i].type == ChatType.bot.index) {
      historyMessages.removeAt(i);
    }

    for (int j = 0; j < historyMessages.length; j++) {
      //遍历historyMessages里的所有内容，将type为0的内容放到user里，将type为1的内容放到model里，并且保证user和model成对出现

      int role = requestParams.last.role;

      if (j == 0 && historyMessages[j].type == ChatType.system.index) {
        requestParams.last.content.add(historyMessages[j].content ?? "");
        continue;
      }

      var images = historyMessages[j].images;

      images?.removeWhere((element) => element.isEmpty);

      if (historyMessages[j].type == role) {
        requestParams.last.content.add(historyMessages[j].content ?? "");
        requestParams.last.images.addAll(images ?? []);
      } else {
        requestParams.add(RequestParams(
            role: historyMessages[j].type ?? 0, content: [historyMessages[j].content ?? ""], images: images ?? []));
      }
    }

    //根据historyCount取后面位数,长度不够就不做操作
    // if (requestParams.length > historyCount) {
    //   requestParams = requestParams.sublist(requestParams.length - historyCount);
    // }
    //确保第一条role是user，最后一条也是user,如果不是，那就删了他
    int k = 0;
    while (requestParams.isNotEmpty && requestParams[k].role == ChatType.bot.index) {
      requestParams.removeAt(k);
    }

    //最后一条必须是user
    int l = requestParams.length - 1;
    while (requestParams.isNotEmpty && requestParams[l].role == ChatType.bot.index) {
      requestParams.removeAt(l);
      l = requestParams.length - 1;
    }

    if (withoutHistoryMessage) {
      return [requestParams.last];
    }
    return requestParams;
  }

  Future<String?> share2ShareGPT(List<ChatItem> chatItem) async {
    if (chatItem.isEmpty) {
      eDismiss();
      return null;
    }
    try {
      Dio dio = Dio(
        BaseOptions(
          headers: {
            "Content-Type": "application/json",
          },
        ),
      );

      var params = generateShareGPTListParams(chatItem)
          .map((e) => {
                "from": e.role == ChatType.bot.index ? "gpt" : "human",
                "value": e.content.join("\n"),
              })
          .toList();

      if (params.isEmpty) {
        eDismiss();
        return null;
      }
      var resultParams = {
        "avatarUrl": null,
        "items": params,
      };
      var result = await dio.post("https://sharegpt.com/api/conversations", data: resultParams);
      eDismiss();
      if (result.statusCode == 200) {
        return "https://shareg.pt/${result.data["id"]}";
      } else {
        return null;
      }
    } on DioException catch (e) {
      e.message.fail();
    } catch (e) {
      e.toString().fail();
    }
    return null;
  }
}
