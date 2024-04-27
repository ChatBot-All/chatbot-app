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

  /// `AChatBot`
  String get app_name {
    return Intl.message(
      'AChatBot',
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

  /// `工坊`
  String get home_factory {
    return Intl.message(
      '工坊',
      name: 'home_factory',
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

  /// `设置 ChatGPT 的API key 和 API Server`
  String get openai_setting_desc {
    return Intl.message(
      '设置 ChatGPT 的API key 和 API Server',
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

  /// `设置 Gemini 的API key 和 API Server`
  String get gemini_setting_desc {
    return Intl.message(
      '设置 Gemini 的API key 和 API Server',
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
