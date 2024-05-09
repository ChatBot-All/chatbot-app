import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:ChatBot/module/setting/openai/openai_viewmodel.dart';
import 'package:flutter/cupertino.dart';

import '../../../base.dart';
import '../../../base/api.dart';
import '../../../base/components/common_text_field.dart';
import '../../../base/theme.dart';
import '../../../hive_bean/local_chat_history.dart';
import '../setting_page.dart';

class OpenAIAddPage extends ConsumerStatefulWidget {
  final AllModelBean? openAi;

  const OpenAIAddPage({super.key, this.openAi});

  @override
  ConsumerState createState() => _OpenAIAddPageState();
}

class _OpenAIAddPageState extends ConsumerState<OpenAIAddPage> {
  late AllModelBean openAi;
  int? time;

  TextEditingController controller = TextEditingController();
  TextEditingController orgController = TextEditingController();
  TextEditingController aliasController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    openAi = widget.openAi ?? AllModelBean();
    super.initState();
    aliasController.text = openAi.alias ?? "";
    controller.text = openAi.apiKey ?? "";
    orgController.text = openAi.organization ?? "";
    time = openAi.time;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(apiServerHistoryProvider.notifier).add(openAi.apiServer);
      ref.watch(apiServerAddressProvider.notifier).update((state) => openAi.apiServer ?? "https://api.openai.com");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.openAi?.time != null
              ? "${S.current.edit} ChatGPT ${S.current.servers}"
              : "${S.current.btn_add} ChatGPT ${S.current.servers}"),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              SettingWithTitle(
                label: S.current.alias_required,
                widget: CommonTextField(
                    maxLength: 10,
                    color: Theme.of(context).canvasColor,
                    controller: aliasController,
                    hintText: S.current.input_text),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Text(
                  S.current.alias_desc,
                  style: TextStyle(
                    color: ref.watch(themeProvider).timeColor(),
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SettingWithTitle(
                label: S.current.org_notrequired,
                widget: CommonTextField(
                    color: Theme.of(context).canvasColor, controller: orgController, hintText: S.current.input_text),
              ),
              const SizedBox(height: 15),
              SettingWithTitle(
                label: "API Key",
                widget: CommonTextField(
                    maxLine: 3, color: Theme.of(context).canvasColor, controller: controller, hintText: "sk-xxxxxx"),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            "API Server",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Builder(builder: (context) {
                          return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                CupertinoIcons.add_circled,
                                color: Theme.of(context).primaryColor,
                                size: 16,
                              )).click(() {
                            showModalBottomSheet(
                                isScrollControlled: true,
                                context: context,
                                constraints: const BoxConstraints(
                                  minHeight: 250,
                                ),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10),
                                    topRight: Radius.circular(10),
                                  ),
                                ),
                                builder: (context) {
                                  TextEditingController serverNameController = TextEditingController();
                                  return Card(
                                    color: ref.watch(themeProvider).xffF6F6F6(),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 10),
                                          child: Text(
                                            "API Server",
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(30),
                                          child: CommonTextField(
                                              controller: serverNameController, hintText: S.current.hint_addServerDesc),
                                        ),
                                        Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 30),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          child: Text(
                                            S.current.btn_add,
                                            style: const TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                        ).click(() {
                                          ref.read(apiServerHistoryProvider.notifier).add(serverNameController.text);
                                          F.pop();
                                        }),
                                        SizedBox(
                                          height: MediaQuery.of(context).viewInsets.bottom,
                                        ),
                                      ],
                                    ),
                                  );
                                }).then((value) {
                              //隐藏键盘
                              FocusScope.of(context).unfocus();
                            });
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Consumer(
                      builder: (context, ref, _) {
                        var list = ref.watch(apiServerHistoryProvider);
                        String server = ref.watch(apiServerAddressProvider);
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          separatorBuilder: (context, index) {
                            return const Divider(
                              height: 10,
                              indent: 0,
                              color: Colors.transparent,
                            );
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                onTap: () {
                                  ref.watch(apiServerAddressProvider.notifier).state = list[index];
                                },
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                                title: Text(
                                  list[index],
                                  style: TextStyle(
                                    color: server == list[index]
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(context).textTheme.titleSmall?.color,
                                    fontSize: 14,
                                  ),
                                ),
                                trailing: server == list[index]
                                    ? Icon(
                                        CupertinoIcons.check_mark,
                                        color: Theme.of(context).primaryColor,
                                        size: 16,
                                      )
                                    : (index != 0
                                        ? const Icon(
                                            CupertinoIcons.delete,
                                            color: Colors.red,
                                            size: 16,
                                          ).click(() {
                                            ref.read(apiServerHistoryProvider.notifier).remove(list[index]);
                                          })
                                        : null),
                              ),
                            );
                          },
                          itemCount: list.length,
                        );
                      },
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  S.current.validate,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ).click(() async {
                AllModelBean openAi = AllModelBean();
                openAi.apiKey = controller.text;
                openAi.organization = orgController.text;
                openAi.apiServer = ref.watch(apiServerAddressProvider.notifier).state;
                openAi.model = APIType.openAI.code;
                openAi.alias = aliasController.text;
                var result = await API().validateApiKey(openAi);
                if (result) {
                  S.current.validate_success.success();
                }
              }),
              const SizedBox(height: 15),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  S.current.save,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ).click(() async {
                try {
                  if (aliasController.text.isEmpty) {
                    S.current.alias_empty.toast();
                    return;
                  }

                  //别名最大10个字符
                  if (aliasController.text.length > 10) {
                    S.current.alias_maxlength.toast();
                    return;
                  }

                  if (controller.text.isEmpty) {
                    "API Key${S.current.cannot_empty}".toast();
                    return;
                  }

                  if (ref.watch(apiServerAddressProvider).isEmpty) {
                    "API Server${S.current.cannot_empty}".toast();
                    return;
                  }

                  S.current.is_getting_modules.loading();

                  var supportedModels = <SupportedModels>[];

                  AllModelBean openAi = AllModelBean();
                  openAi.apiKey = controller.text;
                  openAi.organization = orgController.text;
                  openAi.apiServer = ref.watch(apiServerAddressProvider.notifier).state;
                  openAi.model = APIType.openAI.code;
                  openAi.alias = aliasController.text;
                  openAi.time = time ?? DateTime.now().millisecondsSinceEpoch;

                  var apiResult = await API().getSupportModules(openAi);
                  supportedModels = apiResult.map((e) => SupportedModels(id: e.id, ownedBy: e.ownedBy)).toList();
                  if (supportedModels.isEmpty) {
                    S.current.set_default_models.toast();
                    var models = [
                      "gpt-4",
                      "gpt-4-0314",
                      "gpt-4-0613",
                      "gpt-4-32k",
                      "gpt-4-32k-0314",
                      "gpt-4-32k-0613",
                      "gpt-4-turbo-preview",
                      "gpt-4-1106-preview",
                      "gpt-4-0125-preview",
                      "gpt-4-vision-preview",
                      "gpt-3.5-turbo",
                      "gpt-3.5-turbo-0125",
                      "gpt-3.5-turbo-0301",
                      "gpt-3.5-turbo-0613",
                      "gpt-3.5-turbo-1106",
                      "gpt-3.5-turbo-16k",
                      "gpt-3.5-turbo-16k-0613",
                      "gemini-pro",
                      "gemini-pro-vision",
                    ];
                    supportedModels.addAll(models.map((e) => SupportedModels(id: e, ownedBy: "openai")).toList());
                  }
                  openAi.supportedModels = supportedModels;

                  if (supportedModels.where((element) => element.id?.contains("gpt-4") == true).isNotEmpty) {
                    openAi.defaultModelType =
                        supportedModels.firstWhere((element) => element.id?.contains("gpt-4") == true);
                  }

                  bool result;
                  if (widget.openAi?.time != null) {
                    result = ref.read(openAiListProvider(APIType.openAI).notifier).update(openAi);
                  } else {
                    result = ref.read(openAiListProvider(APIType.openAI).notifier).add(openAi);
                  }
                  if (result) {
                    S.current.save_success.success();
                    F.pop();
                  }
                } catch (e) {
                  e.toString().fail();
                }
              }),
            ],
          ),
        ),
      ),
    );
  }
}
