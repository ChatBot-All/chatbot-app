import 'dart:convert';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/hive_bean/generate_content.dart';
import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:path_provider/path_provider.dart';

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

class API {
  //单例
  static final API _instance = API._internal();

  factory API() => _instance;

  API._internal();

  Future<bool> validateApiKey(AllModelBean bean) async {
    try {
      if (bean.model == APIType.openAI.code) {
        OpenAI.apiKey = bean.apiKey ?? "";
        OpenAI.baseUrl = (bean.apiServer ?? "");
        OpenAI.organization = bean.organization;
        OpenAI.requestsTimeOut = const Duration(seconds: 10);
        OpenAI.showLogs = true;
        OpenAI.showResponsesLogs = true;
        List<OpenAIModelModel> models = await OpenAI.instance.model.list();
        if (models.isNotEmpty) {
          return true;
        }
        return false;
      } else {
        Gemini gemini = Gemini.init(
          apiKey: bean.apiKey ?? "",
          baseURL: "${bean.apiServer}/",
          enableDebugging: kDebugMode,
        );
        await Future.delayed(const Duration(milliseconds: 100));
        var models = await gemini.listModels();
        return models.isNotEmpty;
      }
    } on RequestFailedException catch (e) {
      e.message.fail();
      return false;
    } catch (e) {
      e.toString().fail();
      return false;
    }
  }

  Future<List<SupportedModels>> getSupportModules(AllModelBean bean) async {
    try {
      if (bean.model == APIType.openAI.code) {
        OpenAI.apiKey = bean.apiKey ?? "";
        OpenAI.baseUrl = (bean.apiServer ?? "");
        OpenAI.organization = bean.organization;
        OpenAI.requestsTimeOut = const Duration(seconds: 10);
        OpenAI.showLogs = true;
        OpenAI.showResponsesLogs = true;
        return (await OpenAI.instance.model.list()).map((e) => SupportedModels(ownedBy: e.ownedBy, id: e.id)).toList();
      } else {
        Gemini gemini = Gemini.init(
          apiKey: bean.apiKey ?? "",
          enableDebugging: kDebugMode,
          baseURL: "${bean.apiServer}/",
        );
        await Future.delayed(const Duration(milliseconds: 100));
        var models = await gemini.listModels();
        return models.map((e) => SupportedModels(ownedBy: e.version, id: e.name)).toList();
      }
    } on RequestFailedException catch (e) {
      e.message.fail();
      return [];
    } catch (e) {
      e.toString().fail();
      return [];
    }
  }

