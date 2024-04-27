import 'dart:math';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/module/chat/chat_detail/chat_viewmodel.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:popover/popover.dart';

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
    record.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      supportedModels = HiveBox()
          .openAIConfig
          .values
          .where((element) => (element.getWhisperModels.isNotEmpty &&
              element.getTTSModels.isNotEmpty))
          .toList();
      ref.watch(currentGenerateAudioChatModelProvider.notifier).state =
          supportedModels.first;
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
      "请打开录音权限".fail();
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
  }

  void stopRecord() async {
    var path = await record.stop();

    if (path == null || path.isEmpty) {
      "无法获取到语音文件".fail();
      return;
    }
    if (!File(path).existsSync()) {
      return;
    }
    ref.watch(isGeneratingContentProvider.notifier).state = true;

    try {
      var model =
          ref.watch(currentGenerateAudioChatModelProvider.notifier).state;

      if (model == null) {
        ref.watch(isGeneratingContentProvider.notifier).state = false;
        "没有模型可用的模型".fail();
        return;
      }
      var content = await API().audio2OpenAIText(model, path);
      if (content.isNotEmpty) {
        sendMessage(model, content);
      } else {
        ref.watch(isGeneratingContentProvider.notifier).state = false;
        "没有识别到语音内容".fail();
      }
    } catch (e) {
      ref.watch(isGeneratingContentProvider.notifier).state = false;
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
          title: Row(
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
                      "语音聊天",
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
              Builder(builder: (context) {
                return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
                    child: Transform.rotate(
                      angle: pi / 2,
                      child: Icon(
                        CupertinoIcons.right_chevron,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        size: 16,
                      ),
                    )).click(() {
                  showPopover(
                    context: context,
                    backgroundColor: Theme.of(context).cardColor,
                    bodyBuilder: (context) => SingleChildScrollView(
                      child: Column(
                        children: [
                          ...supportedModels.map((e) {
                            return ListTile(
                              title: Text(e.alias ?? ""),
                              trailing: e.alias == supportedModel.alias
                                  ? Icon(
                                      CupertinoIcons.checkmark,
                                      color: Theme.of(context).primaryColor,
                                      size: 16,
                                    )
                                  : null,
                              onTap: () {
                                ref
                                    .watch(currentGenerateAudioChatModelProvider
                                        .notifier)
                                    .state = e;
                                Navigator.of(context).pop();
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                    onPop: () {},
                    direction: PopoverDirection.bottom,
                    constraints: BoxConstraints(
                      maxWidth: 220,
                      maxHeight: min(supportedModels.length * 55, F.height / 2),
                    ),
                    arrowHeight: 8,
                    arrowWidth: 15,
                  );
                });
              }),
            ],
          ),
        ),
        body: Consumer(builder: (context, ref, _) {
          var chat =
              ref.watch(chatProvider(specialGenerateAudioChatParentItemTime));
          return SizedBox();
        }),
        bottomNavigationBar: SizedBox(
          width: F.width,
          height:
              kBottomNavigationBarHeight + MediaQuery.paddingOf(context).bottom,
          child: SafeArea(
            bottom: true,
            top: false,
            child: Consumer(builder: (context, ref, _) {
              var state = ref.watch(audioChatStatusProvider);

              return IgnorePointer(
                ignoring: state == AudioChatStatus.sending,
                child: Opacity(
                  opacity: state == AudioChatStatus.sending ? 0.5 : 1,
                  child: Listener(
                    onPointerDown: (event) async {
                      ref.watch(audioChatStatusProvider.notifier).state =
                          AudioChatStatus.recording;
                      audioOverlay.showAudio(context);
                      startRecord();
                    },
                    onPointerUp: (event) {
                      audioOverlay.removeAudio();
                      if (ref.watch(audioChatStatusProvider.notifier).state ==
                          AudioChatStatus.canceling) {
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
                        ref.watch(audioChatStatusProvider.notifier).state =
                            AudioChatStatus.recording;
                      } else {
                        ref.watch(audioChatStatusProvider.notifier).state =
                            AudioChatStatus.canceling;
                      }
                      audioOverlay.update();
                    },
                    onPointerCancel: (event) {
                      audioOverlay.removeAudio();
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 30),
                      decoration: BoxDecoration(
                        color: ref.watch(themeProvider).inputPanelBg(),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        "按住说话",
                        style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 16),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      );
    });
  }

  final player = AudioPlayer();

  Future<void> sendMessage(AllModelBean model, String? text) async {
    ref.watch(audioChatStatusProvider.notifier).state = AudioChatStatus.sending;
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
      moduleType: model?.getDefaultModelType.id ?? "gpt-4",
      time: DateTime.now().millisecondsSinceEpoch,
    );
    await Future.delayed(const Duration(milliseconds: 50));
    ref
        .read(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
        .add(userChatItem);

    String result = "";
    var chatItem = ChatItem(
      type: ChatType.bot.index,
      messageType: MessageType.common.index,
      content: result,
      status: MessageStatus.loading.index,
      parentID: specialGenerateAudioChatParentItemTime,
      requestID: userChatItem.time,
      moduleName: model?.model ?? 0,
      moduleType: model?.defaultModelType?.id ?? "",
      time: DateTime.now().millisecondsSinceEpoch,
    );
    ref
        .read(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
        .add(chatItem);
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      var data = await API().createTextChatDirectly(
        double.parse("1.0"),
        model!,
        model.getDefaultModelType.id ?? "gpt-4",
        ref
            .watch(
                chatProvider(specialGenerateAudioChatParentItemTime).notifier)
            .chats,
      );

      chatItem.content = result;
      chatItem.status = MessageStatus.success.index;
      ref
          .read(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
          .update(chatItem);

      if (data.content == null || data.content!.isEmpty) {
        "生成内容为空".fail();
        return;
      }
      var tts = await API().text2TTS(data.content!, "");

      if (player.playing) {
        player.stop();
      }

      await player.setAudioSource(MyCustomSource(tts.readAsBytesSync()));
      await player.play();
      ref.watch(audioChatStatusProvider.notifier).state =
          AudioChatStatus.normal;
    } catch (e) {
      ref.watch(audioChatStatusProvider.notifier).state =
          AudioChatStatus.normal;
      e.toString().fail();
      chatItem.content = result;
      chatItem.status = MessageStatus.success.index;
      ref
          .read(chatProvider(specialGenerateAudioChatParentItemTime).notifier)
          .update(chatItem);
    }
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

final audioChatStatusProvider =
    StateProvider.autoDispose<AudioChatStatus>((ref) {
  return AudioChatStatus.normal;
});

enum AudioChatStatus {
  normal,
  recording,
  canceling,
  sending,
  speaking,
}
