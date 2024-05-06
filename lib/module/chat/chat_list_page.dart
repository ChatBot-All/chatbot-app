import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/components/common_dialog.dart';
import 'package:ChatBot/base/theme.dart';
import 'package:ChatBot/module/chat/chat_audio/chat_audio_page.dart';
import 'package:ChatBot/module/chat/chat_image/chat_image_page.dart';
import 'package:ChatBot/module/chat/chat_translate/chat_translate_page.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../base/components/common_loading.dart';
import '../../base/components/multi_state_widget.dart';
import '../../base/db/chat_item.dart';
import '../../hive_bean/local_chat_history.dart';
import '../../hive_bean/openai_bean.dart';
import 'chat_detail/chat_page.dart';
import 'chat_list_view_model.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatListPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.home_chat),
        actions: [
          //添加按钮
          PullDownButton(
            scrollController: ScrollController(),
            buttonBuilder: (context, showMenu) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!isExistModels()) {
                    showCommonDialog(
                      context,
                      title: S.current.reminder,
                      content: S.current.enter_setting_init_server,
                      hideCancelBtn: true,
                      autoPop: true,
                      confirmText: S.current.yes_know,
                      confirmCallback: () {},
                    );
                    return;
                  }
                  F
                      .push(ChatPage(
                          showKeyboard: true,
                          localChatHistory: ChatParentItem(
                            apiKey: getDefaultApiKey(),
                            id: DateTime.now().millisecondsSinceEpoch,
                            moduleName: getModelByApiKey("").model,
                            moduleType: getSupportedModelByApiKey(""),
                            temperature: HiveBox().temperature,
                            title: S.current.new_chat,
                          )))
                      .then((value) {
                    ref.read(chatParentListProvider.notifier).load();
                  });
                },
                onLongPress: () {
                  if (!isExistModels()) {
                    showCommonDialog(
                      context,
                      title: S.current.reminder,
                      content: S.current.enter_setting_init_server,
                      hideCancelBtn: true,
                      autoPop: true,
                      confirmText: S.current.yes_know,
                      confirmCallback: () {},
                    );
                    return;
                  }
                  showMenu();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Icon(
                    CupertinoIcons.add_circled,
                    color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
                    size: 22,
                  ),
                ),
              );
            },
            itemBuilder: (context) {
              return [
                PullDownMenuTitle(
                  title: Padding(
                    padding: const EdgeInsets.only(bottom: 5, top: 5),
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
                          onTap: () {
                            F
                                .push(ChatPage(
                                    showKeyboard: true,
                                    localChatHistory: ChatParentItem(
                                      apiKey: e.apiKey ?? "",
                                      id: DateTime.now().millisecondsSinceEpoch,
                                      moduleName: e.model,
                                      moduleType: e.defaultModelType?.id ?? "gpt-4",
                                      title: S.current.new_chat,
                                    )))
                                .then((value) {
                              ref.read(chatParentListProvider.notifier).load();
                            });
                          },
                        ))
                    .toList(),
              ];
            },
          ),
        ],
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final chatHistory = ref.watch(chatParentListProvider);
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              await ref.read(chatParentListProvider.notifier).load();
            },
            child: MultiStateWidget<List<ChatParentItem>>(
              value: chatHistory,
              data: (data) {
                //排序如下：
                // 1.优先置顶，按照置顶里的时间排序，\
                data.sort((a, b) {
                  if (a.chatItem != null && b.chatItem != null) {
                    return b.chatItem!.time!.compareTo(a.chatItem!.time!);
                  } else {
                    return b.id!.compareTo(a.id!);
                  }
                });
                data.sort((a, b) => (b.pin ?? false ? 1 : 0).compareTo(a.pin ?? false ? 1 : 0));

                // 然后如果ChatItem不为空，那就以ChatItem的time排序，否则就以data的time排序

                return ListView.builder(
                  padding: EdgeInsets.only(
                      top: 0, bottom: MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight),
                  itemCount: data.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) {
                      return Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const ChatSpecialTextListItem(),
                          const ChatImageListItem(),
                          const ChatTranslateListItem(),
                          if (data.isEmpty)
                            SizedBox(
                                height: F.height -
                                    kBottomNavigationBarHeight -
                                    MediaQuery.paddingOf(context).bottom -
                                    kToolbarHeight -
                                    MediaQuery.paddingOf(context).top -
                                    50 -
                                    50 -
                                    20 -
                                    20 -
                                    20,
                                child: const EmptyData()),
                        ],
                      );
                    }

                    final item = data[index - 1];
                    return ChatListItem(item);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatTranslateListItem extends ConsumerWidget {
  const ChatTranslateListItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      color: ref.watch(themeProvider).pinedBgColor(),
      child: Column(
        children: [
          Container(
            color: ref.watch(themeProvider).pinedBgColor(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Consumer(builder: (context, ref, _) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.translate,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  );
                }),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    S.current.translate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ).click(() {
            if (!isExistModels()) {
              showCommonDialog(
                context,
                title: S.current.reminder,
                content: S.current.enter_setting_init_server,
                hideCancelBtn: true,
                autoPop: true,
                confirmText: S.current.yes_know,
                confirmCallback: () {},
              );
              return;
            }

            F.push(const ChatTranslatePage()).then((value) {
              ChatItemProvider().deleteAll(specialGenerateTranslateChatParentItemTime);
            });
          }),
          const Divider(
            indent: 80,
          ),
        ],
      ),
    );
  }
}

