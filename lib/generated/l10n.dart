// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `ChatBot`
  String get app_name {
    return Intl.message(
      'ChatBot',
      name: 'app_name',
      desc: '',
      args: [],
    );
  }

  /// `聊天`
  String get home_chat {
    return Intl.message(
      '聊天',
      name: 'home_chat',
      desc: '',
      args: [],
    );
  }

  /// `语音聊天`
  String get voiceChat {
    return Intl.message(
      '语音聊天',
      name: 'voiceChat',
      desc: '',
      args: [],
    );
  }

  /// `随便聊聊`
  String get new_chat {
    return Intl.message(
      '随便聊聊',
      name: 'new_chat',
      desc: '',
      args: [],
    );
  }

  /// `工坊`
  String get home_factory {
    return Intl.message(
      '工坊',
      name: 'home_factory',
      desc: '',
      args: [],
    );
  }

  /// `服务`
  String get home_server {
    return Intl.message(
      '服务',
      name: 'home_server',
      desc: '',
      args: [],
    );
  }

  /// `设置`
  String get home_setting {
    return Intl.message(
      '设置',
      name: 'home_setting',
      desc: '',
      args: [],
    );
  }

  /// `ChatGPT 服务商`
  String get openai_setting {
    return Intl.message(
      'ChatGPT 服务商',
      name: 'openai_setting',
      desc: '',
      args: [],
    );
  }

  /// `设置 ChatGPT 的 API key 和 API Server`
  String get openai_setting_desc {
    return Intl.message(
      '设置 ChatGPT 的 API key 和 API Server',
      name: 'openai_setting_desc',
      desc: '',
      args: [],
    );
  }

  /// `Gemini 服务商`
  String get gemini_setting {
    return Intl.message(
      'Gemini 服务商',
      name: 'gemini_setting',
      desc: '',
      args: [],
    );
  }

  /// `设置 Gemini 的 API key 和 API Server`
  String get gemini_setting_desc {
    return Intl.message(
      '设置 Gemini 的 API key 和 API Server',
      name: 'gemini_setting_desc',
      desc: '',
      args: [],
    );
  }

  /// `官方`
  String get official {
    return Intl.message(
      '官方',
      name: 'official',
      desc: '',
      args: [],
    );
  }

  /// `第三方`
  String get third_party {
    return Intl.message(
      '第三方',
      name: 'third_party',
      desc: '',
      args: [],
    );
  }

  /// `添加`
  String get btn_add {
    return Intl.message(
      '添加',
      name: 'btn_add',
      desc: '',
      args: [],
    );
  }

  /// `请输入服务器地址`
  String get hint_addServerDesc {
    return Intl.message(
      '请输入服务器地址',
      name: 'hint_addServerDesc',
      desc: '',
      args: [],
    );
  }

  /// `正在录音...`
  String get recording {
    return Intl.message(
      '正在录音...',
      name: 'recording',
      desc: '',
      args: [],
    );
  }

  /// `正在取消...`
  String get canceling {
    return Intl.message(
      '正在取消...',
      name: 'canceling',
      desc: '',
      args: [],
    );
  }

  /// `正在发送到服务器...`
  String get sending_server {
    return Intl.message(
      '正在发送到服务器...',
      name: 'sending_server',
      desc: '',
      args: [],
    );
  }

  /// `服务器正在回应...`
  String get is_responsing {
    return Intl.message(
      '服务器正在回应...',
      name: 'is_responsing',
      desc: '',
      args: [],
    );
  }

  /// `按住底部麦克风，开始聊天吧`
  String get hold_micro_phone_talk {
    return Intl.message(
      '按住底部麦克风，开始聊天吧',
      name: 'hold_micro_phone_talk',
      desc: '',
      args: [],
    );
  }

  /// `生成内容为空`
  String get generate_content_is_empty {
    return Intl.message(
      '生成内容为空',
      name: 'generate_content_is_empty',
      desc: '',
      args: [],
    );
  }

  /// `没有识别到语音内容`
  String get can_not_get_voice_content {
    return Intl.message(
      '没有识别到语音内容',
      name: 'can_not_get_voice_content',
      desc: '',
      args: [],
    );
  }

  /// `没有模型可用的模型`
  String get no_module_use {
    return Intl.message(
      '没有模型可用的模型',
      name: 'no_module_use',
      desc: '',
      args: [],
    );
  }

  /// `请打开录音权限`
  String get open_micro_permission {
    return Intl.message(
      '请打开录音权限',
      name: 'open_micro_permission',
      desc: '',
      args: [],
    );
  }

  /// `无法获取到语音文件`
  String get no_audio_file {
    return Intl.message(
      '无法获取到语音文件',
      name: 'no_audio_file',
      desc: '',
      args: [],
    );
  }

  /// `按住说话`
  String get hold_talk {
    return Intl.message(
      '按住说话',
      name: 'hold_talk',
      desc: '',
      args: [],
    );
  }

  /// `请输入内容`
  String get input_text {
    return Intl.message(
      '请输入内容',
      name: 'input_text',
      desc: '',
      args: [],
    );
  }

  /// `重新发送`
  String get resend {
    return Intl.message(
      '重新发送',
      name: 'resend',
      desc: '',
      args: [],
    );
  }

  /// `再次发送`
  String get send_again {
    return Intl.message(
      '再次发送',
      name: 'send_again',
      desc: '',
      args: [],
    );
  }

  /// `复制`
  String get copy {
    return Intl.message(
      '复制',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `复制成功`
  String get copy_success {
    return Intl.message(
      '复制成功',
      name: 'copy_success',
      desc: '',
      args: [],
    );
  }

  /// `分享`
  String get share {
    return Intl.message(
      '分享',
      name: 'share',
      desc: '',
      args: [],
    );
  }

  /// `删除`
  String get delete {
    return Intl.message(
      '删除',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `确定删除这条消息吗？`
  String get delete_reminder {
    return Intl.message(
      '确定删除这条消息吗？',
      name: 'delete_reminder',
      desc: '',
      args: [],
    );
  }

  /// `温馨提示`
  String get reminder {
    return Intl.message(
      '温馨提示',
      name: 'reminder',
      desc: '',
      args: [],
    );
  }

  /// `确定重新发送消息吗`
  String get conform_resend {
    return Intl.message(
      '确定重新发送消息吗',
      name: 'conform_resend',
      desc: '',
      args: [],
    );
  }

  /// `确定`
  String get confirm {
    return Intl.message(
      '确定',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `聊天设置`
  String get chat_setting {
    return Intl.message(
      '聊天设置',
      name: 'chat_setting',
      desc: '',
      args: [],
    );
  }

  /// `名称`
  String get name {
    return Intl.message(
      '名称',
      name: 'name',
      desc: '',
      args: [],
    );
  }

  /// `请输入名称`
  String get input_name {
    return Intl.message(
      '请输入名称',
      name: 'input_name',
      desc: '',
      args: [],
    );
  }

  /// `温度参数`
  String get tempture {
    return Intl.message(
      '温度参数',
      name: 'tempture',
      desc: '',
      args: [],
    );
  }

  /// `服务商`
  String get servers {
    return Intl.message(
      '服务商',
      name: 'servers',
      desc: '',
      args: [],
    );
  }

  /// `请选择`
  String get select {
    return Intl.message(
      '请选择',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `模型`
  String get models {
    return Intl.message(
      '模型',
      name: 'models',
      desc: '',
      args: [],
    );
  }

  /// `别名不可以重复`
  String get alias_repeat {
    return Intl.message(
      '别名不可以重复',
      name: 'alias_repeat',
      desc: '',
      args: [],
    );
  }

  /// `ApiKey不可以重复`
  String get apikey_repeat {
    return Intl.message(
      'ApiKey不可以重复',
      name: 'apikey_repeat',
      desc: '',
      args: [],
    );
  }

  /// `超现实`
  String get vivid {
    return Intl.message(
      '超现实',
      name: 'vivid',
      desc: '',
      args: [],
    );
  }

  /// `现实的`
  String get natural {
    return Intl.message(
      '现实的',
      name: 'natural',
      desc: '',
      args: [],
    );
  }

  /// `尺寸`
  String get size {
    return Intl.message(
      '尺寸',
      name: 'size',
      desc: '',
      args: [],
    );
  }

  /// `风格`
  String get style {
    return Intl.message(
      '风格',
      name: 'style',
      desc: '',
      args: [],
    );
  }

  /// `生成图片`
  String get generate_image {
    return Intl.message(
      '生成图片',
      name: 'generate_image',
      desc: '',
      args: [],
    );
  }

  /// `保存到相册`
  String get save_gallary {
    return Intl.message(
      '保存到相册',
      name: 'save_gallary',
      desc: '',
      args: [],
    );
  }

  /// `保存成功`
  String get save_success {
    return Intl.message(
      '保存成功',
      name: 'save_success',
      desc: '',
      args: [],
    );
  }

  /// `保存失败`
  String get save_fail {
    return Intl.message(
      '保存失败',
      name: 'save_fail',
      desc: '',
      args: [],
    );
  }

  /// `图片生成失败`
  String get generate_image_fail {
    return Intl.message(
      '图片生成失败',
      name: 'generate_image_fail',
      desc: '',
      args: [],
    );
  }

  /// `请先进入设置并配置服务商`
  String get enter_setting_init_server {
    return Intl.message(
      '请先进入设置并配置服务商',
      name: 'enter_setting_init_server',
      desc: '',
      args: [],
    );
  }

  /// `知道了`
  String get yes_know {
    return Intl.message(
      '知道了',
      name: 'yes_know',
      desc: '',
      args: [],
    );
  }

  /// `目前生成图片仅支持 dall-e-3 模型,您所添加的服务商均不支持该模型`
  String get only_support_dalle3 {
    return Intl.message(
      '目前生成图片仅支持 dall-e-3 模型,您所添加的服务商均不支持该模型',
      name: 'only_support_dalle3',
      desc: '',
      args: [],
    );
  }

  /// `您所添加的服务商不支持语音聊天`
  String get not_support_tts {
    return Intl.message(
      '您所添加的服务商不支持语音聊天',
      name: 'not_support_tts',
      desc: '',
      args: [],
    );
  }

  /// `工坊`
  String get library {
    return Intl.message(
      '工坊',
      name: 'library',
      desc: '',
      args: [],
    );
  }

  /// `编辑`
  String get edit {
    return Intl.message(
      '编辑',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `别名(必填)`
  String get alice_required {
    return Intl.message(
      '别名(必填)',
      name: 'alice_required',
      desc: '',
      args: [],
    );
  }

  /// `仅用于多个相同的服务商之间区分`
  String get alice_desc {
    return Intl.message(
      '仅用于多个相同的服务商之间区分',
      name: 'alice_desc',
      desc: '',
      args: [],
    );
  }

  /// `验证成功`
  String get validate_success {
    return Intl.message(
      '验证成功',
      name: 'validate_success',
      desc: '',
      args: [],
    );
  }

  /// `验证失败`
  String get validate_fail {
    return Intl.message(
      '验证失败',
      name: 'validate_fail',
      desc: '',
      args: [],
    );
  }

  /// `确定删除当前配置吗`
  String get delete_config_reminder {
    return Intl.message(
      '确定删除当前配置吗',
      name: 'delete_config_reminder',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
