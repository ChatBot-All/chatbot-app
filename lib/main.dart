import 'package:ChatBot/module/splash_page.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'base.dart';
import 'base/riverpod/provider_log.dart';
import 'base/theme.dart';
import 'initial.dart';

void main() async {
  await Initial.init();

  S.load(getLocaleByCode(HiveBox().globalLanguageCode));
  runApp(
    ProviderScope(
      observers: [
        ProviderLogger(),
      ],
      child: const MyApp(),
    ),
  );
  if (Platform.isAndroid) {
    SystemUiOverlayStyle style = const SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(style);
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var globalLanguage = ref.watch(globalLanguageProvider);
    var primaryColor = ref.watch(primaryColorProvider);
    return MaterialApp(
      key: ValueKey(globalLanguage),
      navigatorKey: F.navigatorKey,
      title: S.current.app_name,
      localeResolutionCallback: (Locale? locale, Iterable<Locale> supportedLocales) {
        if (locale != null) {
          return locale;
        }
        return supportedLocales.first;
      },
      debugShowCheckedModeBanner: false,
      theme: ref.watch(themeProvider).theme(primaryColor),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const SplashPage(),
      locale: getLocaleByCode(globalLanguage),
      builder: (context, child) {
        return FlutterEasyLoading(
            child: ScrollConfiguration(
          behavior: const ScrollPhysicsConfig(),
          child: child ?? Container(),
        ));
      },
    );
  }
}

/// 全局滚动配置，默认全部使用iOS的BouncingScrollPhysics效果
class ScrollPhysicsConfig extends ScrollBehavior {
  const ScrollPhysicsConfig();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return const BouncingScrollPhysics();
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
      default:
        return const BouncingScrollPhysics();
    }
  }
}