  Future<String> generateChatTitle(
      ChatParentItem history, AllModelBean bean, String modelType, List<ChatItem> chatItems) async {
    try {
      if (history.moduleName == APIType.gemini.code) {
        Gemini gemini = Gemini.init(
          apiKey: bean.apiKey ?? "",
          baseURL: "${bean.apiServer}/",
          enableDebugging: kDebugMode,
          generationConfig: GenerationConfig(
            temperature: double.tryParse(history.historyMessageCount?.toString() ?? "1.0") ?? 1.0,
          ),
        );
        var list = generateChatTitleListParams(chatItems, history.historyMessageCount ?? 6);

        if (list.length >= 2) {
          list = list.sublist(0, 2);
        }

        list.add(RequestParams(
          role: 0,
          content: [S.current.title_promot],
          images: [],
        ));

        var contents = list
            .map((e) => Content(
                parts: e.content.map((e) => Parts(text: e)).toList(),
                role: e.role != ChatType.bot.index ? 'user' : 'model'))
            .toList();

        var result = await gemini.chat(contents, modelName: modelType);
        return result?.content?.parts?.last.text ?? "";
      }
      OpenAI.apiKey = bean.apiKey ?? "";
      OpenAI.baseUrl = (bean.apiServer ?? "");
      OpenAI.organization = bean.organization;
      OpenAI.requestsTimeOut = const Duration(seconds: 6000);
      OpenAI.showLogs = true;
      OpenAI.showResponsesLogs = true;

      //取后10个列表数据

      List<ChatItem> historyMessages = chatItems;

      final list = historyMessages
          .where((element) => element.content != null && element.content!.isNotEmpty)
          .map((e) => OpenAIChatCompletionChoiceMessageModel(
                role: e.type == ChatType.user.index ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant,
                content: [
                  OpenAIChatCompletionChoiceMessageContentItemModel.text(
                    e.content ?? "",
                  )
                ],
              ))
          .toList();

      list.add(OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            S.current.title_promot,
          )
        ],
      ));

      var result = await OpenAI.instance.chat.create(
        model: modelType,
        messages: list,
        frequencyPenalty: 0,
        topP: 1,
        presencePenalty: 0,
        temperature: double.tryParse(history.historyMessageCount?.toString() ?? "1.0") ?? 1.0,
      );
      return result.choices.first.message.content?.first.text?.trim() ?? "";
    } on RequestFailedException catch (e) {
      print(e);
      return S.current.new_chat;
    } catch (e) {
      print(e);
      return chatItems.first.content ?? "";
    }
  }

  Future<String> audio2OpenAIText(AllModelBean bean, String path) async {
    try {
      OpenAI.apiKey = bean.apiKey ?? "";
      OpenAI.baseUrl = (bean.apiServer ?? "");
      OpenAI.organization = bean.organization;
      OpenAI.requestsTimeOut = const Duration(seconds: 6000);
      OpenAI.showLogs = true;
      OpenAI.showResponsesLogs = true;
      OpenAIAudioModel transcription = await OpenAI.instance.audio.createTranscription(
        file: File(path),
        model: bean.getWhisperModels.first.id ?? "",
        responseFormat: OpenAIAudioResponseFormat.text,
      );
      print(transcription.text);
      return transcription.text;
    } catch (e) {
      e.toString().fail();
      return "";
    }
  }

  Future<List<OpenAIImageData>> createOpenAIImage(
    AllModelBean bean,
    String prompt,
    OpenAIImageStyle style,
    OpenAIImageSize size,
  ) async {
    OpenAI.apiKey = bean.apiKey ?? "";
    OpenAI.baseUrl = (bean.apiServer ?? "");
    OpenAI.organization = bean.organization;
    OpenAI.requestsTimeOut = const Duration(seconds: 6000);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    OpenAIImageModel image = await OpenAI.instance.image.create(
      model: "dall-e-3",
      prompt: prompt,
      n: 1,
      size: size,
      quality: OpenAIImageQuality.hd,
      style: style,
      responseFormat: OpenAIImageResponseFormat.url,
    );

    List<OpenAIImageData> images = [];

    for (int index = 0; index < image.data.length; index++) {
      final currentItem = image.data[index];
      images.add(currentItem);
    }
    return images;
  }

  List<RequestParams> generateChatTitleListParams(List<ChatItem> chatItems, int historyCount) {
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

  List<RequestParams> generateChatHistory(List<ChatItem> chatItems, int historyCount, bool withoutHistoryMessage) {
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

  Future<Stream<GenerateContentBean>> createTextChat(
    int moduleName,
    int historyCount,
    double temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> chatItems,
    bool withoutHistoryMessage,
  ) async {
    //整合chatItems

    var requestParams = generateChatHistory(chatItems, historyCount, withoutHistoryMessage);
    if (moduleName == APIType.openAI.code) {
      return _createOpenAIChat(moduleName, historyCount, temperature, bean, modelType, requestParams);
    } else {
      return _createGeminiChat(moduleName, historyCount, temperature, bean, modelType, requestParams);
    }
  }

  Future<File> text2TTS(String content, String voice) async {
    File speechFile = await OpenAI.instance.audio.createSpeech(
      model: "tts-1",
      input: content,
      voice: "nova",
      responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
      outputDirectory: await getApplicationDocumentsDirectory(),
      outputFileName: DateTime.now().millisecondsSinceEpoch.toString(),
    );
    return speechFile;

// The file result.
  }

  Future<GenerateContentBean> createTextChatDirectly(
    double temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> chatItems,
  ) async {
    //整合chatItems

    var requestParams = generateChatHistory(chatItems, 10, false);
    return _createOpenAIChatDirectly(temperature, bean, modelType, requestParams);
  }

  Stream<GenerateContentBean> _createGeminiChat(
    int moduleName,
    int historyCount,
    double temperature,
    AllModelBean bean,
    String modelType,
    List<RequestParams> chatItems,
  ) {
    Gemini gemini = Gemini.init(
      apiKey: bean.apiKey ?? "",
      baseURL: "${bean.apiServer}/",
      enableDebugging: kDebugMode,
      generationConfig: GenerationConfig(
        temperature: temperature,
      ),
    );
    RequestParams lastOneMessage = chatItems.last;
    if (lastOneMessage.images.isNotEmpty && lastOneMessage.images.where((element) => element.isNotEmpty).isNotEmpty) {
      return Stream.fromFuture(gemini
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

      return gemini
          .streamChat(contents, modelName: modelType)
          .map((event) => GenerateContentBean(content: event.content?.parts?.last.text));
    }

    // gemini.chat();
  }

  Future<GenerateContentBean> _createOpenAIChatDirectly(
    double temperature,
    AllModelBean bean,
    String model,
    List<RequestParams> chatItems,
  ) async {
    OpenAI.apiKey = bean.apiKey ?? "";
    OpenAI.baseUrl = (bean.apiServer ?? "");
    OpenAI.organization = bean.organization;
    OpenAI.requestsTimeOut = const Duration(seconds: 6000);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;

    final list = chatItems
        .map((e) => OpenAIChatCompletionChoiceMessageModel(
              role: getTypeByRole(e.role),
              content: [
                ...e.content.map((e) => OpenAIChatCompletionChoiceMessageContentItemModel.text(e)).toList(),
                ...e.images.map((e) => OpenAIChatCompletionChoiceMessageContentItemModel.imageBase64(e)).toList(),
              ],
            ))
        .toList();

    var result = (await OpenAI.instance.chat.create(
      model: model,
      messages: list,
      frequencyPenalty: 0,
      n: 1,
      topP: 1,
      presencePenalty: 0,
      temperature: temperature,
    ));

    return GenerateContentBean(content: result.choices.first.message.content?.first.text ?? "");
  }

  Future<Stream<GenerateContentBean>> _createOpenAIChat(
    int moduleName,
    int historyCount,
    double temperature,
    AllModelBean bean,
    String model,
    List<RequestParams> chatItems,
  ) async {
    try {
      OpenAI.apiKey = bean.apiKey ?? "";
      OpenAI.baseUrl = (bean.apiServer ?? "");
      OpenAI.organization = bean.organization;
      OpenAI.requestsTimeOut = const Duration(seconds: 6000);
      OpenAI.showLogs = true;
      OpenAI.showResponsesLogs = true;

      final list = chatItems
          .map((e) => OpenAIChatCompletionChoiceMessageModel(
                role: getTypeByRole(e.role),
                content: [
                  ...e.content.map((e) => OpenAIChatCompletionChoiceMessageContentItemModel.text(e)).toList(),
                  ...e.images.map((e) => OpenAIChatCompletionChoiceMessageContentItemModel.imageBase64(e)).toList(),
                ],
              ))
          .toList();

      return OpenAI.instance.chat
          .createStream(
        model: model,
        messages: list,
        frequencyPenalty: 0,
        n: 1,
        topP: 1,
        presencePenalty: 0,
        temperature: temperature,
      )
          .map((event) {
        List<OpenAIChatCompletionChoiceMessageContentItemModel?>? content = event.choices.first.delta.content;

        var result = "";
        content?.forEach((element) {
          if (element?.type == "text") {
            result += element?.text ?? "";
          } else if (element?.type == "image_url") {
            result += "![${element?.imageUrl}](${element?.imageUrl})";
          }
        });
        return GenerateContentBean(content: result);
      });
    } on RequestFailedException catch (e) {
      return Stream.error(e);
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
}
