import 'package:ChatBot/const.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../generated/l10n.dart';
import '../utils/sp_util.dart';

enum SupportedLanguage {
  zh('zh'),
  en('en'),
  ja('ja'),
  ko('ko');

  final String code;

  const SupportedLanguage(this.code);
}

List<String> getSupportedLanguage() {
  return SupportedLanguage.values.map((e) => e.code).toList();
}

Locale getLocaleByDefaultCode() {
  String code = HiveBox().globalLanguageCode;
  String resultCode = code;
  if (code == "auto") {
    var defLan = WidgetsBinding.instance.window.locale.languageCode;
    if (getSupportedLanguage().contains(defLan)) {
      resultCode = defLan;
    } else {
      if (defLan.startsWith("zh")) {
        resultCode = 'zh';
      }
    }
  }

  return S.delegate.supportedLocales
      .firstWhere((element) => element.languageCode == resultCode, orElse: () => WidgetsBinding.instance.window.locale);
}

Locale getLocaleByCode(String code) {
  String resultCode = code;
  if (code == "auto") {
    var defLan = WidgetsBinding.instance.window.locale.languageCode;
    if (getSupportedLanguage().contains(defLan)) {
      resultCode = defLan;
    } else {
      if (defLan.startsWith("zh")) {
        resultCode = 'zh';
      }
    }
  }

  return S.delegate.supportedLocales
      .firstWhere((element) => element.languageCode == resultCode, orElse: () => WidgetsBinding.instance.window.locale);
}

Map<String, String> getLocaleLanguages() {
  String code = getLocaleByDefaultCode().languageCode;

  if (code == SupportedLanguage.en.code) {
    return supportedEnglishLanguages;
  }

  if (code == SupportedLanguage.zh.code) {
    return supportedLanguages;
  }

  if (code == SupportedLanguage.ko.code) {
    return supportedKoLanguages;
  }
  if (code == SupportedLanguage.ja.code) {
    return supportedJapaneseLanguages;
  }

  return supportedEnglishLanguages;
}

String getLocaleNameByCode(String code) {
  if (code == "auto") {
    return "Auto";
  }

  switch (code) {
    case 'en':
      return "English";
    case 'ja':
      return '日本語';
    case 'zh':
      return '简体中文';
    case 'ko':
      return '한국인';
  }
  return "English";
}

final globalLanguageProvider = StateNotifierProvider<GlobalLanguageModel, String>((ref) {
  return GlobalLanguageModel(HiveBox().globalLanguageCode);
});

class GlobalLanguageModel extends StateNotifier<String> {
  GlobalLanguageModel(super.state);

  String get globalLanguage => getLocaleNameByCode(state);

  Locale get getLocale => getLocaleByCode(state);

  void change(String t) {
    if (t == state) return;
    state = t;
    HiveBox().appConfig.put(HiveBox.cAppConfigGlobalLanguageCode, t);
    S.load(getLocaleByCode(state));
  }
}

final primaryColorProvider = StateNotifierProvider<PrimaryColorNotify, Color>((ref) {
  return PrimaryColorNotify(Color(int.parse(HiveBox().primaryColor, radix: 16)));
});

class PrimaryColorNotify extends StateNotifier<Color> {
  PrimaryColorNotify(super.state);

  void change(Color t) {
    if (t == state) return;
    state = t;
    HiveBox().appConfig.put(HiveBox.cAppConfigPrimaryColor, t.value.toRadixString(16));
  }

  Color get color => state;
}

final themeProvider = StateNotifierProvider<ThemeViewModel, BaseTheme>((ref) {
  return ThemeViewModel(LightTheme());
});

enum ThemeType {
  light,
  dark,
  system;

  static ThemeType getType(int type) {
    switch (type) {
      case 0:
        return ThemeType.light;
      case 1:
        return ThemeType.dark;
      case 2:
        return ThemeType.system;
      default:
        return ThemeType.light;
    }
  }
}

BaseTheme _getThemeByType(int themeType) {
  switch (themeType) {
    case 0:
      return LightTheme();
    case 1:
      return DarkTheme();
    case 2:
      var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;
      if (isDarkMode) {
        return DarkTheme();
      }
      return LightTheme();
    default:
      return LightTheme();
  }
}

class ThemeViewModel extends StateNotifier<BaseTheme> {
  ThemeViewModel(super.state) {
    int type = SpUtil.getInt(spLightTheme, defValue: ThemeType.system.index);
    state = _getThemeByType(type);
  }

  ThemeType get type => ThemeType.getType(SpUtil.getInt(spLightTheme, defValue: ThemeType.system.index));

  void change(int t) {
    state = _getThemeByType(t);
    SpUtil.putInt(
      spLightTheme,
      t,
    );
  }
}

abstract class BaseTheme {
  ThemeData theme(Color primaryColor);

  Color xff00ff();

  Color timeColor();

  Color xffF4F4F6();

  Color xffF6F6F6();

  Color inputPanelBg();

  Color pinedBgColor();

  Color unPinedBgColor();

  Color divideBgColor();

  Color userSendMessageTextColor();

  static BaseTheme of(WidgetRef ref) {
    return ref.watch(themeProvider);
  }
}

