import 'dart:convert';

import 'package:ChatBot/base.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../db/chat_item.dart';
import 'chat_markdown.dart';

class ScreenShootUserMessage extends StatelessWidget {
  final ChatItem chatItem;

  const ScreenShootUserMessage({super.key, required this.chatItem});

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

class ScreenShootBotMessage extends ConsumerWidget {
  final ChatItem chatItem;

  const ScreenShootBotMessage({super.key, required this.chatItem});

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

class ScreenShootAssistMessage extends StatelessWidget {
  final ChatItem chatItem;

  const ScreenShootAssistMessage({super.key, required this.chatItem});

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
