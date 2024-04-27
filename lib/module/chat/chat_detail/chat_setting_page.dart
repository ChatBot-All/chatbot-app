import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/components/components.dart';
import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/module/chat/chat_list_view_model.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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

  var temperatureList = ["0.0", "0.2", "0.4", "0.6", "0.8", "1.0", "1.2", "1.4", "1.6", "1.8", "2.0"];

  final FocusNode focusNode = FocusNode();
  final FocusNode countFocusNode = FocusNode();

  double temperature = 1.0;

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
        temperature = double.parse(current?.temperature ?? "1.0");
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

        temperature = double.parse(currentLocalChatHistory?.temperature ?? "1.0");
        return Scaffold(
          appBar: AppBar(
            title: const Text("聊天设置"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                children: [
                  SettingWithTitle(
                    label: "名称",
                    widget: IgnorePointer(
                      ignoring: currentLocalChatHistory?.id == specialGenerateTextChatParentItemTime,
                      child: CommonTextField(
                        focusNode: focusNode,
                        color: Theme.of(context).canvasColor,
                        controller: nameController,
                        hintText: "请输入名称",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          "温度参数",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: StatefulBuilder(builder: (context, s) {
                          return SfSlider(
                            value: temperature,
                            onChangeEnd: (value) {
                              ref.watch(currentChatParentItemProvider.notifier).state =
                                  currentLocalChatHistory?.copyWith(temperature: value.toString());
                            },
                            onChanged: (value) {
                              temperature = value;
                              s.call(() {});
                            },
                            min: 0.0,
                            max: 2.0,
                            interval: 2,
                            showLabels: true,
                            stepSize: 0.2,
                            enableTooltip: true,
                            showDividers: true,
                            showTicks: true,
                            minorTicksPerInterval: 9,
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // SettingWithTitle(
                  //   label: "上下文消息个数",
                  //   widget: CommonTextField(
                  //     focusNode: countFocusNode,
                  //     color: Theme.of(context).canvasColor,
                  //     controller: countController,
                  //     hintText: "请输入个数",
                  //   ),
                  // ),
                  // const SizedBox(height: 20),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Text(
                          "服务商",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Consumer(builder: (context, ref, _) {
                          final modelList = ref.watch(allModelListProvider);
                          return MultiStateWidget<List<AllModelBean>>(
                            value: modelList,
                            data: (data) => DropdownButtonHideUnderline(
                              child: DropdownButton2<AllModelBean>(
                                isDense: true,
                                isExpanded: true,
                                hint: Text(
                                  '请选择',
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
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "模型",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Builder(builder: (context) {
                          final supportedModels =
                              getModelByApiKey(currentLocalChatHistory?.apiKey ?? "").getTextModels;

                          final model = currentLocalChatHistory?.moduleType ?? supportedModels.first.id ?? "";

                          if (supportedModels.where((element) => element.id == model).isEmpty) {
                            supportedModels.add(SupportedModels(id: model, ownedBy: ""));
                          }
                          return DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isDense: true,
                              isExpanded: true,
                              hint: Text(
                                '请选择',
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
                      ),
                      const SizedBox(width: 15),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
