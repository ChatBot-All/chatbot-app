import '../base.dart';
import '../utils/hive_box.dart';

final autoGenerateTitleProvider = StateNotifierProvider<AutoGenerateTitleNotify, bool>((ref) {
  return AutoGenerateTitleNotify(false);
});

class AutoGenerateTitleNotify extends StateNotifier<bool> {
  AutoGenerateTitleNotify(super.state) {
    load();
  }

  bool get value => state;

  void change(bool v) {
    state = v;
  }

  void load() {
    state = bool.parse(HiveBox().appConfig.get(HiveBox.cAppConfigAutoGenerateTitle) ?? "true");
  }
}