class ChatImageListItem extends ConsumerWidget {
  const ChatImageListItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      color: ref.watch(themeProvider).pinedBgColor(),
      child: Column(
        children: [
          Container(
            color: ref.watch(themeProvider).pinedBgColor(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Consumer(builder: (context, ref, _) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      CupertinoIcons.photo,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  );
                }),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    S.current.generate_image,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ).click(() {
            if (!isExistModels()) {
              showCommonDialog(
                context,
                title: S.current.reminder,
                content: S.current.enter_setting_init_server,
                hideCancelBtn: true,
                autoPop: true,
                confirmText: S.current.yes_know,
                confirmCallback: () {},
              );
              return;
            }
            if (!isExistDallE3Models()) {
              showCommonDialog(
                context,
                title: S.current.reminder,
                content: S.current.only_support_dalle3,
                hideCancelBtn: true,
                autoPop: true,
                confirmText: S.current.yes_know,
                confirmCallback: () {},
              );
              return;
            }
            F.push(const ChatImagePage());
          }),
          const Divider(
            indent: 80,
          ),
        ],
      ),
    );
  }
}

class ChatAudioChatListItem extends ConsumerWidget {
  const ChatAudioChatListItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      color: ref.watch(themeProvider).pinedBgColor(),
      child: Column(
        children: [
          Container(
            color: ref.watch(themeProvider).pinedBgColor(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Consumer(builder: (context, ref, _) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      CupertinoIcons.waveform_path,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  );
                }),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    S.current.voiceChat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ).click(() {
            if (!isExistModels()) {
              showCommonDialog(
                context,
                title: S.current.reminder,
                content: S.current.enter_setting_init_server,
                hideCancelBtn: true,
                autoPop: true,
                confirmText: S.current.yes_know,
                confirmCallback: () {},
              );
              return;
            }
            if (!isExistTTSAndWhisperModels()) {
              showCommonDialog(
                context,
                title: S.current.reminder,
                content: S.current.not_support_tts,
                hideCancelBtn: true,
                autoPop: true,
                confirmText: S.current.yes_know,
                confirmCallback: () {},
              );
              return;
            }
            F.push(const ChatAudioPage()).then((value) {
              ChatItemProvider().deleteAll(specialGenerateAudioChatParentItemTime);
            });
          }),
          const Divider(
            indent: 80,
          ),
        ],
      ),
    );
  }
}

