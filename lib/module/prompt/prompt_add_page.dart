import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/db/prompt_item.dart';
import 'package:ChatBot/module/prompt/prompt_viewmodel.dart';

import '../../base/components/common_text_field.dart';
import '../setting/setting_page.dart';

class PromptAddPage extends ConsumerStatefulWidget {
  const PromptAddPage({super.key});

  @override
  ConsumerState createState() => _PromptAddPageState();
}

class _PromptAddPageState extends ConsumerState<PromptAddPage> {
  final authorController = TextEditingController();
  final titleController = TextEditingController();
  final promptController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.current.add_prompt),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 15),
              SettingWithTitle(
                label: S.current.author,
                widget: CommonTextField(
                    maxLength: 10,
                    color: Theme.of(context).canvasColor,
                    controller: authorController,
                    hintText: S.current.input_text),
              ),
              const SizedBox(height: 15),
              SettingWithTitle(
                label: S.current.title,
                widget: CommonTextField(
                    maxLine: 1,
                    minLine: 1,
                    maxLength: 50,
                    color: Theme.of(context).canvasColor,
                    controller: titleController,
                    hintText: S.current.input_text),
              ),
              const SizedBox(height: 15),
              SettingWithTitle(
                label: "Prompt",
                widget: CommonTextField(
                    maxLine: 10,
                    minLine: 1,
                    color: Theme.of(context).canvasColor,
                    controller: promptController,
                    hintText: S.current.input_text),
              ),
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
                if (authorController.text.isEmpty) {
                  "${S.current.author}${S.current.cannot_empty}".fail();
                  return;
                }
                if (titleController.text.isEmpty) {
                  "${S.current.title}${S.current.cannot_empty}".fail();
                  return;
                }
                if (promptController.text.isEmpty) {
                  "Prompt${S.current.cannot_empty}".fail();
                  return;
                }

                PromptItem promptItem = PromptItem();
                promptItem.author = authorController.text;
                promptItem.title = titleController.text;
                promptItem.prompt = promptController.text;
                promptItem.time = DateTime.now().millisecondsSinceEpoch;
                ref.watch(promptListProvider.notifier).addPrompt(promptItem);
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }
}
