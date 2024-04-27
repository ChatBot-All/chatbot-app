import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/sp_util.dart';

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
    int type = SpUtil.getInt("lightTheme", defValue: ThemeType.system.index);
    state = _getThemeByType(type);
  }

  ThemeType get type => ThemeType.getType(SpUtil.getInt("lightTheme", defValue: 2));

  void change(int t) {
    if (t == type.index) return;

    state = _getThemeByType(t);
    SpUtil.putInt(
      "lightTheme",
      t,
    );
  }
}

abstract class BaseTheme {
  ThemeData theme();

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
  ThemeData theme() {
    return ThemeData.light().copyWith(
      useMaterial3: false,
      colorScheme: const ColorScheme.light(
        primary: Color(0xff01C160),
        secondary: Color(0xff01C160),
        surface: Colors.white,
        background: Color(0xffEDEDED),
        error: Color(0xffFF3B30),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xff181818),
        onBackground: Color(0xff181818),
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xffEDEDED),
      primaryColor: const Color(0xff01C160),
      hoverColor: const Color(0xff01C160),
      cardColor: Colors.white,
      canvasColor: Colors.white,
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xffF6F6F7),
        selectedItemColor: Color(0xff01C160),
        unselectedItemColor: Color(0xff181818),
        selectedLabelStyle: TextStyle(
          color: Color(0xff01C160),
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          color: Color(0xff181818),
          fontSize: 12,
        ),
        selectedIconTheme: IconThemeData(
          color: Color(0xff01C160),
          size: 22,
        ),
        unselectedIconTheme: IconThemeData(
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
  ThemeData theme() {
    return ThemeData.dark().copyWith(
      useMaterial3: false,
      colorScheme: const ColorScheme.dark(
          primary: Color(0xff01C160),
          secondary: Color(0xff01C160),
          surface: Color(0xff2C2C2C),
          background: Color(0xffEDEDED),
          error: Color(0xffFF3B30),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Color(0xff1E201D),
          onBackground: Color(0xff1E201D),
          onError: Colors.white,
          brightness: Brightness.dark),
      scaffoldBackgroundColor: const Color(0xff111111),
      primaryColor: const Color(0xff01C160),
      hoverColor: const Color(0xff01C160),
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
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xff1C1C1C),
        selectedItemColor: Color(0xff01C160),
        unselectedItemColor: Color(0xffCFCFCF),
        selectedLabelStyle: TextStyle(
          color: Color(0xff01C160),
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          color: Color(0xffCFCFCF),
          fontSize: 12,
        ),
        selectedIconTheme: IconThemeData(
          color: Color(0xff01C160),
          size: 22,
        ),
        unselectedIconTheme: IconThemeData(
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
