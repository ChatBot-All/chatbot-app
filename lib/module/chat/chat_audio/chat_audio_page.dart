import 'dart:math';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:record/record.dart';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/module/chat/chat_detail/chat_viewmodel.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:popover/popover.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../base/api.dart';
import '../../../base/components/autio_popover.dart';
import '../../../base/db/chat_item.dart';
import '../../../base/theme.dart';
import 'package:just_audio/just_audio.dart';

class ChatAudioPage extends ConsumerStatefulWidget {
  const ChatAudioPage({super.key});

  @override
  ConsumerState createState() => _ChatAudioPageState();
}

class _ChatAudioPageState extends ConsumerState<ChatAudioPage> {
  List<AllModelBean> supportedModels = [];

  @override
  void dispose() {
    audioOverlay.removeAudio();
    record.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    supportedModels = HiveBox()
        .openAIConfig
        .values
        .where((element) => (element.getWhisperModels.isNotEmpty &&
            element.getTTSModels.isNotEmpty))
        .toList();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (ref.watch(currentGenerateAudioChatModelProvider.notifier).state ==
          null) {
        ref.watch(currentGenerateAudioChatModelProvider.notifier).state =
            supportedModels.first;
        ref.watch(currentGenerateAudioChatTextParserProvider.notifier).state =
            supportedModels.first;
      }
    });
  }

  final AudioOverlay audioOverlay = AudioOverlay();

  final record = AudioRecorder();
  String? audioPath;

  void startRecord() async {
    if (await record.hasPermission()) {
      audioPath =
          "${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.m4a";
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
    ref.watch(audioRecordingStateProvider.notifier).state =
        AudioRecordingState.normal;
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
    ref.watch(audioRecordingStateProvider.notifier).state =
        AudioRecordingState.sending;

    try {
      var model =
          ref.watch(currentGenerateAudioChatModelProvider.notifier).state;
      var textModel =
          ref.watch(currentGenerateAudioChatTextParserProvider.notifier).state;

      if (model == null || textModel == null) {
        ref.watch(audioRecordingStateProvider.notifier).state =
            AudioRecordingState.normal;
        S.current.no_module_use.fail();
        return;
      }
      var content = await API().tts2Text(model, path);
      if (content != null && content.isNotEmpty) {
        sendMessage(model, textModel, content);
      } else {
        ref.watch(audioRecordingStateProvider.notifier).state =
            AudioRecordingState.normal;
        S.current.can_not_get_voice_content.fail();
      }
    } catch (e) {
      ref.watch(audioRecordingStateProvider.notifier).state =
          AudioRecordingState.normal;
      e.toString().fail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      var supportedModel = ref.watch(currentGenerateAudioChatModelProvider);

      if (supportedModel == null) return const Scaffold();
      return Scaffold(
        appBar: AppBar(
          title: PullDownButton(
            itemBuilder: (context) {
              return supportedModels.map((e) {
                return PullDownMenuItem(
                  title: e.alias ?? "",
                  iconColor: Theme.of(context).primaryColor,
                  icon: e.alias == supportedModel.alias
                      ? CupertinoIcons.checkmark
                      : null,
                  onTap: () {
                    ref
                        .watch(currentGenerateAudioChatModelProvider.notifier)
                        .state = e;
                  },
                );
              }).toList();
            },
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
                        S.current.voiceChat,
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
                  width: 5,
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
          ),
          actions: [
            Builder(builder: (context) {
              return PullDownButton(
                scrollController: ScrollController(),
                itemBuilder: (context) {
                  return [
                    PullDownMenuTitle(
                      title: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Text(
                          S.current.text_parse_model,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    ...HiveBox()
                        .openAIConfig
                        .values
                        .map((e) => PullDownMenuItem(
                              title: e.alias ?? "",
                              iconColor: Theme.of(context).primaryColor,
                              icon: e ==
                                      ref
                                          .watch(
                                              currentGenerateAudioChatTextParserProvider
                                                  .notifier)
                                          .state
                                  ? CupertinoIcons.checkmark
                                  : null,
                              onTap: () {
                                ref
                                    .watch(
                                        currentGenerateAudioChatTextParserProvider
                                            .notifier)
                                    .state = e;
                              },
                            ))
                        .toList(),
                  ];
                },
                buttonBuilder: (_, showMenu) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  ),
                ).click(() {
                  showMenu();
                }),
              );
            }),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer(builder: (context, ref, _) {
                var talker = ref.watch(talkerProvider);
                var status = ref.watch(audioRecordingStateProvider);
                return Column(
                  children: [
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Wrap(
                        runAlignment: WrapAlignment.center,
                        alignment: WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: talkers
                            .map((e) => Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: talker == e
                                        ? Theme.of(context).primaryColor
                                        : ref
                                            .watch(themeProvider)
                                            .inputPanelBg(),
                                    borderRadius: BorderRadius.circular(1000),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    e,
                                    style: TextStyle(
                                      color: talker == e
                                          ? Colors.white
                                          : Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.color,
                                      fontSize: 16,
                                    ),
                                  ),
                                ).click(() {
                                  ref.watch(talkerProvider.notifier).state = e;
                                }))
                            .toList(),
                      ),
                    ),
                    Expanded(
                        child: Center(
                            child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: getLottie(status),
                    ))),
                  ],
                );
              }),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: F.width,
              padding:
                  EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
              height: kBottomNavigationBarHeight +
                  MediaQuery.paddingOf(context).bottom,
              child: Consumer(builder: (context, ref, _) {
                var state = ref.watch(audioRecordingStateProvider);

                return IgnorePointer(
                  ignoring: state != AudioRecordingState.normal,
                  child: Opacity(
                    opacity: state != AudioRecordingState.normal ? 0.5 : 1,
                    child: Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (event) async {
                        ref.watch(audioRecordingStateProvider.notifier).state =
                            AudioRecordingState.recording;
                        audioOverlay.showAudio(context);
                        startRecord();
                      },
                      onPointerUp: (event) {
                        audioOverlay.removeAudio();
                        if (ref
                                .watch(audioRecordingStateProvider.notifier)
                                .state ==
                            AudioRecordingState.canceling) {
                          cancel();
                        } else {
                          stopRecord();
                        }
                      },
                      onPointerMove: (event) {
                        //获取他相对于整个屏幕左上角的偏移
                        var offset = event.position;

                        double paddingBottom =
                            MediaQuery.of(context).size.height - offset.dy;

                        if (paddingBottom < 200) {
                          ref
                              .watch(audioRecordingStateProvider.notifier)
                              .state = AudioRecordingState.recording;
                        } else {
                          ref
                              .watch(audioRecordingStateProvider.notifier)
                              .state = AudioRecordingState.canceling;
                        }
                        audioOverlay.update();
                      },
                      onPointerCancel: (event) {
                        audioOverlay.removeAudio();
                        ref.watch(audioRecordingStateProvider.notifier).state =
                            AudioRecordingState.normal;
                      },
                      child: Transform.translate(
                        offset: const Offset(0, -40),
                        child: Lottie.asset(
                          "assets/lottie/audio.json",
                          width: 130,
                          height: 130,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }

  final player = AudioPlayer();

  Future<void> sendMessage(
      AllModelBean model, AllModelBean textModel, String? text) async {
    ref.watch(audioRecordingStateProvider.notifier).state =
        AudioRecordingState.sending;
    var userChatItem = ChatItem(
      type: ChatType.user.index,
      content: text,
      status: MessageStatus.success.index,
      parentID: specialGenerateAudioChatParentItemTime,
      images: [],
      moduleName: ref
          .watch(currentGenerateAudioChatModelProvider.notifier)
          .state
          ?.model,
      messageType: MessageType.common.index,
      moduleType: model.getDefaultModelType.id ?? "gpt-4",
      time: DateTime.now().millisecondsSinceEpoch,
    );
    await Future.delayed(const Duration(milliseconds: 50));
    ref
        .watch(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
        .add(userChatItem);

    String result = "";
    var chatItem = ChatItem(
      type: ChatType.bot.index,
      messageType: MessageType.common.index,
      content: result,
      status: MessageStatus.loading.index,
      parentID: specialGenerateAudioChatParentItemTime,
      requestID: userChatItem.time,
      moduleName: model.model ?? 0,
      moduleType: model.defaultModelType?.id ?? "",
      time: DateTime.now().millisecondsSinceEpoch,
    );
    var allChats = ref
        .watch(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
        .add(chatItem);
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      var data = await API().generateContent(
        double.parse("1.0"),
        textModel,
        textModel.getDefaultModelType.id ?? "gpt-4",
        allChats,
        [],
      );

      chatItem.content = data.content;
      chatItem.status = MessageStatus.success.index;
      ref
          .watch(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
          .update(chatItem);

      if (data.content == null || data.content!.isEmpty) {
        throw Exception(S.current.generate_content_is_empty);
      }
      var tts = await API().text2TTS(
          ref.watch(currentGenerateAudioChatModelProvider.notifier).state!,
          data.content!,
          ref.watch(talkerProvider.notifier).state);
      ref.watch(audioRecordingStateProvider.notifier).state =
          AudioRecordingState.speaking;

      if (player.playing) {
        player.stop();
      }
      if (tts == null) {
        ref.watch(audioRecordingStateProvider.notifier).state =
            AudioRecordingState.normal;

        return;
      }
      await player.setAudioSource(MyCustomSource(tts.readAsBytesSync()));
      await player.play();
      ref.watch(audioRecordingStateProvider.notifier).state =
          AudioRecordingState.normal;
    } catch (e) {
      String error = e.toString();
      if (e is RequestFailedException) {
        error = e.message;
      }
      ref.watch(audioRecordingStateProvider.notifier).state =
          AudioRecordingState.normal;
      error.fail();
      chatItem.content = "";
      chatItem.status = MessageStatus.failed.index;
      userChatItem.status = MessageStatus.failed.index;
      ref
          .watch(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
          .update(chatItem);
      ref
          .watch(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
          .update(userChatItem);
    }
  }

  Widget getLottie(AudioRecordingState status) {
    if (status == AudioRecordingState.recording) {
      return Text(S.current.recording,
          style: Theme.of(context).textTheme.bodyMedium);
    }
    if (status == AudioRecordingState.canceling) {
      return Text(S.current.canceling,
          style: Theme.of(context).textTheme.bodyMedium);
    }
    if (status == AudioRecordingState.sending) {
      return Text(S.current.sending_server,
          style: Theme.of(context).textTheme.bodyMedium);
    }
    if (status == AudioRecordingState.speaking) {
      return Text(S.current.is_responsing,
          style: Theme.of(context).textTheme.bodyMedium);
    }
    return Text(S.current.hold_micro_phone_talk,
        style: Theme.of(context).textTheme.bodyMedium);
  }
}

// Feed your own stream of bytes into the player
class MyCustomSource extends StreamAudioSource {
  final List<int> bytes;

  MyCustomSource(this.bytes);

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    start ??= 0;
    end ??= bytes.length;
    return StreamAudioResponse(
      sourceLength: bytes.length,
      contentLength: end - start,
      offset: start,
      stream: Stream.value(bytes.sublist(start, end)),
      contentType: 'audio/mpeg',
    );
  }
}

///全局共享的当前生成音频聊天人声
final talkerProvider = StateProvider<String>((ref) {
  return talkers.first;
});
var talkers = [
  "Alloy",
  "Echo",
  "Fable",
  "Onyx",
  "Nova",
  "Shimmer",
];
