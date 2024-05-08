import 'dart:async';
import 'dart:math';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/db/chat_item.dart';
import 'package:ChatBot/base/theme.dart';
import 'package:ChatBot/const.dart';
import 'package:ChatBot/module/chat/chat_detail/chat_viewmodel.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import '../../../base/api.dart';
import '../../../base/components/autio_popover.dart';
import '../../../base/components/lottie_widget.dart';
import '../../../base/providers.dart';
import '../../../hive_bean/generate_content.dart';
import '../../../hive_bean/openai_bean.dart';
import '../../../utils/hive_box.dart';
import '../chat_audio/chat_audio_page.dart';

class ChatTranslatePage extends ConsumerStatefulWidget {
  const ChatTranslatePage({super.key});

  @override
  ConsumerState createState() => _ChatTranslatePageState();
}

class _ChatTranslatePageState extends ConsumerState<ChatTranslatePage> {
  final fromTextController = TextEditingController();
  List<AllModelBean> supportedModels = [];
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    supportedModels = HiveBox().openAIConfig.values.toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ref.watch(currentGenerateTranslateChatModelProvider.notifier).state == null) {
        ref.watch(currentGenerateTranslateChatModelProvider.notifier).state = supportedModels.first;
      }
      _focusNode.requestFocus();
    });
  }

  final AudioOverlay audioOverlay = AudioOverlay();

  final record = AudioRecorder();
  String? audioPath;

  var player = AudioPlayer();

  void playText(AllModelBean bean, String content) async {
    if (bean.getTTSModels.isEmpty) {
      return;
    }
    if (content.isEmpty) return;
    var tts = await API().text2TTS(bean, content, ref.watch(talkerProvider.notifier).state);

    if (player.playing) {
      player.stop();
    }
    if (tts == null) {
      return;
    }

    await player.setAudioSource(MyCustomSource(tts.readAsBytesSync()));
    await player.play();
  }

  void startRecord() async {
    if (await record.hasPermission()) {
      audioPath = "${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.m4a";
      await record.start(const RecordConfig(), path: audioPath!);
    } else {
      S.current.open_micro_permission.fail();
      audioOverlay.removeAudio();
    }
  }

  void cancel() {
    try {
      record.cancel();
      if (audioPath != null && audioPath!.isNotEmpty) {
        if (File(audioPath!).existsSync()) {
          File(audioPath!).deleteSync();
        }
      }
    } catch (e) {
      e.toString().fail();
    }
    ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.normal;
  }

  void stopRecord() async {
    var path = await record.stop();

    if (path == null || path.isEmpty) {
      S.current.no_audio_file.fail();
      return;
    }
    if (!File(path).existsSync()) {
      return;
    }
    ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.sending;

    S.current.loading.loading();
    try {
      var model = ref.watch(currentGenerateTranslateChatModelProvider.notifier).state;

      if (model == null) {
        ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.normal;
        S.current.no_module_use.fail();
        return;
      }
      var content = await API().tts2Text(model, path);
      if (content != null && content.isNotEmpty) {
        sendMessage(model, content);
      } else {
        ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.normal;
        S.current.can_not_get_voice_content.fail();
      }
    } catch (e) {
      ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.normal;
      e.toString().fail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      var supportedModel = ref.watch(currentGenerateTranslateChatModelProvider);

      if (supportedModel == null) return const Scaffold();
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          appBar: AppBar(
            title: PullDownButton(
              scrollController: ScrollController(),
              buttonBuilder: (_, showMenu) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: F.width * 0.5,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          S.current.translate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).appBarTheme.titleTextStyle,
                        ),
                        Text(
                          "(${getModelByApiKey(supportedModel.apiKey!).alias.toString()})",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).primaryColor,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Icon(
                    CupertinoIcons.chevron_up_chevron_down,
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                    size: 16,
                  ),
                ],
              ).click(() {
                showMenu();
              }),
              itemBuilder: (BuildContext context) {
                return supportedModels
                    .map<PullDownMenuItem>((e) => PullDownMenuItem(
                          title: e.alias ?? "",
                          iconColor: Theme.of(context).primaryColor,
                          icon: e.alias != supportedModel.alias ? null : CupertinoIcons.checkmark_alt,
                          onTap: () {
                            ref.watch(currentGenerateTranslateChatModelProvider.notifier).state = e;
                          },
                        ))
                    .toList();
              },
            ),
          ),
          floatingActionButton:
              //翻译按钮
              FloatingActionButton(
            mini: true,
            onPressed: () {
              if (fromTextController.text.isEmpty) {
                return;
              }
              //隐藏键盘
              FocusScope.of(context).unfocus();
              _translate(supportedModel, fromTextController.text);
            },
            backgroundColor: Theme.of(context).cardColor,
            child: Icon(
              Icons.translate,
              color: Theme.of(context).primaryColor,
            ),
          ),
          body: SingleChildScrollView(
            child: Consumer(builder: (context, ref, _) {
              String fromLanguage = ref.watch(fromLanguageProvider);
              String toLanguage = ref.watch(toLanguageProvider);
              String translatedContent = ref.watch(translatedContentProvider);

              return Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      getLocaleLanguages()[fromLanguage] ?? "",
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: F.width,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        focusNode: _focusNode,
                        controller: fromTextController,
                        maxLines: 15,
                        textInputAction: TextInputAction.send,
                        minLines: 5,
                        onSubmitted: (value) {
                          _translate(supportedModel, value);
                        },
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 24,
                            ),
                        decoration: InputDecoration(
                          hintText: S.current.input_text,
                          border: InputBorder.none,
                          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 24,
                              ),
                          contentPadding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Divider(),
                    if (translatedContent.isNotEmpty) const SizedBox(height: 30),
                    if (translatedContent.isNotEmpty)
                      Text(
                        getLocaleLanguages()[toLanguage] ?? "",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 14,
                        ),
                      ),
                    if (translatedContent.isNotEmpty) const SizedBox(height: 16),
                    if (translatedContent.isNotEmpty)
                      Text(
                        translatedContent,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: 24,
                        ),
                      ),
                    if (translatedContent.isNotEmpty) const SizedBox(height: 15),
                    if (translatedContent.isNotEmpty)
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).primaryColor,
                          BlendMode.srcIn,
                        ),
                        child: MoreFunctions(
                          speakCall: supportedModel.getTTSModels.isEmpty
                              ? null
                              : () {
                                  playText(supportedModel, translatedContent);
                                },
                          stopCall: () {
                            player.stop();
                            ref.watch(playingAudioProvider.notifier).state = false;
                          },
                          toClipboard: () {
                            translatedContent.toClipboard();
                          },
                          toShare: () {
                            Share.share(translatedContent);
                          },
                        ),
                      ),
                    SizedBox(height: F.height / 3),
                  ],
                ),
              );
            }),
          ),
          bottomNavigationBar: SafeArea(
            bottom: true,
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 15),
                Row(
                  children: [
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer(builder: (context, ref, _) {
                        var fromLanguage = ref.watch(fromLanguageProvider);
                        return PullDownButton(
                          scrollController: ScrollController(),
                          itemBuilder: (context) => getLocaleLanguages()
                              .entries
                              .map((e) => PullDownMenuItem(
                                    title: e.value,
                                    enabled: e.key != ref.watch(toLanguageProvider.notifier).value,
                                    onTap: () {
                                      ref.watch(fromLanguageProvider.notifier).change(e.key);
                                    },
                                  ))
                              .toList(),
                          buttonBuilder: (context, showMenu) => Card(
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: F.width,
                                  minHeight: 40,
                                ),
                                child: Center(
                                    child: Text(
                                  getLocaleLanguages()[fromLanguage] ?? "",
                                  style: Theme.of(context).textTheme.titleMedium,
                                ))),
                          ).click(() {
                            showMenu();
                          }),
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                    Transform.rotate(
                      angle: pi / 2,
                      child: Icon(
                        CupertinoIcons.arrow_swap,
                        size: 20,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ).click(() {
                      var from = ref.watch(fromLanguageProvider.notifier).value;
                      var to = ref.watch(toLanguageProvider.notifier).value;
                      ref.watch(fromLanguageProvider.notifier).change(to);
                      ref.watch(toLanguageProvider.notifier).change(from);
                    }),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Consumer(builder: (context, ref, _) {
                        var toLanguage = ref.watch(toLanguageProvider);
                        return PullDownButton(
                          scrollController: ScrollController(),
                          itemBuilder: (context) => getLocaleLanguages()
                              .entries
                              .map((e) => PullDownMenuItem(
                                    title: e.value,
                                    enabled: e.key != ref.watch(fromLanguageProvider.notifier).value,
                                    onTap: () {
                                      ref.watch(toLanguageProvider.notifier).change(e.key);
                                    },
                                  ))
                              .toList(),
                          buttonBuilder: (context, showMenu) => Card(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minWidth: F.width,
                                minHeight: 40,
                              ),
                              child: Center(
                                  child: Text(
                                getLocaleLanguages()[toLanguage] ?? "",
                                style: Theme.of(context).textTheme.titleMedium,
                              )),
                            ),
                          ).click(() {
                            showMenu();
                          }),
                        );
                      }),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),
                const SizedBox(height: 10),
                if (supportedModel.getWhisperModels.isNotEmpty)
                  Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (event) async {
                      ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.recording;
                      audioOverlay.showAudio(context);
                      startRecord();
                    },
                    onPointerUp: (event) {
                      audioOverlay.removeAudio();
                      if (ref.watch(audioRecordingStateProvider.notifier).state == AudioRecordingState.canceling) {
                        cancel();
                      } else {
                        stopRecord();
                      }
                    },
                    onPointerMove: (event) {
                      //获取他相对于整个屏幕左上角的偏移
                      var offset = event.position;

                      double paddingBottom = MediaQuery.of(context).size.height - offset.dy;

                      if (paddingBottom < 200) {
                        ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.recording;
                      } else {
                        ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.canceling;
                      }
                      audioOverlay.update();
                    },
                    onPointerCancel: (event) {
                      audioOverlay.removeAudio();
                      ref.watch(audioRecordingStateProvider.notifier).state = AudioRecordingState.normal;
                    },
                    child: const LottieWidget(
                      scale: 2.4,
                      transformHitTests: false,
                      width: 80,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void sendMessage(AllModelBean model, String content) {
    fromTextController.text = content;
    _translate(model, content);
  }

  StreamSubscription<GenerateContentBean>? _streamSubscription;

  void _translate(AllModelBean model, String content) async {
    S.current.loading.loading();
    ref.watch(translatedContentProvider.notifier).state = "";
    //prompt
    var promptItem = ChatItem(
      content:
          "You are now a translation engine. You only need to translate the content I request and do not need to return anything else.",
      time: DateTime.now().millisecondsSinceEpoch,
      moduleType: model.getDefaultModelType.id,
      moduleName: model.model,
      messageType: MessageType.common.index,
      parentID: specialGenerateTranslateChatParentItemTime,
      status: MessageStatus.success.index,
      type: ChatType.user.index,
    );

    await Future.delayed(const Duration(milliseconds: 50));

    var detectFrom = ref.watch(fromLanguageProvider.notifier).value;
    String detectTo = ref.watch(toLanguageProvider.notifier).value;
    var generatedUserPrompt = "translate from ${getLocaleLanguages()[detectFrom]} to ${getLocaleLanguages()[detectTo]}";

    if (detectTo == getLocaleLanguages()["wyw"] || detectTo == getLocaleLanguages()["yue"]) {
      generatedUserPrompt = "翻译成$detectTo";
    }
    if (detectFrom == getLocaleLanguages()["wyw"] ||
        detectFrom == getLocaleLanguages()["zh-Hans"] ||
        detectFrom == getLocaleLanguages()["zh-Hant"]) {
      if (detectTo == getLocaleLanguages()["zh-Hant"]) {
        generatedUserPrompt = "翻译成繁体白话文";
      } else if (detectTo == getLocaleLanguages()["zh-Hans"]) {
        generatedUserPrompt = "翻译成简体白话文";
      } else if (detectTo == getLocaleLanguages()["yue"]) {
        generatedUserPrompt = "翻译成粤语白话文";
      }
    }
    generatedUserPrompt = "$generatedUserPrompt:\n\n${fromTextController.text}";

    var userItem = ChatItem(
      content: generatedUserPrompt,
      time: DateTime.now().millisecondsSinceEpoch,
      moduleType: model.getDefaultModelType.id,
      moduleName: model.model,
      parentID: specialGenerateTranslateChatParentItemTime,
      messageType: MessageType.common.index,
      status: MessageStatus.success.index,
      type: ChatType.user.index,
    );
    await Future.delayed(const Duration(milliseconds: 50));

    String result = "";
    var chatItem = ChatItem(
      type: ChatType.bot.index,
      messageType: MessageType.common.index,
      content: result,
      status: MessageStatus.loading.index,
      parentID: specialGenerateTranslateChatParentItemTime,
      requestID: userItem.time,
      moduleName: ref.watch(currentGenerateTranslateChatModelProvider.notifier).state!.model!,
      moduleType: ref.watch(currentGenerateTranslateChatModelProvider.notifier).state!.defaultModelType!.id,
      time: DateTime.now().millisecondsSinceEpoch,
    );
    await Future.delayed(const Duration(milliseconds: 50));

    eDismiss();
    _streamSubscription = (await API().streamGenerateContent(
      HiveBox().temperature,
      ref.watch(currentGenerateTranslateChatModelProvider.notifier).state!,
      ref.watch(currentGenerateTranslateChatModelProvider.notifier).state!.defaultModelType!.id!,
      [promptItem, userItem],
      [],
      true,
    ))
        .listen((event) {
      result += event.content ?? "";
      result.i();
      chatItem.content = result;
      chatItem.status = MessageStatus.success.index;
      ref.watch(translatedContentProvider.notifier).state = result;
    }, onDone: () {
      _streamSubscription?.cancel();
      ref.watch(imagesProvider.notifier).update((state) => []);
    }, onError: (e) {
      if (e is RequestFailedException) {
        e.message.fail();
      } else {
        e.toString().fail();
      }
      userItem.status = MessageStatus.failed.index;
      chatItem.content = "";
      chatItem.status = MessageStatus.failed.index;
      _streamSubscription?.cancel();
      e.toString().fail();
    }, cancelOnError: true);
  }

  @override
  void dispose() {
    player.dispose();
    record.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}

typedef SpeakCall = void Function();

class MoreFunctions extends ConsumerWidget {
  final SpeakCall? speakCall;
  final SpeakCall stopCall;
  final SpeakCall toClipboard;
  final SpeakCall toShare;

  const MoreFunctions({
    super.key,
    required this.speakCall,
    required this.stopCall,
    required this.toClipboard,
    required this.toShare,
  });

  @override
  Widget build(BuildContext context, ref) {
    var playing = ref.watch(playingAudioProvider);

    return Row(
      children: [
        const SizedBox(width: 5),
        if (speakCall != null && !playing)
          Icon(CupertinoIcons.speaker_3, size: 20, color: Theme.of(context).textTheme.titleMedium?.color).click(
            () {
              speakCall!();
            },
          ),
        if (playing)
          Icon(CupertinoIcons.stop_circle, size: 20, color: Theme.of(context).textTheme.titleMedium?.color).click(
            () {
              stopCall();
            },
          ),
        const Spacer(),
        Icon(CupertinoIcons.doc_on_doc, size: 20, color: Theme.of(context).textTheme.titleMedium?.color).click(
          () {
            toClipboard();
          },
        ),
        const SizedBox(width: 30),
        Icon(CupertinoIcons.arrowshape_turn_up_right, size: 20, color: Theme.of(context).textTheme.titleMedium?.color)
            .click(
          () {
            toShare();
          },
        ),
        const SizedBox(width: 5),
      ],
    );
  }
}

final translatedContentProvider = StateProvider.autoDispose<String>((ref) {
  return "";
});

final playingAudioProvider = StateProvider.autoDispose<bool>((ref) {
  return false;
});
