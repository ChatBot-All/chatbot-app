import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/theme.dart';
import 'package:flutter/cupertino.dart';

class CommonTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String hintText;
  final Color? color;
  final int? maxLine;
  final int? maxLength;
  final FocusNode? focusNode;

  const CommonTextField(
      {super.key, this.focusNode, required this.controller, required this.hintText, this.maxLength, this.color, this.maxLine = 1});

  @override
  Widget build(BuildContext context, ref) {
    return CupertinoTextField(
      focusNode: focusNode,
      placeholder: S.current.input_text,
      controller: controller,
      maxLines: 1,
      minLines: 1,
      maxLength: maxLength,
      cursorColor: Theme.of(context).primaryColor,
      style: Theme.of(context).textTheme.titleMedium,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      decoration: BoxDecoration(
        color: ref.watch(themeProvider).inputPanelBg(),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
