import 'package:chat_bot/hive_bean/openai_bean.dart';
import 'package:chat_bot/hive_bean/supported_models.dart';
import 'package:chat_bot/module/setting/openai/openai_viewmodel.dart';
import 'package:flutter/cupertino.dart';

import '../../../base.dart';
import '../../../base/api.dart';
import '../../../base/components/common_text_field.dart';
import '../../../base/theme.dart';
import '../../../hive_bean/local_chat_history.dart';
import '../../services/services_page.dart';
import '../setting_page.dart';
import 'deepseek_viewmodel.dart';

class DeepSeekAddPage extends ConsumerStatefulWidget {
  final AllModelBean? openAi;

  const DeepSeekAddPage({super.key, this.openAi});

  @override
  ConsumerState createState() => _DeepSeekAddPageState();
}

class _DeepSeekAddPageState extends ConsumerState<DeepSeekAddPage> {
  late AllModelBean openAi;
  int? time;

  TextEditingController controller = TextEditingController();
  TextEditingController aliasController = TextEditingController();

  @override
  void initState() {
    openAi = widget.openAi ?? AllModelBean();
    super.initState();
    aliasController.text = openAi.alias ?? "";
    controller.text = openAi.apiKey ?? "";
    time = openAi.time;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.watch(deepSeekApiServerAddressProvider.notifier).update((state) => openAi.apiServer ?? APIType.deepSeek.host);
    });
  }

  @override
  void dispose() {
    super.dispose();
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
              ? "${S.current.edit} ${APIType.deepSeek.name} ${S.current.servers}"
              : "${S.current.btn_add} ${APIType.deepSeek.name} ${S.current.servers}"),
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
                label: "API Key",
                widget: CommonTextField(
                    maxLine: 3, color: Theme.of(context).canvasColor, controller: controller, hintText: "API Key"),
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
                      ],
                    ),
                    const SizedBox(height: 10),
                    Consumer(
                      builder: (context, ref, _) {
                        var list = [APIType.deepSeek.host];
                        String server = ref.watch(deepSeekApiServerAddressProvider);
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
                                  ref.watch(deepSeekApiServerAddressProvider.notifier).state = list[index];
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
                                trailing: Icon(
                                  CupertinoIcons.check_mark,
                                  color: Theme.of(context).primaryColor,
                                  size: 16,
                                ),
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
              const SizedBox(height: 15),
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
                if (controller.text.isEmpty) {
                  "API Key${S.current.cannot_empty}".toast();
                  return;
                }

                if (ref.watch(deepSeekApiServerAddressProvider).isEmpty) {
                  "API Server${S.current.cannot_empty}".toast();
                  return;
                }
                AllModelBean openAi = AllModelBean();
                openAi.apiKey = controller.text;
                openAi.apiServer = ref.watch(deepSeekApiServerAddressProvider.notifier).state;
                openAi.model = APIType.deepSeek.code;
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

                if (ref.watch(deepSeekApiServerAddressProvider).isEmpty) {
                  "API Server${S.current.cannot_empty}".toast();
                  return;
                }

                S.current.is_getting_modules.loading();

                var supportedModels = <SupportedModels>[];

                AllModelBean openAi = AllModelBean();
                openAi.apiKey = controller.text.trim();
                openAi.apiServer = ref.watch(deepSeekApiServerAddressProvider.notifier).state.trim();
                openAi.model = APIType.deepSeek.code;
                openAi.alias = aliasController.text.trim();
                openAi.time = time ?? DateTime.now().millisecondsSinceEpoch;
                openAi.updateTime = DateTime.now().millisecondsSinceEpoch;

                try {
                  var result = await API().getSupportModules(openAi);
                  supportedModels = result.map((e) => SupportedModels(id: e.id, ownedBy: e.ownedBy)).toList();
                } catch (e) {}

                if (supportedModels.isEmpty) {
                  return;
                }

                openAi.supportedModels = supportedModels;

                openAi.defaultModelType = supportedModels.first;
                bool result;
                if (widget.openAi?.time != null) {
                  result = await ref.read(openAiListProvider(APIType.deepSeek).notifier).update(openAi);
                } else {
                  result = await ref.read(openAiListProvider(APIType.deepSeek).notifier).add(openAi);
                }
                if (result) {
                  S.current.save_success.success();
                  F.pop();
                }
              }),
              SizedBox(height: 15 + MediaQuery.paddingOf(context).bottom),
            ],
          ),
        ),
      ),
    );
  }
}
