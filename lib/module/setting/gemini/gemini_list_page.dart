import 'dart:math';

import 'package:ChatBot/base/components/common_dialog.dart';
import 'package:ChatBot/base/components/common_loading.dart';
import 'package:ChatBot/base/theme.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:popover/popover.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../base.dart';
import '../../../base/components/multi_state_widget.dart';
import 'gemini_add_page.dart';
import 'gemini_viewmodel.dart';

class GeminiListPage extends ConsumerStatefulWidget {
  const GeminiListPage({super.key});

  @override
  ConsumerState createState() => _GeminiListPageState();
}

class _GeminiListPageState extends ConsumerState<GeminiListPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      //判断是不是上下滚动
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {}
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.gemini_setting),
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
            F.push(const GeminiAddPage()).then((value) {
              ref.watch(geminiListProvider.notifier).load();
            });
          }),
        ],
      ),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final chatHistory = ref.watch(geminiListProvider);
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              await ref.read(geminiListProvider.notifier).load();
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
                    return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 5));
                  },
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  itemBuilder: (BuildContext context, int index) {
                    final item = data[index];
                    return GeminiListItem(item, () {
                      setState(() {});
                    });
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

class GeminiListItem extends ConsumerWidget {
  final AllModelBean item;
  final VoidCallback onTap;

  const GeminiListItem(this.item, this.onTap, {super.key});

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
                    F.push(GeminiAddPage(openAi: item));
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
                        ref.watch(geminiListProvider.notifier).remove(item);
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
                    bool officer = (item.apiServer
                            ?.endsWith("generativelanguage.googleapis.com")) ==
                        true;
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
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
                                            .where((element) =>
                                                element.id != null &&
                                                element.id!.isNotEmpty)
                                            .map((e) {
                                          return PullDownMenuItem(
                                            title: e.id?.replaceFirst(
                                                    "models/", "") ??
                                                "",
                                            icon: e.id ==
                                                    (item.defaultModelType
                                                            ?.id ??
                                                        item.supportedModels
                                                            ?.first.id)
                                                ? CupertinoIcons.checkmark
                                                : null,
                                            iconColor:
                                                Theme.of(context).primaryColor,
                                            onTap: () {
                                              ref
                                                  .watch(geminiListProvider
                                                      .notifier)
                                                  .update(item.copyWith(
                                                    defaultModelType: e,
                                                  ));
                                            },
                                          );
                                        }).toList();
                                      },
                                      buttonBuilder: (_, showMenu) => Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 1,
                                        ),
                                        child: Text(
                                          (item.defaultModelType?.id ??
                                                  item.supportedModels?.first
                                                      .id ??
                                                  "")
                                              .replaceFirst("models/", ""),
                                          style: TextStyle(
                                            color:
                                                Theme.of(context).primaryColor,
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
                        Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: Text(
                            item.apiServer ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).click(() {
              HiveBox()
                  .appConfig
                  .put(HiveBox.cDefaultApiServerKey, item.apiKey ?? "");
              onTap();
            }),
          ),
        ),
      ),
    );
  }
}
