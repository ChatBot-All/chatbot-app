import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/api.dart';
import 'package:ChatBot/hive_bean/generate_content.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:path_provider/path_provider.dart';

import '../../hive_bean/supported_models.dart';
import '../db/chat_item.dart';
import 'api_impl.dart';

class ChatGPTImpl extends APIImpl {
  //单例

  static ChatGPTImpl? _instance;

  factory ChatGPTImpl() => _instance ??= ChatGPTImpl._();

  ChatGPTImpl._();

  @override
  Future<void> initAPI(AllModelBean bean) async {
    OpenAI.apiKey = bean.apiKey ?? "";
    OpenAI.baseUrl = (bean.apiServer ?? "");
    OpenAI.organization = bean.organization;
    OpenAI.requestsTimeOut = const Duration(seconds: 6000);
    OpenAI.showLogs = true;
    OpenAI.showResponsesLogs = true;
  }

  @override
  Future<GenerateContentBean> generateContent(
    double temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
  ) async {
    initAPI(bean);
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
      model: modelType,
      messages: list,
      frequencyPenalty: 0,
      n: 1,
      topP: 1,
      presencePenalty: 0,
      temperature: temperature,
    ));

    return GenerateContentBean(content: result.choices.first.message.content?.first.text ?? "");
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

  @override
  Future<Stream<GenerateContentBean>> streamGenerateContent(
    String temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
    bool withoutHistoryMessage,
  ) async {
    try {
      initAPI(bean);
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
        model: modelType,
        messages: list,
        frequencyPenalty: 0,
        n: 1,
        topP: 1,
        presencePenalty: 0,
        temperature: double.tryParse(temperature) ?? 1.0,
      )
          .map((event) {
        var result = "";

        try {
          if (event.choices.isNotEmpty && event.choices.first.delta.content != null) {
            List<OpenAIChatCompletionChoiceMessageContentItemModel?>? content = event.choices.first.delta.content;
            content?.forEach((element) {
              try {
                if (element?.type == "text") {
                  result += element?.text ?? "";
                } else if (element?.type == "image_url") {
                  result += "![${element?.imageUrl}](${element?.imageUrl})";
                }
              } catch (e) {}
            });
          }
        } catch (e) {}
        return GenerateContentBean(content: result);
      });
    } on RequestFailedException catch (e) {
      return Stream.error(e);
    }
  }

  @override
  Future<File?> text2TTS(AllModelBean bean, String content, String voice) async {
    try {
      initAPI(bean);
      File speechFile = await OpenAI.instance.audio.createSpeech(
        model: "tts-1",
        input: content,
        voice: voice.toLowerCase(),
        responseFormat: OpenAIAudioSpeechResponseFormat.mp3,
        outputDirectory: await getApplicationDocumentsDirectory(),
        outputFileName: DateTime.now().millisecondsSinceEpoch.toString(),
      );
      return speechFile;
    } on RequestFailedException catch (e) {
      e.message.fail();
      return null;
    } catch (e) {
      e.toString().fail();
      return null;
    }
  }

  @override
  Future<String?> tts2Text(AllModelBean bean, String ttsFile) async {
    try {
      initAPI(bean);
      OpenAIAudioModel transcription = await OpenAI.instance.audio.createTranscription(
        file: File(ttsFile),
        model: bean.getWhisperModels.first.id ?? "",
        responseFormat: OpenAIAudioResponseFormat.text,
      );
      return transcription.text;
    } on RequestFailedException catch (e) {
      e.message.fail();
      return null;
    } catch (e) {
      e.toString().fail();
      return "";
    }
  }

  @override
  Future<bool> validateApiKey(AllModelBean bean) async {
    try {
      initAPI(bean);
      List<OpenAIModelModel> models = await OpenAI.instance.model.list();

      eDismiss();
      if (models.isNotEmpty) {
        return true;
      }
      S.current.getmodules_fail.fail();
      return false;
    } on RequestFailedException catch (e) {
      e.message.fail();
      return false;
    } catch (e) {
      e.toString().fail();
      return false;
    }
  }

  @override
  Future<List<SupportedModels>> getSupportModules(AllModelBean bean) async {
    try {
      initAPI(bean);
      var result =
          (await OpenAI.instance.model.list()).map((e) => SupportedModels(ownedBy: e.ownedBy, id: e.id)).toList();
      eDismiss();
      return result;
    } on RequestFailedException catch (e) {
      e.message.fail();
      return [];
    } catch (e) {
      e.toString().fail();
      return [];
    }
  }

  @override
  Future<List<OpenAIImageData>> generateOpenAIImage(
    AllModelBean bean,
    String prompt,
    OpenAIImageStyle style,
    OpenAIImageSize size,
  ) async {
    initAPI(bean);

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

  @override
  Future<String> generateChatTitle(
    String temperature,
    AllModelBean bean,
    String modelType,
    List<ChatItem> originalChatItem,
    List<RequestParams> chatItems,
  ) async {
    try {
      if (chatItems.isEmpty) {
        return S.current.new_chat;
      }
      initAPI(bean);

      final list = chatItems
          .where((element) => element.content.isNotEmpty)
          .map((e) => OpenAIChatCompletionChoiceMessageModel(
                role: e.role == ChatType.user.index ? OpenAIChatMessageRole.user : OpenAIChatMessageRole.assistant,
                content: e.content
                    .map((e) => OpenAIChatCompletionChoiceMessageContentItemModel.text(
                          e,
                        ))
                    .toList(),
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
        temperature: double.tryParse(temperature) ?? 1.0,
      );
      return result.choices.first.message.content?.first.text?.trim() ?? "";
    } on RequestFailedException catch (e) {
      e.message.fail();
      return S.current.new_chat;
    } catch (e) {
      e.toString().fail();
      return chatItems.first.content.first;
    }
  }
}
