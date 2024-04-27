// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "app_name": MessageLookupByLibrary.simpleMessage("AChatBot"),
        "btn_add": MessageLookupByLibrary.simpleMessage("添加"),
        "gemini_setting": MessageLookupByLibrary.simpleMessage("Gemini 服务商"),
        "gemini_setting_desc": MessageLookupByLibrary.simpleMessage(
            "设置 Gemini 的API key 和 API Server"),
        "hint_addServerDesc": MessageLookupByLibrary.simpleMessage("请输入服务器地址"),
        "home_chat": MessageLookupByLibrary.simpleMessage("聊天"),
        "home_factory": MessageLookupByLibrary.simpleMessage("工坊"),
        "home_setting": MessageLookupByLibrary.simpleMessage("设置"),
        "official": MessageLookupByLibrary.simpleMessage("官方"),
        "openai_setting": MessageLookupByLibrary.simpleMessage("ChatGPT 服务商"),
        "openai_setting_desc": MessageLookupByLibrary.simpleMessage(
            "设置 ChatGPT 的API key 和 API Server"),
        "third_party": MessageLookupByLibrary.simpleMessage("第三方")
      };
}