class ChatSpecialTextListItem extends ConsumerWidget {
  const ChatSpecialTextListItem({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      color: ref.watch(themeProvider).pinedBgColor(),
      child: Column(
        children: [
          Container(
            color: ref.watch(themeProvider).pinedBgColor(),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                const SizedBox(width: 15),
                Consumer(builder: (context, ref, _) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      CupertinoIcons.chat_bubble,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                  );
                }),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    S.current.new_chat,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ],
            ),
          ).click(() {
            if (!isExistModels()) {
              showCommonDialog(
                context,
                title: S.current.reminder,
                content: S.current.enter_setting_init_server,
                hideCancelBtn: true,
                autoPop: true,
                confirmText: S.current.yes_know,
                confirmCallback: () {},
              );
              return;
            }

            var chatItem =
                HiveBox().chatHistory.get(specialGenerateTextChatParentItemTime.toString(), defaultValue: null);
            if (chatItem == null) {
              chatItem = ChatParentItem(
                apiKey: getDefaultApiKey(),
                id: specialGenerateTextChatParentItemTime,
                moduleName: getModelByApiKey("").model,
                moduleType: getSupportedModelByApiKey(""),
                title: S.current.new_chat,
              );
              HiveBox().chatHistory.put(specialGenerateTextChatParentItemTime.toString(), chatItem);
            }
            F.push(ChatPage(localChatHistory: chatItem));
          }),
          const Divider(
            indent: 80,
          ),
        ],
      ),
    );
  }
}

class ChatListItem extends ConsumerWidget {
  final ChatParentItem item;

  const ChatListItem(this.item, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      color: (item.pin ?? false) ? ref.watch(themeProvider).pinedBgColor() : ref.watch(themeProvider).unPinedBgColor(),
      child: Column(
        children: [
          Slidable(
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              extentRatio: 0.4,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    ref.watch(chatParentListProvider.notifier).pin(item);
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  icon: (item.pin ?? false) ? CupertinoIcons.pin_slash : CupertinoIcons.pin,
                ),
                SlidableAction(
                  onPressed: (context) {
                    ref.watch(chatParentListProvider.notifier).remove(item);
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.delete,
                ),
              ],
            ),
            child: Container(
              color: (item.pin ?? false)
                  ? ref.watch(themeProvider).pinedBgColor()
                  : ref.watch(themeProvider).unPinedBgColor(),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Consumer(builder: (context, ref, _) {
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: (item.pin ?? false)
                            ? Theme.of(context).cardColor
                            : Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        CupertinoIcons.chat_bubble,
                        color: Theme.of(context).primaryColor,
                        size: 24,
                      ),
                    );
                  }),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      item.title ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 10, right: 15),
                                    padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(color: Theme.of(context).primaryColor, width: 1),
                                    ),
                                    child: Text(
                                      APIType.fromCode(item.moduleName ?? 1).name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Theme.of(context).primaryColor, fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              item.chatItem == null ? (item.id?.toYMDHM() ?? "") : item.chatItem!.time?.toYMDHM() ?? "",
                              style: TextStyle(
                                color: ref.watch(themeProvider).timeColor(),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 15),
                          ],
                        ),
                        if (item.chatItem != null &&
                            item.chatItem!.content != null &&
                            item.chatItem!.content!.isNotEmpty)
                          const SizedBox(height: 5),
                        if (item.chatItem != null &&
                            item.chatItem!.content != null &&
                            item.chatItem!.content!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Text(
                              item.chatItem == null ? "" : item.chatItem!.content?.toString() ?? "",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ).click(() {
              //检查apiKey是否还在，如果不在就修改
              if (!isExistModels()) {
                showCommonDialog(
                  context,
                  title: S.current.reminder,
                  content: S.current.enter_setting_init_server,
                  hideCancelBtn: true,
                  autoPop: true,
                  confirmText: S.current.yes_know,
                  confirmCallback: () {},
                );
                return;
              }
              var model = getModelByApiKey(item.apiKey ?? "");

              var result = item.copyWith(
                moduleType: getSupportedModelByApiKey(model.apiKey ?? "", preModelType: item.moduleType),
                moduleName: model.model,
                apiKey: model.apiKey,
              );

              ref.watch(chatParentListProvider.notifier).update(result);

              F.push(ChatPage(localChatHistory: result)).then((value) {
                ref.read(chatParentListProvider.notifier).load();
              });
            }),
          ),
          const Divider(
            indent: 80,
          ),
        ],
      ),
    );
  }
}
