import 'package:ChatBot/base/components/chat_markdown.dart';
import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/module/chat/chat_detail/chat_page.dart';
import 'package:ChatBot/module/photoview_page.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:dio/dio.dart';
import 'package:extended_image/extended_image.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/components/components.dart';
import 'package:ChatBot/module/chat/chat_detail/chat_viewmodel.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../base/api.dart';
import '../../../base/components/screenshot_view.dart';
import '../../../base/db/chat_item.dart';

class ChatImagePage extends ConsumerStatefulWidget {
  final bool showKeyboard;

  const ChatImagePage({super.key, this.showKeyboard = false});

  @override
  ConsumerState createState() => _ChatImagePageState();
}

class _ChatImagePageState extends ConsumerState<ChatImagePage> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final ScreenshotController _screenshotController = ScreenshotController();

  bool isScrollManual = false;

  bool requestTitled = false;

  List<AllModelBean> supportedModels = [];

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
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
      if (ref.watch(isGeneratingContentProvider) == false && isScrollManual && _focusNode.hasFocus) {
        if (_scrollController.position.pixels != 0) {
          _focusNode.unfocus();
        }
      }
    });
    supportedModels = HiveBox().openAIConfig.values.where((element) => (element.getDallModels.isNotEmpty)).toList();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ///查找出所有支持"dall-e-3"的模型
      ref.watch(currentGenerateImageModelProvider.notifier).state = supportedModels.first;
      if (widget.showKeyboard) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          _focusNode.requestFocus();
        });
      }
    });
  }

  String valueStrByOpenAIImageSize(OpenAIImageSize item) {
    switch (item) {
      case OpenAIImageSize.size256:
        return "256x256";
      case OpenAIImageSize.size512:
        return "512x512";
      case OpenAIImageSize.size1024:
        return "1024x1024";
      case OpenAIImageSize.size1792Horizontal:
        return "1792x1024";
      case OpenAIImageSize.size1792Vertical:
        return "1024x1792";
    }
  }

  String valueStrByOpenAIImageStyle(OpenAIImageStyle item) {
    switch (item) {
      case OpenAIImageStyle.vivid:
        return S.current.vivid;
      case OpenAIImageStyle.natural:
        return S.current.natural;
    }
  }

  @override
  Widget build(BuildContext rootContext) {
    return Consumer(builder: (context, ref, _) {
      var supportedModel = ref.watch(currentGenerateImageModelProvider);

      if (supportedModel == null) return const Scaffold();
      return Scaffold(
        appBar: AppBar(
          actions: [
            Builder(builder: (context) {
              return PullDownButton(
                scrollController: ScrollController(),
                itemBuilder: (context) {
                  return [
                    PullDownMenuTitle(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: Text(
                          S.current.size,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    ...OpenAIImageSize.values
                        .map<PullDownMenuItem>((e) => PullDownMenuItem(
                              title: valueStrByOpenAIImageSize(e),
                              iconColor: Theme.of(context).primaryColor,
                              icon: e == ref.watch(openAIImageSizeProvider.notifier).state
                                  ? CupertinoIcons.checkmark_alt
                                  : null,
                              onTap: () {
                                ref.watch(openAIImageSizeProvider.notifier).state = e;
                              },
                            ))
                        .toList(),
                    PullDownMenuTitle(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 5, top: 5),
                        child: Text(
                          S.current.style,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                    ...OpenAIImageStyle.values.map((e) {
                      return PullDownMenuItem(
                        title: valueStrByOpenAIImageStyle(e),
                        iconColor: Theme.of(context).primaryColor,
                        icon: e == ref.watch(openAIImageStyleProvider.notifier).state ? CupertinoIcons.checkmark : null,
                        onTap: () {
                          ref.watch(openAIImageStyleProvider.notifier).state = e;
                        },
                      );
                    }),
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
                        var list = ref.watch(chatProvider(specialGenerateImageChatParentItemTime).notifier).chats;
                        _screenshotController
                            .captureFromLongWidget(
                          InheritedTheme.captureAll(
                            rootContext,
                            ProviderScope(
                              child: ScreenShotChatImagePage(
                                list: list,
                                rootContext: rootContext,
                                result: ChatParentItem(
                                  title: S.current.generate_image,
                                  moduleType: "dall-e-3",
                                  moduleName: supportedModel.model,
                                ),
                              ),
                            ),
                          ),
                          delay: const Duration(milliseconds: 100),
                          context: rootContext,
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
          title: PullDownButton(
            scrollController: ScrollController(),
            itemBuilder: (context) => supportedModels.map((e) {
              return PullDownMenuItem(
                title: e.alias ?? "",
                iconColor: Theme.of(context).primaryColor,
                icon: e.alias != supportedModel.alias ? null : CupertinoIcons.checkmark_alt,
                onTap: () {
                  ref.watch(currentGenerateImageModelProvider.notifier).state = e;
                },
              );
            }).toList(),
            buttonBuilder: (context, showMenu) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: F.width * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        S.current.generate_image,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                      Text(
                        "(${getModelByApiKey(supportedModel.apiKey!).alias.toString()})dall-e-3",
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
                  color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                  size: 16,
                ),
              ],
            ).click(() {
              showMenu();
            }),
          ),
        ),
        body: Consumer(builder: (context, ref, _) {
          var chat = ref.watch(chatProvider(specialGenerateImageChatParentItemTime));
          return MultiStateWidget(
              value: chat,
              data: (list) {
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
                        child: ListView.builder(
                          reverse: true,
                          physics: const ClampingScrollPhysics(),
                          controller: _scrollController,
                          itemBuilder: (context, index) {
                            var item = list[list.length - 1 - index];

                            Widget resultWidget;
                            if (item.type == ChatType.user.index) {
                              resultWidget = UserMessage(
                                chatItem: item,
                                hideResend: true,
                                resendMessage: (content) {
                                  //删除自己和关联的bot消息
                                  ref
                                      .watch(chatProvider(supportedModel.time ?? 0).notifier)
                                      .remove(item, connectOtherTimeID: true);
                                  sendMessage(content);
                                },
                                sendMessageAgain: (content) {
                                  sendMessage(content);
                                },
                              );
                            } else if (item.type == ChatType.bot.index) {
                              resultWidget = BotImageMessage(
                                chatItem: item,
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
                    ChatPanel(
                      focusNode: _focusNode,
                      scrollToTop: () {
                        _scrollController.animateTo(0,
                            duration: const Duration(milliseconds: 100), curve: Curves.easeInOut);
                      },
                      supportAudio: supportedModel.getWhisperModels.isNotEmpty,
                      sendMessage: (content, images) async {
                        sendMessage(content);
                      },
                      cancelSend: () {
                        ChatItem lastOne =
                            ref.watch(chatProvider(specialGenerateImageChatParentItemTime).notifier).chats.last;
                        lastOne.content = "canceled by user";
                        lastOne.status = MessageStatus.canceled.index;
                        ref.watch(chatProvider(specialGenerateImageChatParentItemTime).notifier).update(lastOne);
                        ref.watch(isGeneratingContentProvider.notifier).state = false;
                      },
                      supportImage: false,
                    ),
                  ],
                );
              });
        }),
      );
    });
  }

  Future<void> sendMessage(String content) async {
    ref.watch(isGeneratingContentProvider.notifier).state = true;
    var userChatItem = ChatItem(
      type: ChatType.user.index,
      content: content,
      status: MessageStatus.success.index,
      parentID: specialGenerateImageChatParentItemTime,
      messageType: MessageType.image.index,
      moduleType: "dall-e-3",
      moduleName: ref.watch(currentGenerateImageModelProvider.notifier).state!.model,
      time: DateTime.now().millisecondsSinceEpoch,
    );

    await Future.delayed(const Duration(milliseconds: 50));
    ref.read(chatProvider(specialGenerateImageChatParentItemTime).notifier).add(userChatItem);

    String result = "";
    var botChatItem = ChatItem(
      type: ChatType.bot.index,
      content: result,
      status: MessageStatus.loading.index,
      parentID: specialGenerateImageChatParentItemTime,
      requestID: userChatItem.time,
      messageType: MessageType.image.index,
      moduleName: ref.watch(currentGenerateImageModelProvider.notifier).state!.model,
      moduleType: "dall-e-3",
      time: DateTime.now().millisecondsSinceEpoch,
    );
    ref.read(chatProvider(specialGenerateImageChatParentItemTime).notifier).add(botChatItem);
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      var resultImages = await API().generateOpenAIImage(
        ref.watch(currentGenerateImageModelProvider.notifier).state!,
        userChatItem.content ?? "",
        ref.watch(openAIImageStyleProvider.notifier).state,
        ref.watch(openAIImageSizeProvider.notifier).state,
      );
      botChatItem.images = resultImages.map((e) => e.url ?? "").toList();
      botChatItem.messageType = MessageType.image.index;
      if (botChatItem.images?.isNotEmpty ?? false) {
        botChatItem.status = MessageStatus.success.index;
      } else {
        botChatItem.status = MessageStatus.failed.index;
        botChatItem.content = S.current.generate_image_fail;
      }
      ref.read(isGeneratingContentProvider.notifier).state = false;
      ref.read(chatProvider(specialGenerateImageChatParentItemTime).notifier).update(botChatItem);
    } catch (e) {
      userChatItem.status = MessageStatus.failed.index;
      ref.read(chatProvider(specialGenerateImageChatParentItemTime).notifier).update(userChatItem);
      botChatItem.content = e.toString();
      botChatItem.status = MessageStatus.failed.index;
      ref.read(isGeneratingContentProvider.notifier).state = false;
      ref.read(chatProvider(specialGenerateImageChatParentItemTime).notifier).update(botChatItem);
    }
  }
}

List<PullDownMenuItem> getImageMessageActions2(BuildContext context, WidgetRef ref, ChatItem chatItem,
    ResendMessage? resendMessage, SendMessageAgain? sendMessageAgain) {
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

    if (chatItem.images?.isNotEmpty ?? false)
      PullDownMenuItem(
        icon: CupertinoIcons.arrow_down_circle,
        title: S.current.save_gallary,
        onTap: () async {
          S.current.downloading.loading();
          try {
            final imagePath =
                '${(await getApplicationDocumentsDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}.png';
            await Dio().download(chatItem.images!.first, imagePath);
            await Gal.putImage(imagePath);
            S.current.save_success.success();
          } catch (e) {
            print(e);
            S.current.save_fail.fail();
          }
        },
      ),
    //分享
    if (chatItem.images?.isNotEmpty ?? false)
      PullDownMenuItem(
        icon: CupertinoIcons.arrowshape_turn_up_right,
        title: S.current.share,
        onTap: () {
          Share.share(chatItem.images!.first);
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
              ref.read(chatProvider(chatItem.parentID ?? 0).notifier).remove(chatItem);
            },
          );
        });
      },
    ),
  ];
}

class BotImageMessage extends ConsumerWidget {
  final ChatItem chatItem;

  const BotImageMessage({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chatItem.moduleType ?? "",
                style: TextStyle(fontSize: 14, color: Theme.of(context).primaryColor),
              ),
              Text(
                "  ${chatItem.time.toYMDHM()}",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          PullDownButton(
            scrollController: ScrollController(),
            itemBuilder: (context) => getImageMessageActions2(context, ref, chatItem, null, null),
            buttonBuilder: (context, showMenu) => GestureDetector(
              onLongPress: () {
                showMenu();
              },
              onTap: () {
                //隐藏键盘
                FocusScope.of(context).unfocus();
                F.pushTransparent(SlidePage(
                  url: chatItem.images?.first ?? "",
                ));
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                  minWidth: 10,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                  ),
                ),
                child: getMessage(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getMessage(BuildContext context) {
    if (chatItem.status == MessageStatus.loading.index) {
      return Container(
        width: MediaQuery.of(context).size.width * 0.2,
        alignment: Alignment.center,
        child: SizedBox(
          width: 40,
          child: LoadingAnimationWidget.prograssiveDots(
            color: Theme.of(context).primaryColor,
            size: 40,
          ),
        ),
      );
    } else if (chatItem.status == MessageStatus.success.index && (chatItem.images?.isNotEmpty ?? false)) {
      return Hero(
        tag: chatItem.images?.first ?? "",
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: ExtendedImage.network(
            chatItem.images?.first ?? "",
            width: MediaQuery.of(context).size.width * 0.7,
            height: MediaQuery.of(context).size.width * 0.7,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (chatItem.status == MessageStatus.failed.index) {
      return ChatMarkDown(
        content: chatItem.content ?? "",
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Text(
          "canceled by user",
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
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Text(
          chatItem.content ?? "",
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}

final openAIImageSizeProvider = StateProvider<OpenAIImageSize>((ref) {
  return OpenAIImageSize.size1024;
});

final openAIImageStyleProvider = StateProvider<OpenAIImageStyle>((ref) {
  return OpenAIImageStyle.natural;
});
