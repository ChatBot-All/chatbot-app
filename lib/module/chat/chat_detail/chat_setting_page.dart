import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/components/components.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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
          ref.watch(currentChatParentItemProvider.notifier).state = current?.copyWith(title: nameController.text);
        }
      }
    });
    countFocusNode.addListener(() {
      if (!countFocusNode.hasFocus) {
        var current = ref.watch(currentChatParentItemProvider.notifier).state;
        int count = current?.historyMessageCount ?? 4;
        if (count != int.parse(countController.text)) {
          ref.watch(currentChatParentItemProvider.notifier).state =
              current?.copyWith(historyMessageCount: int.parse(countController.text));
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
        countController.text = (currentLocalChatHistory?.historyMessageCount ?? 4).toString();
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
                      ignoring: currentLocalChatHistory?.id == specialGenerateTextChatParentItemTime,
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
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.current.tempture,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isDense: true,
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    CupertinoIcons.chevron_down,
                                    color: Theme.of(context).textTheme.titleSmall?.color,
                                    size: 16,
                                  ),
                                ),
                                hint: Text(
                                  S.current.select,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                items: List.generate(21, (index) => ((index) / 10).toString())
                                    .map((item) => DropdownMenuItem<String>(
                                          alignment: Alignment.center,
                                          value: item,
                                          child: Text(
                                            item,
                                            style: TextStyle(
                                              color: Theme.of(context).textTheme.titleSmall?.color,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: currentLocalChatHistory?.temperature ?? HiveBox().temperature,
                                onChanged: (String? e) {
                                  ref.watch(currentChatParentItemProvider.notifier).state =
                                      currentLocalChatHistory?.copyWith(temperature: e.toString());
                                },
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                buttonStyleData: ButtonStyleData(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.transparent,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ),
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
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.current.servers,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Consumer(builder: (context, ref, _) {
                              final modelList = ref.watch(allModelListProvider);
                              return MultiStateWidget<List<AllModelBean>>(
                                value: modelList,
                                data: (data) => DropdownButtonHideUnderline(
                                  child: DropdownButton2<AllModelBean>(
                                    isDense: true,
                                    hint: Text(
                                      S.current.select,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).hintColor,
                                      ),
                                    ),
                                    items: data
                                        .map((item) => DropdownMenuItem<AllModelBean>(
                                              value: item,
                                              child: Text(
                                                item.alias ?? "",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ))
                                        .toList(),
                                    value: getModelByApiKey(currentLocalChatHistory?.apiKey ?? ""),
                                    onChanged: (AllModelBean? e) {
                                      ref.watch(currentChatParentItemProvider.notifier).state =
                                          currentLocalChatHistory?.copyWith(
                                              apiKey: e?.apiKey,
                                              moduleType:
                                                  (e == null || e.supportedModels == null || e.supportedModels!.isEmpty)
                                                      ? "gpt-4"
                                                      : (e.supportedModels?.first.id ?? "gpt-4"),
                                              moduleName: e?.model ?? 1);
                                    },
                                    dropdownStyleData: DropdownStyleData(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    buttonStyleData: ButtonStyleData(
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).canvasColor,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
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
                        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.current.models,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Builder(builder: (context) {
                              final supportedModels =
                                  getModelByApiKey(currentLocalChatHistory?.apiKey ?? "").getTextModels;

                              final model = currentLocalChatHistory?.moduleType ?? supportedModels.first.id ?? "";

                              if (supportedModels.where((element) => element.id == model).isEmpty) {
                                supportedModels.add(SupportedModels(id: model, ownedBy: ""));
                              }
                              return DropdownButtonHideUnderline(
                                child: DropdownButton2<String>(
                                  isDense: true,
                                  hint: Text(
                                    S.current.select,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).hintColor,
                                    ),
                                  ),
                                  dropdownStyleData: DropdownStyleData(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  items: supportedModels
                                      .map((item) => DropdownMenuItem<String>(
                                            value: item.id,
                                            child: Text(
                                              item.id?.replaceFirst("models/", "") ?? "",
                                              style: const TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                  value: currentLocalChatHistory?.moduleType ?? supportedModels.first.id ?? '',
                                  onChanged: (String? e) {
                                    ref.watch(currentChatParentItemProvider.notifier).state =
                                        currentLocalChatHistory?.copyWith(moduleType: e);
                                  },
                                  buttonStyleData: ButtonStyleData(
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).canvasColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(width: 15),
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
