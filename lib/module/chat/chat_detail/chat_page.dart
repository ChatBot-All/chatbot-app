import 'dart:async';
import 'dart:convert';
import 'package:ChatBot/base/components/chat_markdown.dart';
import 'package:ChatBot/base/components/send_button.dart';
import 'package:ChatBot/base/theme.dart';
import 'package:ChatBot/hive_bean/generate_content.dart';
import 'package:ChatBot/module/chat/chat_detail/chat_setting_page.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:record/record.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/components/components.dart';
import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:ChatBot/module/chat/chat_detail/chat_viewmodel.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../base/api.dart';
import '../../../base/components/autio_popover.dart';
import '../../../base/components/screenshot_view.dart';
import '../../../base/db/chat_item.dart';
import '../../../base/providers.dart';
import '../../../hive_bean/openai_bean.dart';
import '../chat_audio/chat_audio_page.dart';

class ChatPage extends ConsumerStatefulWidget {
  final bool showKeyboard;
  final ChatParentItem localChatHistory;

  const ChatPage({
    super.key,
    required this.localChatHistory,
    this.showKeyboard = false,
  });

  @override
  ConsumerState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final ScreenshotController _screenshotController = ScreenshotController();

  var player = AudioPlayer();

  bool isScrollManual = false;

  bool requestTitled = false;

