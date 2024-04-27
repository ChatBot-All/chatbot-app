import 'package:flutter_markdown/flutter_markdown.dart';

import '../../base.dart';

class ChatMarkDown extends StatelessWidget {
  final String content;

  const ChatMarkDown({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    MarkdownStyleSheet styleSheet = MarkdownStyleSheet(
      p: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      h1: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      h2: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      h3: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      h4: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      h5: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      h6: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      blockquote:
          Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      code: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      em: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      strong: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      del: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      tableHead:
          Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      tableBody:
          Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).textTheme.titleMedium?.color),
      tableHeadAlign: TextAlign.center,
      tableBorder: TableBorder.all(
        color: Theme.of(context).textTheme.titleMedium?.color ?? Colors.black,
        width: 1,
      ),
      blockquoteDecoration: BoxDecoration(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        borderRadius: BorderRadius.circular(5),
      ),
      blockquotePadding: const EdgeInsets.all(5),
    );
    return Markdown2(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      selectable: false,
      styleSheet: styleSheet,
      styleSheetTheme: MarkdownStyleSheetBaseTheme.material,
      data: content,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
    );
  }
}

class Markdown2 extends MarkdownWidget {
  /// Creates a scrolling widget that parses and displays Markdown.
  const Markdown2({
    super.key,
    required super.data,
    super.selectable,
    super.styleSheet,
    super.styleSheetTheme = null,
    super.fitContent = true,
    super.syntaxHighlighter,
    super.onTapLink,
    super.onTapText,
    super.imageDirectory,
    super.blockSyntaxes,
    super.inlineSyntaxes,
    super.extensionSet,
    super.imageBuilder,
    super.checkboxBuilder,
    super.bulletBuilder,
    super.builders,
    super.paddingBuilders,
    super.listItemCrossAxisAlignment,
    this.padding = const EdgeInsets.all(16.0),
    this.controller,
    this.physics,
    this.shrinkWrap = false,
    super.softLineBreak,
  });

  /// The amount of space by which to inset the children.
  final EdgeInsets padding;

  /// An object that can be used to control the position to which this scroll view is scrolled.
  ///
  /// See also: [ScrollView.controller]
  final ScrollController? controller;

  /// How the scroll view should respond to user input.
  ///
  /// See also: [ScrollView.physics]
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the scroll direction should be
  /// determined by the contents being viewed.
  ///
  /// See also: [ScrollView.shrinkWrap]
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context, List<Widget>? children) {
    return ListView(
      padding: padding,
      controller: controller,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children!,
    );
  }
}
