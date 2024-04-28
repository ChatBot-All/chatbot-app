import 'package:ChatBot/base.dart';

import '../setting/gemini/gemini_list_page.dart';
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
        title: Text("服务商"),
      ),
      body:  SingleChildScrollView(
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
                    count: ref.watch(openAICountProvider),
                    subTitle: S.current.openai_setting_desc,
                  ).click(() {
                    F.push(const OpenAIListPage());
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
                    count: ref.watch(geminiCountProvider),
                    subTitle: S.current.gemini_setting_desc,
                  ).click(() {
                    F.push(const GeminiListPage());
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
