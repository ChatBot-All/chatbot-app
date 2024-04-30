import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/components/components.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../../../base/components/common_text_field.dart';
import '../../../hive_bean/supported_models.dart';
import '../../setting/setting_page.dart';
import 'chat_setting_viewmodel.dart';
import 'chat_viewmodel.dart';

class ChatSettingPage extends ConsumerStatefulWidget {
  const ChatSettingPage({super.key});

  @override
  ConsumerState createState() => _ChatSettingPageState();
}

class _ChatSettingPageState extends ConsumerState<ChatSettingPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController countController = TextEditingController();

  final FocusNode focusNode = FocusNode();
  final FocusNode countFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        var current = ref.watch(currentChatParentItemProvider.notifier).state;
        if ((current?.title ?? "") != nameController.text) {
          ref.watch(currentChatParentItemProvider.notifier).state =
              current?.copyWith(title: nameController.text);
        }
      }
    });
    countFocusNode.addListener(() {
      if (!countFocusNode.hasFocus) {
        var current = ref.watch(currentChatParentItemProvider.notifier).state;
        int count = current?.historyMessageCount ?? 4;
        if (count != int.parse(countController.text)) {
          ref.watch(currentChatParentItemProvider.notifier).state = current
              ?.copyWith(historyMessageCount: int.parse(countController.text));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Consumer(builder: (context, ref, _) {
        var currentLocalChatHistory = ref.watch(currentChatParentItemProvider);

        nameController.text = currentLocalChatHistory?.title ?? "";
        countController.text =
            (currentLocalChatHistory?.historyMessageCount ?? 4).toString();
        return Scaffold(
          appBar: AppBar(
            title: Text(S.current.chat_setting),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  SettingWithTitle(
                    label: S.current.name,
                    widget: IgnorePointer(
                      ignoring: currentLocalChatHistory?.id ==
                          specialGenerateTextChatParentItemTime,
                      child: CommonTextField(
                        focusNode: focusNode,
                        color: Theme.of(context).canvasColor,
                        controller: nameController,
                        hintText: S.current.input_name,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.current.tempture,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            PullDownButton(
                              scrollController: ScrollController(),
                              buttonBuilder: (_, showMenu) => Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentLocalChatHistory?.temperature ??
                                        HiveBox().temperature,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(width: 5),
                                  Icon(
                                    CupertinoIcons.chevron_up_chevron_down,
                                    color: Theme.of(context)
                                        .appBarTheme
                                        .titleTextStyle
                                        ?.color,
                                    size: 16,
                                  ),
                                ],
                              ).click(() {
                                showMenu();
                              }),
                              itemBuilder: (BuildContext context) {
                                return List.generate(21,
                                        (index) => ((index) / 10).toString())
                                    .map(
                                      (e) => PullDownMenuItem(
                                        onTap: () {
                                          ref
                                                  .watch(
                                                      currentChatParentItemProvider
                                                          .notifier)
                                                  .state =
                                              currentLocalChatHistory?.copyWith(
                                                  temperature: e.toString());
                                        },
                                        title: e,
                                        iconColor:
                                            Theme.of(context).primaryColor,
                                        icon: e !=
                                                (currentLocalChatHistory
                                                        ?.temperature ??
                                                    HiveBox().temperature)
                                            ? null
                                            : CupertinoIcons.checkmark_alt,
                                      ),
                                    )
                                    .toList();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 16, top: 3, bottom: 3),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.current.servers,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Consumer(builder: (context, ref, _) {
                              final modelList = ref.watch(allModelListProvider);
                              return MultiStateWidget<List<AllModelBean>>(
                                value: modelList,
                                data: (data) => PullDownButton(
                                  buttonBuilder: (_, showMenu) => Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        getModelByApiKey(currentLocalChatHistory
                                                        ?.apiKey ??
                                                    "")
                                                .alias ??
                                            "",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(width: 5),
                                      Icon(
                                        CupertinoIcons.chevron_up_chevron_down,
                                        color: Theme.of(context)
                                            .appBarTheme
                                            .titleTextStyle
                                            ?.color,
                                        size: 16,
                                      ),
                                    ],
                                  ).click(() {
                                    showMenu();
                                  }),
                                  scrollController: ScrollController(),
                                  itemBuilder: (BuildContext context) {
                                    return data
                                        .map(
                                          (e) => PullDownMenuItem(
                                            onTap: () {
                                              ref
                                                      .watch(
                                                          currentChatParentItemProvider
                                                              .notifier)
                                                      .state =
                                                  currentLocalChatHistory?.copyWith(
                                                      apiKey: e.apiKey,
                                                      moduleType: (e.supportedModels ==
                                                                  null ||
                                                              e.supportedModels!
                                                                  .isEmpty)
                                                          ? "gpt-4"
                                                          : (e.supportedModels
                                                                  ?.first.id ??
                                                              "gpt-4"),
                                                      moduleName: e.model ?? 1);
                                            },
                                            title: e.alias ?? "",
                                            iconColor:
                                                Theme.of(context).primaryColor,
                                            icon: e.apiKey !=
                                                    currentLocalChatHistory
                                                        ?.apiKey
                                                ? null
                                                : CupertinoIcons.checkmark_alt,
                                          ),
                                        )
                                        .toList();
                                  },
                                ),
                              );
                            }),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.current.models,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Builder(builder: (context) {
                              final supportedModels = getModelByApiKey(
                                      currentLocalChatHistory?.apiKey ?? "")
                                  .getTextModels;

                              final model =
                                  currentLocalChatHistory?.moduleType ??
                                      supportedModels.first.id ??
                                      "";

                              if (supportedModels
                                  .where((element) => element.id == model)
                                  .isEmpty) {
                                supportedModels.add(
                                    SupportedModels(id: model, ownedBy: ""));
                              }
                              return PullDownButton(
                                scrollController: ScrollController(),
                                buttonBuilder: (_, showMenu) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      currentLocalChatHistory?.moduleType ??
                                          supportedModels.first.id ??
                                          '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(width: 5),
                                    Icon(
                                      CupertinoIcons.chevron_up_chevron_down,
                                      color: Theme.of(context)
                                          .appBarTheme
                                          .titleTextStyle
                                          ?.color,
                                      size: 16,
                                    ),
                                  ],
                                ).click(() {
                                  showMenu();
                                }),
                                itemBuilder: (BuildContext context) {
                                  return supportedModels
                                      .map(
                                        (e) => PullDownMenuItem(
                                          onTap: () {
                                            ref
                                                    .watch(
                                                        currentChatParentItemProvider
                                                            .notifier)
                                                    .state =
                                                currentLocalChatHistory
                                                    ?.copyWith(
                                                        moduleType: e.id);
                                          },
                                          title: e.id?.replaceFirst(
                                                  "models/", "") ??
                                              "",
                                          iconColor:
                                              Theme.of(context).primaryColor,
                                          icon: e.id !=
                                                  currentLocalChatHistory
                                                      ?.moduleType
                                              ? null
                                              : CupertinoIcons.checkmark_alt,
                                        ),
                                      )
                                      .toList();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
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
