import 'package:ChatBot/hive_bean/openai_bean.dart';
import 'package:ChatBot/hive_bean/supported_models.dart';
import 'package:ChatBot/module/setting/openai/openai_viewmodel.dart';

import '../../../base.dart';
import '../../../base/api.dart';
import '../../../base/components/common_text_field.dart';
import '../../../hive_bean/local_chat_history.dart';
import '../../../utils/hive_box.dart';
import '../setting_page.dart';

///apikey 和 apiServer取一样的字段
class OllamaAddPage extends ConsumerStatefulWidget {
  final AllModelBean? openAi;

  const OllamaAddPage({super.key, this.openAi});

  @override
  ConsumerState createState() => _OllamaAddPageState();
}

class _OllamaAddPageState extends ConsumerState<OllamaAddPage> {
  late AllModelBean openAi;
  int? time;

  TextEditingController controller = TextEditingController();
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
    time = openAi.time;
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
              ? "${S.current.edit} Ollama ${S.current.servers}"
              : "${S.current.btn_add} Ollama ${S.current.servers}"),
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
              const SizedBox(height: 15),
              SettingWithTitle(
                label: "Server",
                widget: CommonTextField(
                    maxLine: 3,
                    color: Theme.of(context).canvasColor,
                    controller: controller,
                    hintText: "http://localhost:11434"),
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
                AllModelBean openAi = AllModelBean();
                openAi.apiKey = controller.text;
                openAi.apiServer = controller.text;
                openAi.model = APIType.ollama.code;
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
                    "Server ${S.current.cannot_empty}".toast();
                    return;
                  }

                  S.current.is_getting_modules.loading();

                  var supportedModels = <SupportedModels>[];

                  AllModelBean openAi = AllModelBean();
                  openAi.apiKey = controller.text;
                  openAi.apiServer = controller.text;
                  openAi.model = APIType.ollama.code;
                  openAi.alias = aliasController.text;
                  openAi.time = time ?? DateTime.now().millisecondsSinceEpoch;

                  var apiResult = await API().getSupportModules(openAi);
                  supportedModels = apiResult.map((e) => SupportedModels(id: e.id, ownedBy: e.ownedBy)).toList();
                  if (supportedModels.isEmpty) {
                    return;
                  }
                  openAi.supportedModels = supportedModels;

                  if (supportedModels.isNotEmpty) {
                    openAi.defaultModelType = supportedModels.first;
                  }

                  bool result;
                  if (widget.openAi?.time != null) {
                    result = ref.read(openAiListProvider(APIType.ollama).notifier).update(openAi);
                  } else {
                    result = ref.read(openAiListProvider(APIType.ollama).notifier).add(openAi);
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
