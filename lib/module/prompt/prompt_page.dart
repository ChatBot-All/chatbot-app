import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/components/common_loading.dart';
import 'package:ChatBot/base/components/components.dart';
import 'package:ChatBot/base/db/chat_item.dart';
import 'package:ChatBot/base/db/prompt_item.dart';
import 'package:ChatBot/base/theme.dart';
import 'package:ChatBot/module/prompt/prompt_add_page.dart';
import 'package:ChatBot/module/prompt/prompt_viewmodel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../hive_bean/local_chat_history.dart';
import '../../hive_bean/openai_bean.dart';
import '../chat/chat_detail/chat_page.dart';
import '../chat/chat_list_view_model.dart';

class PromptPage extends ConsumerStatefulWidget {
  const PromptPage({super.key});

  @override
  ConsumerState createState() => _CommandPageState();
}

class _CommandPageState extends ConsumerState<PromptPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.library),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              CupertinoIcons.add_circled,
              color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
              size: 22,
            ),
          ).click(() {
            F.push(const PromptAddPage()).then((value) {});
          }),
        ],
      ),
      body: Consumer(builder: (context, ref, _) {
        return MultiStateWidget<List<PromptItem>>(
            value: ref.watch(promptListProvider),
            data: (data) {
              if (data.isEmpty) {
                return const EmptyData();
              }
              return ListView.separated(
                  padding: EdgeInsets.only(
                      top: 15, bottom: MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Slidable(
                          enabled: data[index].time != 0,
                          endActionPane: ActionPane(
                            motion: const BehindMotion(),
                            extentRatio: 0.2,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  ref.watch(promptListProvider.notifier).removePrompt(data[index]);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: CupertinoIcons.delete,
                              ),
                            ],
                          ),
                          child: Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              title: Text(
                                data[index].title ?? "",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: Text(
                                  data[index].prompt ?? "",
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
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(15), topRight: Radius.circular(15))),
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
                                                      data[index].title ?? "",
                                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Text(
                                                      data[index].prompt ?? "",
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
                                                      child: Text(
                                                        S.current.cancel,
                                                        style: const TextStyle(
                                                            color: Colors.red,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold),
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
                                                      child: Text(
                                                        S.current.send,
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold),
                                                      ),
                                                      onPressed: () {
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

                                                        ChatParentItem item = ChatParentItem(
                                                            apiKey: getDefaultApiKey(),
                                                            id: DateTime.now().millisecondsSinceEpoch,
                                                            moduleName: getModelByApiKey("").model,
                                                            historyMessageCount: 10,
                                                            temperature: "0.6",
                                                            moduleType: getSupportedModelByApiKey(""),
                                                            title: data[index].title);

                                                        ChatItemProvider().insert(ChatItem(
                                                            content: data[index].prompt ?? "",
                                                            time: DateTime.now().millisecondsSinceEpoch,
                                                            type: ChatType.system.index,
                                                            parentID: item.id,
                                                            status: MessageStatus.success.index,
                                                            moduleName: item.moduleName,
                                                            moduleType: item.moduleType));

                                                        F.pop();
                                                        F.push(ChatPage(localChatHistory: item,showKeyboard: true,)).then((value) {
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
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 15);
                  },
                  itemCount: data.length);
            });
      }),
    );
  }
}
