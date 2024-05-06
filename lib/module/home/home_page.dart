import 'package:ChatBot/base.dart';
import 'package:ChatBot/base/version_check.dart';
import 'package:ChatBot/module/chat/chat_audio/chat_audio_page.dart';
import 'package:ChatBot/module/chat/chat_list_page.dart';
import 'package:ChatBot/module/home/home_viewmodel.dart';
import 'package:lottie/lottie.dart';

import '../../base/components/common_dialog.dart';
import '../../base/components/lottie_widget.dart';
import '../../base/db/chat_item.dart';
import '../../base/theme.dart';
import '../../const.dart';
import '../../hive_bean/openai_bean.dart';
import '../chat/chat_list_view_model.dart';
import '../prompt/prompt_page.dart';
import '../services/services_page.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      VersionCheck().checkLastedVersion(context);
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    var brightness = View.of(context).platformDispatcher.platformBrightness;

    if (SpUtil.getInt(spLightTheme, defValue: ThemeType.system.index) != ThemeType.system.index) {
      return;
    }

    if (brightness == Brightness.dark) {
      ref.read(themeProvider.notifier).change(ThemeType.system.index);
    } else {
      ref.read(themeProvider.notifier).change(ThemeType.system.index);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var currentIndex = ref.watch(homeIndexProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          ChatListPage(),
          PromptPage(),
          ServicesPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        child: SizedBox(
          height: kBottomNavigationBarHeight + MediaQuery.paddingOf(context).bottom + kBottomNavigationBarHeight / 2,
          child: CustomPaint(
            painter: BottomNavPainter(
              bgColor: Theme.of(context).cardColor,
            ),
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom, top: kBottomNavigationBarHeight / 2),
              child: Row(
                children: [
                  Expanded(
                      child: BottomNavItem(
                    label: S.current.home_chat,
                    index: 0,
                    checked: currentIndex == 0,
                  )),
                  Expanded(
                      child: BottomNavItem(
                    label: S.current.home_factory,
                    index: 1,
                    checked: currentIndex == 1,
                  )),
                  GestureDetector(
                    onTap: () {
                      if (!isExistModels()) {
                        showCommonDialog(
                          context,
                          title: S.current.reminder,
                          content: S.current.enter_setting_init_server,
                          hideCancelBtn: true,
                          autoPop: true,
                          confirmText: S.current.yes_know,
                          confirmCallback: () {},
                        );
                        return;
                      }
                      if (!isExistTTSAndWhisperModels()) {
                        showCommonDialog(
                          context,
                          title: S.current.reminder,
                          content: S.current.not_support_tts,
                          hideCancelBtn: true,
                          autoPop: true,
                          confirmText: S.current.yes_know,
                          confirmCallback: () {},
                        );
                        return;
                      }
                      F.push(const ChatAudioPage()).then((value) {
                        ChatItemProvider().deleteAll(specialGenerateAudioChatParentItemTime);
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: const LottieWidget(
                      scale: 2.4,
                      transformHitTests: false,
                      width: 80,
                    ),
                  ),
                  Expanded(
                      child: BottomNavItem(
                    label: S.current.home_server,
                    index: 2,
                    checked: currentIndex == 2,
                  )),
                  Expanded(
                      child: BottomNavItem(
                    label: S.current.home_setting,
                    index: 3,
                    checked: currentIndex == 3,
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavItem extends ConsumerWidget {
  final bool checked;
  final int index;
  final String label;

  const BottomNavItem({super.key, required this.checked, required this.index, required this.label});

  @override
  Widget build(BuildContext context, ref) {
    return GestureDetector(
      onTap: () {
        ref.read(homeIndexProvider.notifier).update((state) => index);
      },
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: checked ? Theme.of(context).textTheme.titleMedium : Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 5),
            Container(
              decoration: BoxDecoration(
                color: checked ? Theme.of(context).primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(5),
              ),
              height: 3,
              width: 30,
            )
          ],
        ),
      ),
    );
  }
}

class BottomNavPainter extends CustomPainter {
  final Color bgColor;

  BottomNavPainter({this.bgColor = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    //绘制矩形，然后顶部中间是个半圆
    Paint paint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTRB(0, kBottomNavigationBarHeight / 2, size.width, size.height), paint);

    canvas.drawCircle(Offset(size.width / 2, kBottomNavigationBarHeight), kBottomNavigationBarHeight / 1.35, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
