import 'package:chat_bot/base.dart';
import 'package:chat_bot/hive_bean/local_chat_history.dart';
import 'package:chat_bot/module/setting/ollama/ollama_add_page.dart';

import '../setting/gemini/gemini_viewmodel.dart';
import '../setting/openai/openai_list_page.dart';
import '../setting/openai/openai_viewmodel.dart';
import '../setting/setting_page.dart';

class ServicesPage extends ConsumerStatefulWidget {
  const ServicesPage({super.key});

  @override
  ConsumerState createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.servers),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 15,
              ),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.openai_setting,
                  widget: SettingItem(
                    iconUrl: 'assets/images/openai.png',
                    title: S.current.openai_setting,
                    count: ref.watch(specialModelCountProvider(APIType.openAI)),
                    subTitle: S.current.openai_setting_desc,
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.openAI,
                    ));
                  }),
                );
              }),
              const SizedBox(
                height: 15,
              ),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.gemini_setting,
                  widget: SettingItem(
                    iconUrl: 'assets/images/gemini.png',
                    title: S.current.gemini_setting,
                    count: ref.watch(specialModelCountProvider(APIType.gemini)),
                    subTitle: S.current.gemini_setting_desc,
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.gemini,
                    ));
                  }),
                );
              }),
              const SizedBox(
                height: 15,
              ),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting,
                  widget: SettingItem(
                    iconUrl: 'assets/images/ollama.png',
                    title: S.current.ollama_setting,
                    count: ref.watch(specialModelCountProvider(APIType.ollama)),
                    subTitle: S.current.ollama_setting_desc,
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.ollama,
                    ));
                  }),
                );
              }),
              const SizedBox(
                height: 15,
              ),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', "通义千问"),
                  widget: SettingItem(
                    iconUrl: 'assets/images/qianwen.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', "通义千问"),
                    count: ref.watch(specialModelCountProvider(APIType.qianwen)),
                    subTitle: S.current.ollama_setting_desc.replaceAll('Ollama', "通义千问"),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.qianwen,
                    ));
                  }),
                );
              }),
              const SizedBox(
                height: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
