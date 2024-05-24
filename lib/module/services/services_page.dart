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
                    apiType: APIType.openAI,
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
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.gemini_setting,
                  widget: SettingItem(
                    apiType: APIType.gemini,
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
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', APIType.coHere.name),
                  widget: SettingItem(
                    apiType: APIType.coHere,
                    iconUrl: 'assets/images/cohere.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', APIType.coHere.name),
                    count: ref.watch(specialModelCountProvider(APIType.coHere)),
                    subTitle: S.current.gemini_setting_desc.replaceAll('Gemini', APIType.coHere.name),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.coHere,
                    ));
                  }),
                );
              }),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting,
                  widget: SettingItem(
                    apiType: APIType.ollama,
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
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', APIType.deepSeek.name),
                  widget: SettingItem(
                    apiType: APIType.deepSeek,
                    iconUrl: 'assets/images/deepseek.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', APIType.deepSeek.name),
                    count: ref.watch(specialModelCountProvider(APIType.deepSeek)),
                    subTitle: S.current.gemini_setting_desc.replaceAll('Gemini', APIType.deepSeek.name),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.deepSeek,
                    ));
                  }),
                );
              }),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', APIType.kimi.name),
                  widget: SettingItem(
                    apiType: APIType.kimi,
                    iconUrl: 'assets/images/kimi.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', APIType.kimi.name),
                    count: ref.watch(specialModelCountProvider(APIType.kimi)),
                    subTitle: S.current.gemini_setting_desc.replaceAll('Gemini', APIType.kimi.name),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.kimi,
                    ));
                  }),
                );
              }),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', "通义千问"),
                  widget: SettingItem(
                    apiType: APIType.qianwen,
                    iconUrl: 'assets/images/qianwen.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', "通义千问"),
                    count: ref.watch(specialModelCountProvider(APIType.qianwen)),
                    subTitle: S.current.gemini_setting_desc.replaceAll('Gemini', "通义千问"),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.qianwen,
                    ));
                  }),
                );
              }),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', "智谱"),
                  widget: SettingItem(
                    apiType: APIType.zhipu,
                    iconUrl: 'assets/images/kimi.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', "智谱"),
                    count: ref.watch(specialModelCountProvider(APIType.zhipu)),
                    subTitle: S.current.gemini_setting_desc.replaceAll('Gemini', "智谱"),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.zhipu,
                    ));
                  }),
                );
              }),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', APIType.zeroOne.name),
                  widget: SettingItem(
                    apiType: APIType.zeroOne,
                    iconUrl: 'assets/images/01.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', APIType.zeroOne.name),
                    count: ref.watch(specialModelCountProvider(APIType.zeroOne)),
                    subTitle: S.current.gemini_setting_desc.replaceAll('Gemini', APIType.zeroOne.name),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.zeroOne,
                    ));
                  }),
                );
              }),
              Consumer(builder: (context, ref, _) {
                return SettingWithTitle(
                  label: S.current.ollama_setting.replaceAll('Ollama', APIType.miniMax.name),
                  widget: SettingItem(
                    apiType: APIType.miniMax,
                    iconUrl: 'assets/images/minimax.png',
                    title: S.current.ollama_setting.replaceAll('Ollama', APIType.miniMax.name),
                    count: ref.watch(specialModelCountProvider(APIType.miniMax)),
                    subTitle: S.current.gemini_setting_desc.replaceAll('Gemini', APIType.miniMax.name),
                  ).click(() {
                    F.push(const OpenAIListPage(
                      apiType: APIType.miniMax,
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