  @override
  void initState() {
    super.initState();
    Permission.microphone.request();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut);
        if (ref.watch(sendButtonVisibleProvider.notifier).state == false) {
          ref.watch(sendButtonVisibleProvider.notifier).state = true;
        }
      } else {
        if (ref.watch(sendButtonVisibleProvider.notifier).state == true) {
          ref.watch(sendButtonVisibleProvider.notifier).state = false;
        }
      }
    });

    _scrollController.addListener(() {
      if (ref.watch(isGeneratingContentProvider) == false && isScrollManual) {
        if (_scrollController.position.pixels > 0 && _focusNode.hasFocus) {
          _focusNode.unfocus();
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Future.delayed(const Duration(milliseconds: 100), () {
        ref
            .watch(currentChatParentItemProvider.notifier)
            .update((state) => widget.localChatHistory);
        if (widget.showKeyboard) {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            _focusNode.requestFocus();
          });
        }
      });
    });
  }

  String? getRealModel(List<SupportedModels> state, String? model) {
    if (state.isEmpty) {
      return model;
    }
    var result = state.where((element) => element.id == model);
    if (result.isNotEmpty) {
      return result.first.id;
    }
    return state.first.id;
  }

  @override
  Widget build(BuildContext rootContext) {
    ref.listen(currentChatParentItemProvider, (pre, next) {
      if (next != null) {
        ref.watch(chatParentListProvider.notifier).update(next.copyWith());
      }
    });
    return Consumer(builder: (context, ref, _) {
      var result = ref.watch(currentChatParentItemProvider);

      if (result?.id == specialGenerateTextChatParentItemTime) {
        result?.title = S.current.new_chat;
      }

      AllModelBean currentModel = getModelByApiKey(result?.apiKey ?? "");

      var supportedModel = currentModel.getTextModels;
      var realModel = getRealModel(supportedModel, result?.moduleType);
      if (realModel != result?.moduleType) {
        WidgetsBinding.instance.endOfFrame.then((value) {
          result?.moduleType = realModel;

          var copyData = result?.copyWith(moduleType: realModel);

          ref
              .watch(currentChatParentItemProvider.notifier)
              .update((state) => copyData);
        });
      }

      if (result == null) {
        return Scaffold(
          appBar: AppBar(),
        );
      }
      return Builder(builder: (rootContext1) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              PullDownButton(
                routeTheme: const PullDownMenuRouteTheme(
                  width: 200,
                  accessibilityWidth: 200,
                ),
                buttonBuilder: (context, showMenu) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    CupertinoIcons.ellipsis,
                    color:
                        Theme.of(context).appBarTheme.actionsIconTheme?.color,
                  ),
                ).click(() {
                  showMenu();
                }),
                itemBuilder: (BuildContext context) {
                  return [
                    PullDownMenuTitle(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: Text(
                          S.current.chat_setting,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    PullDownMenuItem(
                      title: S.current.chat_setting,
                      onTap: () {
                        F.push(const ChatSettingPage());
                      },
                    ),
                    PullDownMenuTitle(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: Text(
                          S.current.function,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    PullDownMenuItem(
                      title: S.current.screenshot,
                      onTap: () {
                        S.current.loading.loading();
                        var list = ref
                            .watch(chatProvider(result.id ?? 0).notifier)
                            .chats;
                        _screenshotController
                            .captureFromLongWidget(
                          InheritedTheme.captureAll(
                            rootContext,
                            ProviderScope(
                              child: ScreenShotChatPage(
                                list: list,
                                rootContext: rootContext,
                                result: result,
                              ),
                            ),
                          ),
                          delay: const Duration(milliseconds: 100),
                          context: rootContext,
                          constraints: BoxConstraints(
                            maxWidth: F.width,
                            minWidth: F.width,
                            maxHeight: double.infinity,
                          ),
                          pixelRatio: 2,
                        )
                            .then((value) async {
                          Uint8List imageFile;

                          try {
                            imageFile = value;
                            final imagePath =
                                '${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.png';
                            File(imagePath).writeAsBytesSync(imageFile);
                            await Gal.putImage(imagePath);
                            S.current.save_success.success();
                            Share.shareXFiles([XFile(imagePath)]);
                          } catch (e) {
                            print(e);
                            S.current.save_fail.fail();
                          }
                        });
                      },
                    ),
                    PullDownMenuItem(
                        title: "${S.current.share_to} ShareGPT",
                        onTap: () async {
                          S.current.loading.loading();
                          var url = await API().share2ShareGPT(ref
                              .watch(chatProvider(result.id ?? 0).notifier)
                              .chats);
                          if (url != null && context.mounted) {
                            showCommonDialog(
                              context,
                              title: S.current.reminder,
                              hideCancelBtn: true,
                              content: url,
                              confirmText: S.current.copy,
                              confirmCallback: () {
                                url.toClipboard();
                              },
                            );
                          }
                        }),
                  ];
                },
              ),
            ],
            title: Builder(builder: (context) {
              return PullDownButton(
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
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: F.width * 0.5,
                            ),
                            child: Text(
                              result.title ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).appBarTheme.titleTextStyle,
                            ),
                          ),
                          Text(
                            "(${getModelByApiKey(result.apiKey ?? "").alias.toString()})${result.moduleType?.replaceFirst("models/", "").toString() ?? ""}",
                            style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Theme.of(context).primaryColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      CupertinoIcons.chevron_up_chevron_down,
                      color:
                          Theme.of(context).appBarTheme.titleTextStyle?.color,
                      size: 16,
                    ),
                  ],
                ).click(() {
                  showMenu();
                }),
                itemBuilder: (BuildContext context) {
                  return supportedModel
                      .where((element) =>
                          element.id != null && element.id!.isNotEmpty)
                      .map(
                        (e) => PullDownMenuItem(
                          onTap: () {
                            result.moduleType = e.id;
                            ref
                                .watch(currentChatParentItemProvider.notifier)
                                .update((state) => result.copyWith(
                                      moduleType: e.id,
                                    ));
                          },
                          title: e.id?.replaceFirst("models/", "") ?? "",
                          iconColor: Theme.of(context).primaryColor,
                          icon: e.id != result.moduleType
                              ? null
                              : CupertinoIcons.checkmark_alt,
                        ),
                      )
                      .toList();
                },
              );
            }),
          ),
          body: Consumer(builder: (context, ref, _) {
            var chat = ref.watch(chatProvider(result.id ?? 0));
            return MultiStateWidget(
                value: chat,
                data: (list) {
                  if (requestTitled == false &&
                      list.length >= 2 &&
                      result.title == S.current.new_chat &&
                      result.id != specialGenerateTextChatParentItemTime &&
                      ref.watch(isGeneratingContentProvider) == false &&
                      ref.watch(autoGenerateTitleProvider.notifier).value ==
                          true) {
                    //list里的前2条状态必须是成功

                    requestTitled = true;
                    API().generateChatTitle(
                        result.temperature ?? HiveBox().temperature,
                        getModelByApiKey(result.apiKey ?? ""),
                        result.moduleType!,
                        list, []).then((value) {
                      ref
                          .watch(currentChatParentItemProvider.notifier)
                          .update((state) => result.copyWith(title: value));
                    }).catchError((e) {
                    });
                  }
                  return Column(
                    children: [
                      Expanded(
                        child: Listener(
                          behavior: HitTestBehavior.opaque,
                          onPointerDown: (event) {
                            isScrollManual = false;
                          },
                          onPointerMove: (event) {
                            isScrollManual = true;
                          },
                          onPointerCancel: (event) {
                            isScrollManual = false;
                          },
                          onPointerUp: (event) {
                            isScrollManual = false;
                          },
                          child: Screenshot(
                            controller: _screenshotController,
                            child: ListView.builder(
                              reverse: true,
                              physics: const AlwaysScrollableScrollPhysics(),
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                var item = list[list.length - 1 - index];

                                Widget resultWidget;
                                if (item.type == ChatType.user.index) {
                                  resultWidget = UserMessage(
                                    chatItem: item,
                                    resendMessage: (content) {
                                      sendMessage(
                                          result.id, content, item.images);
                                    },
                                    sendMessageAgain: (content) {
                                      sendMessage(
                                          result.id, content, item.images);
                                    },
                                    ttsCallBack:
                                        currentModel.getTTSModels.isEmpty
                                            ? null
                                            : (content) {
                                                playText(currentModel, content);
                                              },
                                  );
                                } else if (item.type == ChatType.bot.index) {
                                  resultWidget = BotMessage(
                                    chatItem: item,
                                    ttsCallBack:
                                        currentModel.getTTSModels.isEmpty
                                            ? null
                                            : (content) {
                                                playText(currentModel, content);
                                              },
                                  );
                                } else {
                                  resultWidget = AssistMessage(chatItem: item);
                                }
                                return resultWidget;
                              },
                              itemCount: list.length,
                            ),
                          ),
                        ),
                      ),
                      ChatPanel(
                        focusNode: _focusNode,
                        supportImage: true,
                        supportAudio: getModelByApiKey(result.apiKey ?? "")
                            .getWhisperModels
                            .isNotEmpty,
                        scrollToTop: () {
                          _scrollController.animateTo(0,
                              duration: const Duration(milliseconds: 100),
                              curve: Curves.easeInOut);
                        },
                        sendMessage: (content, images) async {
                          await sendMessage(result.id, content, images);
                        },
                        cancelSend: () {
                          _streamSubscription?.cancel();
                          ref
                              .watch(imagesProvider.notifier)
                              .update((state) => []);
                          ChatItem lastOne = ref
                              .watch(chatProvider(result.id ?? 0).notifier)
                              .chats
                              .last;
                          lastOne.status = MessageStatus.canceled.index;
                          ref
                              .watch(chatProvider(result.id ?? 0).notifier)
                              .update(lastOne);
                          ref
                              .watch(isGeneratingContentProvider.notifier)
                              .state = false;
                        },
                      ),
                    ],
                  );
                });
          }),
        );
      });
    });
  }

  StreamSubscription<GenerateContentBean>? _streamSubscription;

  Future<void> sendMessage(
      int? id, String? text, List<String>? sendImages) async {
    ref.watch(isGeneratingContentProvider.notifier).state = true;
    var userChatItem = ChatItem(
      type: ChatType.user.index,
      content: text,
      status: MessageStatus.success.index,
      parentID: id,
      images: sendImages,
      moduleName:
          ref.watch(currentChatParentItemProvider.notifier).state!.moduleName!,
      messageType: MessageType.common.index,
      moduleType:
          ref.watch(currentChatParentItemProvider.notifier).state?.moduleType ??
              "",
      time: DateTime.now().millisecondsSinceEpoch,
    );
    await Future.delayed(const Duration(milliseconds: 50));
    ref.read(chatProvider(id!).notifier).add(userChatItem);

    String result = "";
    var chatItem = ChatItem(
      type: ChatType.bot.index,
      messageType: MessageType.common.index,
      content: result,
      status: MessageStatus.loading.index,
      parentID: id,
      requestID: userChatItem.time,
      moduleName:
          ref.watch(currentChatParentItemProvider.notifier).state!.moduleName!,
      moduleType:
          ref.watch(currentChatParentItemProvider.notifier).state!.moduleType!,
      time: DateTime.now().millisecondsSinceEpoch,
    );
    ref.read(chatProvider(id).notifier).add(chatItem);
    await Future.delayed(const Duration(milliseconds: 50));
    ref.watch(imagesProvider.notifier).update((state) => []);

    var chatParentItem =
        ref.watch(currentChatParentItemProvider.notifier).state!;
    _streamSubscription = (await API().streamGenerateContent(
      chatParentItem.temperature ?? HiveBox().temperature,
      getModelByApiKey(
          ref.watch(currentChatParentItemProvider.notifier).state!.apiKey!),
      ref.watch(currentChatParentItemProvider.notifier).state!.moduleType!,
      ref.watch(chatProvider(id).notifier).chats,
      [],
      id == specialGenerateTextChatParentItemTime,
    ))
        .listen((event) {
      result += event.content ?? "";
      result.i();
      chatItem.content = result;
      chatItem.status = MessageStatus.success.index;
      ref.read(chatProvider(id).notifier).update(chatItem);
    }, onDone: () {
      ref.watch(isGeneratingContentProvider.notifier).state = false;
      _streamSubscription?.cancel();
      ref.watch(imagesProvider.notifier).update((state) => []);
    }, onError: (e) {
      String errorContent = "";
      if (e is RequestFailedException) {
        errorContent = """
requestFailedException:\n
  message:${e.message}
  statusCode:${e.statusCode}""";
      } else {
        errorContent = e.toString();
      }
      userChatItem.status = MessageStatus.failed.index;
      ref.read(chatProvider(id).notifier).update(userChatItem);
      chatItem.content = errorContent;
      chatItem.status = MessageStatus.failed.index;
      ref.read(chatProvider(id).notifier).update(chatItem);
      ref.watch(isGeneratingContentProvider.notifier).state = false;
      _streamSubscription?.cancel();
      ref.watch(imagesProvider.notifier).update((state) => []);
      e.toString().fail();
    }, cancelOnError: true);
  }

  void playText(AllModelBean bean, String content) async {
    if (bean.getTTSModels.isEmpty) {
      return;
    }
    var tts = await API()
        .text2TTS(bean, content, ref.watch(talkerProvider.notifier).state);

    if (player.playing) {
      player.stop();
    }
    if (tts == null) {
      return;
    }

    await player.setAudioSource(MyCustomSource(tts.readAsBytesSync()));
    await player.play();
  }

  @override
  void dispose() {
    player.dispose();
    _streamSubscription?.cancel();
    super.dispose();
  }
}

