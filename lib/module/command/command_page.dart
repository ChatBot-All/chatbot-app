import 'dart:convert';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/db/chat_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../base/components/common_dialog.dart';
import '../../hive_bean/local_chat_history.dart';
import '../../hive_bean/openai_bean.dart';
import '../../utils/hive_box.dart';
import '../chat/chat_detail/chat_page.dart';
import '../chat/chat_list_view_model.dart';

class CommandPage extends ConsumerStatefulWidget {
  const CommandPage({super.key});

  @override
  ConsumerState createState() => _CommandPageState();
}

class _CommandPageState extends ConsumerState<CommandPage> {
  List<CommandBean> list = [];

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("工坊"),
      ),
      body: ListView.separated(
          padding:  EdgeInsets.only(top: 15, bottom: MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight),
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  title: Text(
                    list[index].title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      list[index].content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                    ),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15))),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.35,
                          minHeight: 100,
                        ),
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 30,
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          list[index].title,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          list[index].content,
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                fontSize: 13,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                SafeArea(
                                  bottom: true,
                                  top: false,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CupertinoButton(
                                          minSize: 10,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          color: Theme.of(context).canvasColor,
                                          borderRadius: BorderRadius.circular(5),
                                          child: const Text(
                                            "取消",
                                            style:
                                                TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        const SizedBox(
                                          width: 15,
                                        ),
                                        CupertinoButton(
                                          minSize: 10,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          color: Theme.of(context).primaryColor,
                                          borderRadius: BorderRadius.circular(5),
                                          child: const Text(
                                            "使用",
                                            style: TextStyle(
                                                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          onPressed: () {
                                            if (!isExistModels()) {
                                              showCommonDialog(
                                                context,
                                                title: '温馨提示',
                                                content: "请先进入设置并配置服务商",
                                                hideCancelBtn: true,
                                                autoPop: true,
                                                confirmText: "知道了",
                                                confirmCallback: () {},
                                              );
                                              return;
                                            }

                                            ChatParentItem item = ChatParentItem(
                                                apiKey: getDefaultApiKey(),
                                                id: DateTime.now().millisecondsSinceEpoch,
                                                moduleName: getModelByApiKey("").model,
                                                historyMessageCount: 10,
                                                temperature: "0.6",
                                                moduleType: getSupportedModelByApiKey(""),
                                                title: list[index].title);

                                            ChatItemProvider().insert(ChatItem(
                                                content: list[index].content,
                                                time: DateTime.now().millisecondsSinceEpoch,
                                                type: ChatType.system.index,
                                                parentID: item.id,
                                                status: MessageStatus.success.index,
                                                moduleName: item.moduleName,
                                                moduleType: item.moduleType));

                                            F.pop();
                                            F.push(ChatPage(localChatHistory: item)).then((value) {
                                              ref.read(chatParentListProvider.notifier).load();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                  },
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 15);
          },
          itemCount: list.length),
    );
  }

  void initData() async {
    //解析assets文件夹中的command.json文件
    //将解析的数据赋值给list
    String data = await rootBundle.loadString("assets/command.json");
    var mapData = json.decode(data);
    list = (mapData as List).map((e) => CommandBean.fromJson(e)).toList();
    setState(() {});
  }
}

class CommandBean {
  final String title;
  final String content;

  const CommandBean({required this.title, required this.content});

  static CommandBean fromJson(Map<String, dynamic> json) {
    return CommandBean(title: json["title"] ?? "", content: json["content"] ?? "");
  }
}
