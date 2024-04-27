import 'dart:ui';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/module/chat/chat_list_page.dart';
import 'package:ChatBot/module/home/home_viewmodel.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../base/theme.dart';
import '../command/command_page.dart';
import '../setting/setting_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Connectivity().checkConnectivity().then((value) {
      if (value.contains(ConnectivityResult.none)) {
        "请检查网络连接".toast();
      }
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    var brightness = View.of(context).platformDispatcher.platformBrightness;

    if (brightness == Brightness.dark) {
      ref.read(themeProvider.notifier).change(ThemeType.dark.index);
    } else {
      ref.read(themeProvider.notifier).change(ThemeType.light.index);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var navList = ref.watch(homeNavigationProvider);
    var currentIndex = ref.watch(homeIndexProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          ChatListPage(),
          CommandPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: BottomNavigationBar(
            backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withOpacity(0.9),
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: navList.map((e) {
              int index = navList.indexOf(e);
              bool checked = currentIndex == index;
              return BottomNavigationBarItem(
                icon: Icon(checked ? e.first : e.second),
                label: e.last,
                backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withOpacity(0.9),
              );
            }).toList(),
            currentIndex: currentIndex,
            onTap: (int index) {
              ref.read(homeIndexProvider.notifier).update((state) => index);
            },
          ),
        ),
      ),
    );
  }
}
