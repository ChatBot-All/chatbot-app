import 'package:ChatBot/utils/hive_box.dart';

import 'base.dart';

class Initial {
  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await HiveBox().init();
    await SpUtil.getInstance();
    await SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
  }
}
