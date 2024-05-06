import 'dart:convert';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:extended_image/extended_image.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../db/chat_item.dart';
import '../theme.dart';
import 'chat_markdown.dart';

class ScreenShotChatPage extends ConsumerWidget {
  final List<ChatItem> list;
  final BuildContext rootContext;
  final ChatParentItem result;

  const ScreenShotChatPage({
    super.key,
    required this.list,
    required this.rootContext,
    required this.result,
  });

  @override
  Widget build(BuildContext context, ref) {
    return Material(
      clipBehavior: Clip.antiAlias,
      child: Builder(builder: (context) {
        var items = list.map((e) {
          if (e.type == ChatType.user.index) {
            return ScreenShotUserMessage(
              chatItem: e,
            );
          } else if (e.type == ChatType.bot.index) {
            return ScreenShotBotMessage(
              chatItem: e,
            );
          } else {
            return ScreenShotAssistMessage(chatItem: e);
          }
        }).toList();

        return MediaQuery(
          data: MediaQuery.of(rootContext),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: kToolbarHeight,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: F.width * 0.8,
                      ),
                      child: Text(
                        result.title ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                    ),
                  ),
                  ...items,
                  Container(
                    width: F.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: ref.watch(themeProvider).xffF6F6F6(),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/images/logo.jpg",
                            width: 50,
                            height: 50,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Made by CChatBot",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              DateUtil.formatDateMs(DateTime.now().millisecondsSinceEpoch,
                                  format: DateFormats.y_mo_d_h_m),
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}




class ScreenShotChatImagePage extends ConsumerWidget {
  final List<ChatItem> list;
  final BuildContext rootContext;
  final ChatParentItem result;

  const ScreenShotChatImagePage({
    super.key,
    required this.list,
    required this.rootContext,
    required this.result,
  });

  @override
  Widget build(BuildContext context, ref) {
    return Material(
      child: Builder(builder: (context) {
        var items = list.map((e) {
          if (e.type == ChatType.user.index) {
            return ScreenShotUserMessage(
              chatItem: e,
            );
          } else if (e.type == ChatType.bot.index) {
            return ScreenShotBotImageMessage(
              chatItem: e,
            );
          } else {
            return ScreenShotAssistMessage(chatItem: e);
          }
        }).toList();

        return MediaQuery(
          data: MediaQuery.of(rootContext).copyWith(size: Size(F.width, F.height)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: kToolbarHeight,
                    color: Theme.of(context).appBarTheme.backgroundColor,
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: F.width * 0.8,
                      ),
                      child: Text(
                        result.title ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).appBarTheme.titleTextStyle,
                      ),
                    ),
                  ),
                  ...items,
                  Container(
                    width: F.width,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: ref.watch(themeProvider).xffF6F6F6(),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            "assets/images/logo.jpg",
                            width: 50,
                            height: 50,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Made by CChatBot",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              DateUtil.formatDateMs(DateTime.now().millisecondsSinceEpoch,
                                  format: DateFormats.y_mo_d_h_m),
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class ScreenShotUserMessage extends StatelessWidget {
  final ChatItem chatItem;

  const ScreenShotUserMessage({super.key, required this.chatItem});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        color: Colors.transparent,
        margin: const EdgeInsets.only(right: 15, top: 10, bottom: 10),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: F.width * 0.8,
            minWidth: 10,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
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
                  (chatItem.images!.where((element) => element.isEmpty).length != chatItem.images!.length))
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    runAlignment: WrapAlignment.end,
                    direction: Axis.horizontal,
                    children: [
                      ...chatItem.images!.where((element) => element.isNotEmpty).map((e) {
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
                  (chatItem.images!.where((element) => element.isEmpty).length != chatItem.images!.length))
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
    );
  }
}

class ScreenShotBotMessage extends ConsumerWidget {
  final ChatItem chatItem;

  const ScreenShotBotMessage({super.key, required this.chatItem});

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
            style: TextStyle(fontSize: 13, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 5),
          Container(
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
            child: getMessage(context),
          ),
        ],
      ),
    );
  }

  Widget getMessage(BuildContext context) {
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

class ScreenShotAssistMessage extends StatelessWidget {
  final ChatItem chatItem;

  const ScreenShotAssistMessage({super.key, required this.chatItem});

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

class ScreenShotBotImageMessage extends ConsumerWidget {
  final ChatItem chatItem;

  const ScreenShotBotImageMessage({super.key, required this.chatItem});

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
          Container(
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
          )
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
