// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
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
  String get localeName => 'zh';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add_prompt": MessageLookupByLibrary.simpleMessage("新增 AI 提示"),
        "alias_desc": MessageLookupByLibrary.simpleMessage("仅用于多个相同的服务商之间区分"),
        "alias_empty": MessageLookupByLibrary.simpleMessage("别名不能为空"),
        "alias_input": MessageLookupByLibrary.simpleMessage("请输入别名"),
        "alias_maxlength": MessageLookupByLibrary.simpleMessage("别名最大10个字符"),
        "alias_repeat": MessageLookupByLibrary.simpleMessage("别名不可以重复"),
        "alias_required": MessageLookupByLibrary.simpleMessage("别名(必填)"),
        "apikey_repeat": MessageLookupByLibrary.simpleMessage("ApiKey不可以重复"),
        "app_name": MessageLookupByLibrary.simpleMessage("ChatBot"),
        "appearance": MessageLookupByLibrary.simpleMessage("外观"),
        "author": MessageLookupByLibrary.simpleMessage("作者"),
        "auto_title": MessageLookupByLibrary.simpleMessage("自动生成标题"),
        "btn_add": MessageLookupByLibrary.simpleMessage("添加"),
        "canPaint": MessageLookupByLibrary.simpleMessage("可作画"),
        "canTalk": MessageLookupByLibrary.simpleMessage("可对话"),
        "canVoice": MessageLookupByLibrary.simpleMessage("可语音"),
        "can_not_get_voice_content":
            MessageLookupByLibrary.simpleMessage("没有识别到语音内容"),
        "cancel": MessageLookupByLibrary.simpleMessage("取消"),
        "canceling": MessageLookupByLibrary.simpleMessage("正在取消..."),
        "cannot_empty": MessageLookupByLibrary.simpleMessage("不能为空"),
        "chat_setting": MessageLookupByLibrary.simpleMessage("聊天设置"),
        "confirm": MessageLookupByLibrary.simpleMessage("确定"),
        "conform_resend": MessageLookupByLibrary.simpleMessage("确定重新发送消息吗"),
        "copy": MessageLookupByLibrary.simpleMessage("复制"),
        "copy_success": MessageLookupByLibrary.simpleMessage("复制成功"),
        "default1": MessageLookupByLibrary.simpleMessage("默认"),
        "delete": MessageLookupByLibrary.simpleMessage("删除"),
        "delete_config_reminder":
            MessageLookupByLibrary.simpleMessage("确定删除当前配置吗"),
        "delete_reminder": MessageLookupByLibrary.simpleMessage("确定删除这条消息吗？"),
        "downloading": MessageLookupByLibrary.simpleMessage("下载中..."),
        "edit": MessageLookupByLibrary.simpleMessage("编辑"),
        "empty_content_need_add":
            MessageLookupByLibrary.simpleMessage("您还没有内容，快点击右上角添加吧"),
        "enter_setting_init_server":
            MessageLookupByLibrary.simpleMessage("请先进入服务并配置服务商"),
        "feedback": MessageLookupByLibrary.simpleMessage("反馈"),
        "feedback_question": MessageLookupByLibrary.simpleMessage("问题反馈"),
        "function": MessageLookupByLibrary.simpleMessage("功能"),
        "gemini_setting": MessageLookupByLibrary.simpleMessage("Gemini 服务商"),
        "gemini_setting_desc": MessageLookupByLibrary.simpleMessage(
            "设置 Gemini 的 API key 和 API Server"),
        "generate_content_is_empty":
            MessageLookupByLibrary.simpleMessage("生成内容为空"),
        "generate_image": MessageLookupByLibrary.simpleMessage("生成图片"),
        "generate_image_fail": MessageLookupByLibrary.simpleMessage("图片生成失败"),
        "getmodules_fail": MessageLookupByLibrary.simpleMessage(
            "获取模型失败,如果确定你的Key可以使用，请直接点击保存"),
        "has_reduce": MessageLookupByLibrary.simpleMessage("开启后会有部分损耗"),
        "hint_addServerDesc": MessageLookupByLibrary.simpleMessage("请输入服务器地址"),
        "hold_micro_phone_talk":
            MessageLookupByLibrary.simpleMessage("按住底部麦克风，开始聊天吧"),
        "hold_talk": MessageLookupByLibrary.simpleMessage("按住说话"),
        "home_chat": MessageLookupByLibrary.simpleMessage("聊天"),
        "home_factory": MessageLookupByLibrary.simpleMessage("工坊"),
        "home_server": MessageLookupByLibrary.simpleMessage("服务"),
        "home_setting": MessageLookupByLibrary.simpleMessage("设置"),
        "input_name": MessageLookupByLibrary.simpleMessage("请输入名称"),
        "input_text": MessageLookupByLibrary.simpleMessage("请输入内容"),
        "is_getting_modules": MessageLookupByLibrary.simpleMessage("正在获取模型..."),
        "is_responsing": MessageLookupByLibrary.simpleMessage("服务器正在回应..."),
        "language": MessageLookupByLibrary.simpleMessage("语言"),
        "leave_cancel": MessageLookupByLibrary.simpleMessage("松开 取消"),
        "leave_send": MessageLookupByLibrary.simpleMessage("松开 发送"),
        "library": MessageLookupByLibrary.simpleMessage("工坊"),
        "loading": MessageLookupByLibrary.simpleMessage("加载中..."),
        "main_language": MessageLookupByLibrary.simpleMessage("简体中文"),
        "models": MessageLookupByLibrary.simpleMessage("模型"),
        "name": MessageLookupByLibrary.simpleMessage("名称"),
        "natural": MessageLookupByLibrary.simpleMessage("现实的"),
        "new_chat": MessageLookupByLibrary.simpleMessage("随便聊聊"),
        "new_version": MessageLookupByLibrary.simpleMessage("发现新版本"),
        "no_audio_file": MessageLookupByLibrary.simpleMessage("无法获取到语音文件"),
        "no_module_use": MessageLookupByLibrary.simpleMessage("没有模型可用的模型"),
        "not_support_tts":
            MessageLookupByLibrary.simpleMessage("您所添加的服务商不支持语音聊天"),
        "official": MessageLookupByLibrary.simpleMessage("官方"),
        "ollama_setting": MessageLookupByLibrary.simpleMessage("Ollama 服务商"),
        "ollama_setting_desc":
            MessageLookupByLibrary.simpleMessage("设置 Ollama 的 API Server"),
        "only_support_dalle3": MessageLookupByLibrary.simpleMessage(
            "目前生成图片仅支持 dall-e-3 模型,您所添加的服务商均不支持该模型"),
        "open_micro_permission":
            MessageLookupByLibrary.simpleMessage("请打开录音权限"),
        "openai_setting": MessageLookupByLibrary.simpleMessage("ChatGPT 服务商"),
        "openai_setting_desc": MessageLookupByLibrary.simpleMessage(
            "设置 ChatGPT 的 API key 和 API Server"),
        "org_notrequired": MessageLookupByLibrary.simpleMessage("组织(选填)"),
        "other_set": MessageLookupByLibrary.simpleMessage("其他设置"),
        "primary_color": MessageLookupByLibrary.simpleMessage("主题色"),
        "record_time_too_short": MessageLookupByLibrary.simpleMessage("录音时间太短"),
        "recording": MessageLookupByLibrary.simpleMessage("正在录音..."),
        "reminder": MessageLookupByLibrary.simpleMessage("温馨提示"),
        "resend": MessageLookupByLibrary.simpleMessage("重新发送"),
        "save": MessageLookupByLibrary.simpleMessage("保存"),
        "save_fail": MessageLookupByLibrary.simpleMessage("保存失败"),
        "save_gallary": MessageLookupByLibrary.simpleMessage("保存到相册"),
        "save_success": MessageLookupByLibrary.simpleMessage("保存成功"),
        "screenshot": MessageLookupByLibrary.simpleMessage("截图"),
        "select": MessageLookupByLibrary.simpleMessage("请选择"),
        "send": MessageLookupByLibrary.simpleMessage("发送"),
        "send_again": MessageLookupByLibrary.simpleMessage("再次发送"),
        "sending_server": MessageLookupByLibrary.simpleMessage("正在发送到服务器..."),
        "servers": MessageLookupByLibrary.simpleMessage("服务商"),
        "set_default_models":
            MessageLookupByLibrary.simpleMessage("未获取到任何模型，已经为它添加系统默认模型。"),
        "share": MessageLookupByLibrary.simpleMessage("分享"),
        "share_to": MessageLookupByLibrary.simpleMessage("分享到"),
        "size": MessageLookupByLibrary.simpleMessage("尺寸"),
        "style": MessageLookupByLibrary.simpleMessage("风格"),
        "tempture": MessageLookupByLibrary.simpleMessage("温度参数"),
        "text_parse_model": MessageLookupByLibrary.simpleMessage("文本解析模型"),
        "theme": MessageLookupByLibrary.simpleMessage("主题"),
        "theme_auto": MessageLookupByLibrary.simpleMessage("跟随系统"),
        "theme_dark": MessageLookupByLibrary.simpleMessage("深色模式"),
        "theme_normal": MessageLookupByLibrary.simpleMessage("普通模式"),
        "theme_setting": MessageLookupByLibrary.simpleMessage("主题设置"),
        "third_party": MessageLookupByLibrary.simpleMessage("第三方"),
        "title": MessageLookupByLibrary.simpleMessage("标题"),
        "title_promot": MessageLookupByLibrary.simpleMessage(
            "使用四到五个字直接返回这句话的简要主题，不要解释、不要标点、不要语气词、不要多余文本，不要加粗，如果没有主题，请直接返回“闲聊”"),
        "translate": MessageLookupByLibrary.simpleMessage("翻译"),
        "tts": MessageLookupByLibrary.simpleMessage("朗读"),
        "update_now": MessageLookupByLibrary.simpleMessage("去更新"),
        "validate": MessageLookupByLibrary.simpleMessage("验证"),
        "validate_fail": MessageLookupByLibrary.simpleMessage("验证失败"),
        "validate_success": MessageLookupByLibrary.simpleMessage("验证成功"),
        "version": MessageLookupByLibrary.simpleMessage("版本"),
        "vivid": MessageLookupByLibrary.simpleMessage("超现实"),
        "voiceChat": MessageLookupByLibrary.simpleMessage("语音聊天"),
        "yes_know": MessageLookupByLibrary.simpleMessage("知道了"),
        "yesterday": MessageLookupByLibrary.simpleMessage("昨天")
      };
}