class LightTheme extends BaseTheme {
  @override
  ThemeData theme(Color primaryColor) {
    return ThemeData.light().copyWith(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: primaryColor,
        surface: Colors.white,
        background: const Color(0xffEDEDED),
        error: const Color(0xffFF3B30),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xff181818),
        onBackground: const Color(0xff181818),
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xffEDEDED),
      primaryColor: primaryColor,
      hoverColor: primaryColor,
      cardColor: Colors.white,
      canvasColor: Colors.white,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: primaryColor,
      ),
      textTheme: const TextTheme(
        titleSmall: TextStyle(
          color: Color(0xff091807),
          fontWeight: FontWeight.normal,
        ),
        titleMedium: TextStyle(
          color: Color(0xff091807),
          fontWeight: FontWeight.normal,
        ),
        titleLarge: TextStyle(
          color: Color(0xff091807),
          fontWeight: FontWeight.normal,
        ),
        bodyLarge: TextStyle(
          color: Color(0xff676767),
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: Color(0xff676767),
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: Color(0xff676767),
          fontSize: 12,
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xffE7E7E7),
        space: 1,
        thickness: 1,
        indent: 15,
      ),
      appBarTheme: const AppBarTheme(
        //配置leading颜色
        iconTheme: IconThemeData(
          color: Color(0xff181818),
          size: 18,
        ),
        backgroundColor: Color(0xffEDEDED),
        titleTextStyle: TextStyle(
          color: Color(0xff181818),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0.1,
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: Color(0xff181818),
          size: 16,
        ),
      ),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xffF6F6F7),
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xff181818),
        selectedLabelStyle: TextStyle(
          color: primaryColor,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xff181818),
          fontSize: 12,
        ),
        selectedIconTheme: IconThemeData(
          color: primaryColor,
          size: 22,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xff181818),
          size: 22,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  @override
  Color xff00ff() {
    return const Color(0xffff00ff);
  }

  @override
  Color xffF4F4F6() {
    return const Color(0xffF4F4F6);
  }

  @override
  Color xffF6F6F6() {
    return const Color(0xffF6F6F6);
  }

  @override
  Color inputPanelBg() {
    return Colors.white;
  }

  @override
  Color userSendMessageTextColor() {
    return Colors.white;
  }

  @override
  Color pinedBgColor() {
    return const Color(0xffEDEDED);
  }

  @override
  Color unPinedBgColor() {
    return Colors.white;
  }

  @override
  Color divideBgColor() {
    return Colors.white;
  }

  @override
  Color timeColor() {
    return const Color(0xff5B5B5B);
  }
}

class DarkTheme extends BaseTheme {
  @override
  ThemeData theme(Color primaryColor) {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: primaryColor,
          surface: const Color(0xff2C2C2C),
          background: const Color(0xffEDEDED),
          error: const Color(0xffFF3B30),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: const Color(0xff1E201D),
          onBackground: const Color(0xff1E201D),
          onError: Colors.white,
          brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xff111111),
      primaryColor: primaryColor,
      hoverColor: primaryColor,
      cardColor: const Color(0xff2C2C2C),
      canvasColor: const Color(0xff2C2C2C),
      textTheme: const TextTheme(
        titleSmall: TextStyle(
          color: Color(0xffD1D1D1),
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        titleMedium: TextStyle(
          color: Color(0xffD1D1D1),
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        titleLarge: TextStyle(
          color: Color(0xffD1D1D1),
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        bodyLarge: TextStyle(
          color: Color(0xff5B5B5B),
          fontSize: 18,
        ),
        bodyMedium: TextStyle(
          color: Color(0xff5B5B5B),
          fontSize: 16,
        ),
        bodySmall: TextStyle(
          color: Color(0xff5B5B5B),
          fontSize: 12,
        ),
      ),
      cardTheme: CardTheme(
        color: const Color(0xff191919),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xff2A2A2A),
        space: 1,
        thickness: 1,
        indent: 15,
      ),
      appBarTheme: const AppBarTheme(
        //配置leading颜色
        iconTheme: IconThemeData(
          color: Color(0xffCFCFCF),
          size: 18,
        ),
        backgroundColor: Color(0xff1C1C1C),
        titleTextStyle: TextStyle(
          color: Color(0xffCFCFCF),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 0.1,
        centerTitle: true,
        actionsIconTheme: IconThemeData(
          color: Color(0xffCFCFCF),
          size: 16,
        ),
      ),
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: primaryColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xff1C1C1C),
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xffCFCFCF),
        selectedLabelStyle: TextStyle(
          color: primaryColor,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          color: Color(0xffCFCFCF),
          fontSize: 12,
        ),
        selectedIconTheme: IconThemeData(
          color: primaryColor,
          size: 22,
        ),
        unselectedIconTheme: const IconThemeData(
          color: Color(0xffCFCFCF),
          size: 22,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  @override
  Color xff00ff() {
    return const Color(0xff00ff00);
  }

  @override
  Color xffF4F4F6() {
    return const Color(0xffF4F4F6);
  }

  @override
  Color xffF6F6F6() {
    return const Color(0xff1C1C1C);
  }

  @override
  Color inputPanelBg() {
    return const Color(0xff282828);
  }

  @override
  Color userSendMessageTextColor() {
    return const Color(0xff03130A);
  }

  @override
  Color pinedBgColor() {
    return const Color(0xff202020);
  }

  @override
  Color unPinedBgColor() {
    return const Color(0xff191919);
  }

  @override
  Color divideBgColor() {
    return const Color(0xff191919);
  }

  @override
  Color timeColor() {
    return const Color(0xff5B5B5B);
  }
}
