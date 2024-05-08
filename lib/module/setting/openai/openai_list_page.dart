import 'package:ChatBot/base/components/common_dialog.dart';
import 'package:ChatBot/hive_bean/local_chat_history.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/module/setting/gemini/gemini_add_page.dart';
import 'package:ChatBot/module/setting/ollama/ollama_add_page.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../base.dart';
import '../../../base/components/common_loading.dart';
import '../../../base/components/multi_state_widget.dart';
import '../../../base/theme.dart';
import 'openai_add_page.dart';
import 'openai_viewmodel.dart';

class OpenAIListPage extends ConsumerStatefulWidget {
  final APIType apiType;

  const OpenAIListPage({super.key, required this.apiType});

  @override
  ConsumerState createState() => _OpenAIListPageState();
}

class _OpenAIListPageState extends ConsumerState<OpenAIListPage> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      //判断是不是上下滚动
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(getTitle(widget.apiType)),
        actions: [
          //添加按钮
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Icon(
              CupertinoIcons.add_circled,
              color: Theme.of(context).appBarTheme.actionsIconTheme?.color,
              size: 22,
            ),
          ).click(() {
            if (widget.apiType == APIType.openAI) {
              F.push(const OpenAIAddPage());
            } else if (widget.apiType == APIType.gemini) {
              F.push(const GeminiAddPage());
            } else {
              F.push(const OllamaAddPage());
            }
          }),
        ],
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final chatHistory = ref.watch(openAiListProvider(widget.apiType));
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              await ref.read(openAiListProvider(widget.apiType).notifier).load();
            },
            child: MultiStateWidget<List<AllModelBean>>(
              value: chatHistory,
              data: (data) {
                //以时间排序
                data.sort((a, b) => b.time!.compareTo(a.time!));
                if (data.isEmpty) {
                  return const EmptyData();
                }
                return ListView.separated(
                  controller: _scrollController,
                  itemCount: data.length,
                  physics: const AlwaysScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return const Padding(padding: EdgeInsets.symmetric(vertical: 5));
                  },
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  itemBuilder: (BuildContext context, int index) {
                    final item = data[index];
                    return OpenAIListItem(
                      item,
                      () {
                        setState(() {});
                      },
                      widget.apiType,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  String getTitle(APIType apiType) {
    if (apiType == APIType.openAI) {
      return S.current.openai_setting;
    } else if (apiType == APIType.gemini) {
      return S.current.gemini_setting;
    } else {
      return S.current.ollama_setting;
    }
  }
}

class OpenAIListItem extends ConsumerWidget {
  final AllModelBean item;
  final VoidCallback onTap;
  final APIType apiType;

  const OpenAIListItem(this.item, this.onTap, this.apiType, {super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Card(
          color: Theme.of(context).cardColor,
          child: Slidable(
            groupTag: item.apiKey,
            endActionPane: ActionPane(
              motion: const BehindMotion(),
              extentRatio: 0.4,
              children: [
                SlidableAction(
                  onPressed: (context) {
                    if (apiType == APIType.openAI) {
                      F.push(OpenAIAddPage(openAi: item));
                    } else if (apiType == APIType.gemini) {
                      F.push(GeminiAddPage(openAi: item));
                    } else {
                      F.push(OllamaAddPage(openAi: item));
                    }
                  },
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  icon: Icons.edit_note,
                ),
                SlidableAction(
                  onPressed: (context) {
                    showCommonDialog(
                      context,
                      confirmCallback: () {
                        ref.watch(openAiListProvider(apiType).notifier).remove(item);
                      },
                      content: S.current.delete_config_reminder,
                      title: S.current.reminder,
                      autoPop: true,
                      hideCancelBtn: false,
                    );
                  },
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: CupertinoIcons.delete,
                ),
              ],
            ),
            child: Container(
              color: Theme.of(context).cardColor,
              key: ValueKey(item.apiKey),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  const SizedBox(width: 15),
                  Consumer(builder: (context, ref, _) {
                    bool officer = (item.apiServer?.endsWith(apiType.host)) == true;
                    return Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        officer ? S.current.official : S.current.third_party,
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontSize: officer ? 14 : 12,
                        ),
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
                                      item.alias ?? (item.apiKey ?? ''),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  if (item.apiKey == getDefaultApiKey())
                                    const SizedBox(
                                      width: 10,
                                    ),
                                  Consumer(builder: (context, ref, _) {
                                    if (item.apiKey != getDefaultApiKey()) {
                                      return const SizedBox.shrink();
                                    }
                                    return Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 0,
                                      ),
                                      child: Text(
                                        S.current.default1,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 10,
                                        ),
                                      ),
                                    );
                                  }),
                                  Builder(builder: (context) {
                                    return PullDownButton(
                                      scrollController: ScrollController(),
                                      itemBuilder: (context) {
                                        return item.getTextModels
                                            .where((element) => element.id != null && element.id!.isNotEmpty)
                                            .map((e) {
                                          return PullDownMenuItem(
                                            title: e.id?.replaceFirst("models/", "") ?? "",
                                            icon: e.id == (item.defaultModelType?.id ?? item.supportedModels?.first.id)
                                                ? CupertinoIcons.checkmark
                                                : null,
                                            iconColor: Theme.of(context).primaryColor,
                                            onTap: () {
                                              ref.watch(openAiListProvider(apiType).notifier).update(item.copyWith(
                                                    defaultModelType: e,
                                                  ));
                                            },
                                          );
                                        }).toList();
                                      },
                                      buttonBuilder: (context, showMenu) => Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Theme.of(context).primaryColor),
                                          borderRadius: BorderRadius.circular(3),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        child: Text(
                                          (item.defaultModelType?.id ?? item.supportedModels?.first.id ?? "")
                                              .replaceFirst("models/", ""),
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ).click(() {
                                        showMenu();
                                      }),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              item.time?.toYMDHM() ?? '',
                              style: TextStyle(
                                color: ref.watch(themeProvider).timeColor(),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 15),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.apiServer ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
                        ),
                        getSupportedFunctions(context),
                      ],
                    ),
                  ),
                ],
              ),
            ).click(() {
              HiveBox().appConfig.put(HiveBox.cDefaultApiServerKey, item.apiKey ?? "");
              onTap();
            }),
          ),
        ),
      ),
    );
  }

  Widget getSupportedFunctions(BuildContext context) {
    List<String> functions = [];
    if (item.getTTSModels.isNotEmpty) {
      functions.add(S.current.canVoice);
    }
    if (item.getWhisperModels.isNotEmpty) {
      functions.add(S.current.canTalk);
    }
    if (item.getDallModels.isNotEmpty) {
      functions.add(S.current.canPaint);
    }

    List<Widget> result = functions
        .map((e) => Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(3),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 0,
              ),
              child: Text(
                e,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 10,
                ),
              ),
            ))
        .toList();

    if (result.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 5),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: result,
      ),
    );
  }
}