typedef SendMessageCall = Future<void> Function(
    String content, List<String> images);
typedef CancelSendCall = void Function();

class ChatPanel extends ConsumerStatefulWidget {
  final FocusNode focusNode;
  final VoidCallback scrollToTop;
  final bool supportAudio;
  final bool supportImage;
  final SendMessageCall sendMessage;
  final CancelSendCall cancelSend;

  const ChatPanel({
    super.key,
    required this.focusNode,
    required this.supportAudio,
    required this.supportImage,
    required this.scrollToTop,
    required this.sendMessage,
    required this.cancelSend,
  });

  @override
  ConsumerState<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<ChatPanel> {
  final TextEditingController _controller = TextEditingController();
  final AudioOverlay audioOverlay = AudioOverlay();

  final record = AudioRecorder();
  String? audioPath;
  DateTime? startTime;

  void startRecord() async {
    if (await record.hasPermission()) {
      startTime = null;
      audioPath =
          "${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.m4a";
      await record.start(const RecordConfig(), path: audioPath!);
      startTime = DateTime.now();
    } else {
      await Permission.microphone.request();
      S.current.open_micro_permission.toString();
      audioOverlay.removeAudio();
    }
  }

  void cancel() {
    try {
      startTime = null;
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
    if (DateTime.now().millisecondsSinceEpoch -
            (startTime?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch) <
        1000) {
      S.current.record_time_too_short.fail();
      ref.watch(audioRecordingStateProvider.notifier).state =
          AudioRecordingState.normal;
      await record.stop();
      return;
    }
    var path = await record.stop();

    if (path == null || path.isEmpty) {
      S.current.no_audio_file.fail();
      return;
    }
    if (!File(path).existsSync()) {
      return;
    }
    ref.watch(isGeneratingContentProvider.notifier).state = true;

    try {
      AllModelBean bean = getModelByApiKey(
          ref.watch(currentChatParentItemProvider.notifier).state?.apiKey ??
              "");
      var content = await API().tts2Text(bean, path);
      if (content != null && content.isNotEmpty) {
        _controller.text = content;
        sendMessage();
      } else {
        ref.watch(isGeneratingContentProvider.notifier).state = false;
      }
    } catch (e) {
      ref.watch(isGeneratingContentProvider.notifier).state = false;
      e.toString().fail();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10, right: 15),
      decoration: BoxDecoration(
        color: ref.watch(themeProvider).xffF6F6F6(),
      ),
      child: SafeArea(
        bottom: true,
        top: false,
        child: Column(
          children: [
            Consumer(builder: (context, ref, _) {
              var images = ref.watch(imagesProvider);
              if (images.isEmpty) {
                return const SizedBox();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return LayoutBuilder(builder: (context, c) {
                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.memory(
                                  base64Decode(images[index]),
                                  width: c.maxWidth - 10,
                                  height: c.maxHeight - 10,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: const Icon(
                                CupertinoIcons.xmark_circle_fill,
                                size: 20,
                                color: Color(0xffD0D0D0),
                              ).click(() {
                                ref
                                    .read(imagesProvider.notifier)
                                    .update((state) {
                                  return [...state..removeAt(index)];
                                });
                              }),
                            ),
                          ],
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              );
            }),
            SizedBox(
              height: kBottomNavigationBarHeight,
              child: Consumer(builder: (context, ref, _) {
                var inputMode = ref.watch(inputModeProvider);
                var disableMode = ref.watch(isGeneratingContentProvider);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //选择图片
                    const SizedBox(
                      width: 15,
                    ),
                    // addImage(),
                    if (widget.supportAudio) audioButton(inputMode),
                    if (widget.supportAudio)
                      const SizedBox(
                        width: 15,
                      ),
                    Expanded(
                      child: AnimatedCrossFade(
                        duration: const Duration(milliseconds: 100),
                        firstChild: IgnorePointer(
                          ignoring: disableMode,
                          child: Listener(
                            onPointerDown: (event) async {
                              ref
                                  .watch(audioRecordingStateProvider.notifier)
                                  .state = AudioRecordingState.recording;
                              audioOverlay.showAudio(context);
                              startRecord();
                            },
                            onPointerUp: (event) {
                              audioOverlay.removeAudio();
                              if (ref
                                      .watch(
                                          audioRecordingStateProvider.notifier)
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

                              double paddingBottom = F.height - offset.dy;

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
                              ref
                                  .watch(audioRecordingStateProvider.notifier)
                                  .state = AudioRecordingState.normal;
                              audioOverlay.removeAudio();
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: ref.watch(themeProvider).inputPanelBg(),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                S.current.hold_talk,
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.color,
                                    fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                        secondChild: CupertinoTextField(
                          focusNode: widget.focusNode,
                          enabled: !disableMode,
                          placeholder: S.current.input_text,
                          controller: _controller,
                          maxLines: 5,
                          minLines: 1,
                          cursorColor: Theme.of(context).primaryColor,
                          style: Theme.of(context).textTheme.titleMedium,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: ref.watch(themeProvider).inputPanelBg(),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        crossFadeState: !inputMode
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Consumer(builder: (context, ref, _) {
                      return AnimatedCrossFade(
                        duration: const Duration(milliseconds: 100),
                        firstChild: sendButton(disableMode),
                        secondChild: addImage(widget.supportImage),
                        crossFadeState:
                            (ref.watch(sendButtonVisibleProvider) == true ||
                                    disableMode == true)
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                      );
                    }),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget audioButton(bool inputMode) {
    return Builder(builder: (context) {
      return SizedBox(
        width: 30,
        height: 30,
        child: Icon(
          !inputMode ? CupertinoIcons.pencil_circle : CupertinoIcons.mic_circle,
          color: Theme.of(context).textTheme.titleMedium?.color,
          size: 30,
        ),
      ).click(() {
        ref.watch(inputModeProvider.notifier).state =
            !ref.watch(inputModeProvider.notifier).state;
      });
    });
  }

  Widget sendButton(bool isGenerateContent) {
    return SizedBox(
      width: 60,
      height: 30,
      child: Builder(builder: (context) {
        if (isGenerateContent) {
          return Center(
            child: SizedBox(
              width: 30,
              height: 30,
              child: WaitingSendButton(onPressed: () {
                widget.cancelSend();
              }),
            ),
          );
        }

        return SendButton(onPressed: () {
          sendMessage();
        });
      }),
    );
  }

  Widget addImage(bool supportImage) {
    if (!supportImage) {
      return const SizedBox();
    }
    return Builder(builder: (context) {
      return SizedBox(
        width: 30,
        height: 30,
        child: Icon(
          Icons.add_circle_outline,
          color: Theme.of(context).textTheme.titleMedium?.color,
          size: 30,
        ),
      ).click(() {
        if (ref.watch(isGeneratingContentProvider.notifier).state == true) {
          return;
        }

        ImagePicker images = ImagePicker();
        images.pickMultiImage().then(
          (value) async {
            //压缩图片，然后把图片转换成base64

            List<Uint8List> images = [];

            for (int i = 0; i < value.length; i++) {
              var result = await FlutterImageCompress.compressWithFile(
                value[i].path,
                minWidth: 200,
                minHeight: 200,
                quality: 94,
              );
              images.add(result ?? Uint8List.fromList([]));
            }

            ref.read(imagesProvider.notifier).update((state) {
              return [
                ...state,
                ...images.map((e) => base64Encode(e)).toList(),
              ];
            });
          },
        );
      });
    });
  }

  StreamSubscription<GenerateContentBean>? _streamSubscription;

  void sendMessage({String? text, List<String>? images}) async {
    if (_controller.text.isEmpty && text != null) {
      _controller.text = text;
    }
    List<String>? sendImages;
    if (images != null) {
      sendImages = images;
    } else {
      sendImages = ref.watch(imagesProvider.notifier).state;
    }

    if (_controller.text.isEmpty) {
      S.current.input_text.toast();
      return;
    }
    if (_controller.text.endsWith("\n")) {
      _controller.text =
          _controller.text.substring(0, _controller.text.length - 1);
    }
    await widget.sendMessage(_controller.text, sendImages);
    _controller.text = "";
  }

  @override
  void dispose() {
    record.dispose();
    _streamSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

List<PullDownMenuEntry> getMessageActions2(
    BuildContext context,
    WidgetRef ref,
    ChatItem chatItem,
    ResendMessage? resendMessage,
    SendMessageAgain? sendMessageAgain,
    TTSCallBack? ttsCallBack) {
  return [
    if (resendMessage != null)
      PullDownMenuItem(
        icon: CupertinoIcons.arrow_counterclockwise,
        title: S.current.resend,
        onTap: () {
          resendMessage(chatItem.content ?? "");
        },
      ),
    if (sendMessageAgain != null)
      PullDownMenuItem(
        icon: CupertinoIcons.arrow_2_circlepath,
        title: S.current.send_again,
        onTap: () {
          sendMessageAgain(chatItem.content ?? "");
        },
      ),

    if (ttsCallBack != null)
      PullDownMenuItem(
        icon: CupertinoIcons.volume_up,
        title: S.current.tts,
        onTap: () {
          ttsCallBack(chatItem.content ?? "");
        },
      ),
    PullDownMenuItem(
      icon: CupertinoIcons.doc_on_doc,
      title: S.current.copy,
      onTap: () {
        (chatItem.content ?? "").toClipboard();
      },
    ),
    //分享
    PullDownMenuItem(
      icon: CupertinoIcons.arrowshape_turn_up_right,
      title: S.current.share,
      onTap: () {
        Share.share(chatItem.content ?? "");
      },
    ),
    PullDownMenuItem(
      icon: CupertinoIcons.delete,
      isDestructive: true,
      title: S.current.delete,
      onTap: () {
        Future.delayed(const Duration(milliseconds: 100), () {
          showCommonDialog(
            context,
            content: S.current.delete_reminder,
            title: S.current.reminder,
            confirmText: S.current.delete,
            confirmCallback: () {
              ref
                  .read(chatProvider(chatItem.parentID ?? 0).notifier)
                  .remove(chatItem);
            },
          );
        });
      },
    ),
  ];
}

typedef ResendMessage = void Function(String content);
typedef SendMessageAgain = void Function(String content);
typedef TTSCallBack = void Function(String content);

class UserMessage extends ConsumerWidget {
  final ChatItem chatItem;
  final ResendMessage resendMessage;
  final SendMessageAgain sendMessageAgain;
  final TTSCallBack? ttsCallBack;
  final bool hideResend;

  const UserMessage(
      {super.key,
      required this.chatItem,
      required this.resendMessage,
      required this.sendMessageAgain,
      this.ttsCallBack,
      this.hideResend = false});

  @override
  Widget build(BuildContext context, ref) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //重试
            if (chatItem.status == MessageStatus.failed.index)
              Consumer(builder: (context, ref, _) {
                return const Icon(CupertinoIcons.exclamationmark_circle_fill,
                        color: Colors.red, size: 20)
                    .click(() {
                  showCommonDialog(
                    context,
                    title: S.current.reminder,
                    confirmCallback: () {
                      ref
                          .watch(chatProvider(chatItem.parentID ?? 0).notifier)
                          .remove(chatItem, connectOtherTimeID: true);
                      resendMessage(chatItem.content ?? "");
                    },
                    content: S.current.conform_resend,
                    confirmText: S.current.confirm,
                  );
                }, enable: ref.watch(isGeneratingContentProvider) == false);
              }),
            const SizedBox(width: 10),
            PullDownButton(
              scrollController: ScrollController(),
              itemBuilder: (context) => getMessageActions2(
                context,
                ref,
                chatItem,
                hideResend
                    ? null
                    : (content) {
                        ref
                            .watch(
                                chatProvider(chatItem.parentID ?? 0).notifier)
                            .remove(chatItem, connectOtherTimeID: true);
                        resendMessage(content);
                      },
                (content) {
                  sendMessageAgain(content);
                },
                ttsCallBack,
              ),
              buttonBuilder: (context, showMenu) => GestureDetector(
                onLongPress: () {
                  showMenu();
                },
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: F.width * 0.8,
                    minWidth: 10,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (chatItem.images != null &&
                          chatItem.images!.isNotEmpty &&
                          (chatItem.images!
                                  .where((element) => element.isEmpty)
                                  .length !=
                              chatItem.images!.length))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            runAlignment: WrapAlignment.end,
                            direction: Axis.horizontal,
                            children: [
                              ...chatItem.images!
                                  .where((element) => element.isNotEmpty)
                                  .map((e) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(
                                    base64Decode(e),
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      if (chatItem.images != null &&
                          chatItem.images!.isNotEmpty &&
                          (chatItem.images!
                                  .where((element) => element.isEmpty)
                                  .length !=
                              chatItem.images!.length))
                        const SizedBox(height: 10),
                      Text(
                        chatItem.content ?? "",
                        style: const TextStyle(
                          color: Color(0xff091807),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BotMessage extends ConsumerWidget {
  final ChatItem chatItem;
  final TTSCallBack? ttsCallBack;

  const BotMessage({super.key, required this.chatItem, this.ttsCallBack});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            chatItem.moduleType?.replaceFirst("models/", "") ?? "",
            style:
                TextStyle(fontSize: 13, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 5),
          PullDownButton(
            scrollController: ScrollController(),
            itemBuilder: (context) => getMessageActions2(
                context, ref, chatItem, null, null, ttsCallBack),
            buttonBuilder: (context, showMenu) => GestureDetector(
              onLongPress: () {
                showMenu();
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: F.width * 0.7,
                  minWidth: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: getMessage(ref, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getMessage(WidgetRef ref, BuildContext context) {
    if (chatItem.status == MessageStatus.loading.index) {
      return Container(
        width: F.width * 0.2,
        alignment: Alignment.center,
        child: SizedBox(
          width: 40,
          child: LoadingAnimationWidget.prograssiveDots(
            color: Theme.of(context).primaryColor,
            size: 40,
          ),
        ),
      );
    } else if (chatItem.status == MessageStatus.success.index) {
      //Markdown 适配暗黑主题
      return ChatMarkDown(content: chatItem.content ?? "");
    } else if (chatItem.status == MessageStatus.failed.index) {
      return ChatMarkDown(content: chatItem.content ?? "");
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(
          chatItem.content ?? "canceled by user",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
    }
  }

  bool isMarkdown(String text) {
    // 定义一系列Markdown的正则表达式模式
    final List<RegExp> markdownPatterns = [
      RegExp(r'^\s*#', multiLine: true), // 标题
      RegExp(r'\*\*(.*?)\*\*'), // 加粗
      RegExp(r'\*(.*?)\*'), // 斜体
      RegExp(r'!\[.*?\]\(.*?\)'), // 图片
      RegExp(r'\[.*?\]\(.*?\)'), // 链接
      RegExp(r'^```(.*?)```', multiLine: true), // 代码块
      RegExp(r'^\s*-\s', multiLine: true), // 无序列表
      RegExp(r'^\s*\d+\.\s', multiLine: true), // 有序列表
    ];

    // 检查文本是否匹配Markdown的任何特征
    for (var pattern in markdownPatterns) {
      if (pattern.hasMatch(text)) {
        return true; // 如果找到匹配项，则假定文本是Markdown格式
      }
    }

    return false; // 如果没有找到任何匹配项，则假定文本不是Markdown格式
  }
}

class AssistMessage extends StatelessWidget {
  final ChatItem chatItem;

  const AssistMessage({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
      alignment: Alignment.center,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: F.width * 0.9,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          chatItem.content ?? "",
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    );
  }
}
