import '../base.dart';
import '../utils/hive_box.dart';
import '../utils/icloud_async.dart';

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
    HiveBox().appConfig.put(HiveBox.cAppConfigAutoGenerateTitle, v.toString());
  }

  void load() {
    state = bool.parse(HiveBox().appConfig.get(HiveBox.cAppConfigAutoGenerateTitle) ?? "true");
  }
}

final openICloudProvider = StateNotifierProvider<OpenICloudNotify, bool>((ref) {
  return OpenICloudNotify(false);
});

class OpenICloudNotify extends StateNotifier<bool> {
  OpenICloudNotify(super.state) {
    load();
  }

  bool get value => state;

  void change(bool v) {
    state = v;
    HiveBox().appConfig.put(HiveBox.cAppConfigOpenICloud, v.toString());
    if (v) {
      ICloudAsync().startAsync();
    }
  }

  void load() {
    state = bool.parse(HiveBox().appConfig.get(HiveBox.cAppConfigOpenICloud) ?? "false");
  }
}

final defaultTemperatureProvider = StateNotifierProvider<DefaultTemperatureNotify, String>((ref) {
  return DefaultTemperatureNotify(HiveBox().temperature);
});

class DefaultTemperatureNotify extends StateNotifier<String> {
  DefaultTemperatureNotify(String state) : super(state);

  String get value => state;

  void change(String value) {
    state = value;
    HiveBox().appConfig.put(HiveBox.cDefaultTemperature, value);
  }

  void load() {
    state = HiveBox().temperature;
  }
}

final versionProvider = StateProvider<String>((ref) {
  return "";
});

final fromLanguageProvider = StateNotifierProvider<FromLanguageNotify, String>((ref) {
  return FromLanguageNotify(HiveBox().fromLanguage);
});

class FromLanguageNotify extends StateNotifier<String> {
  FromLanguageNotify(String state) : super(state);

  String get value => state;

  void change(String key) {
    state = key;
    HiveBox().appConfig.put(HiveBox.cAppConfigFromLanguage, key);
  }

  void load() {
    state = HiveBox().fromLanguage;
  }
}

final toLanguageProvider = StateNotifierProvider<ToLanguageNotify, String>((ref) {
  return ToLanguageNotify(HiveBox().toLanguage);
});

class ToLanguageNotify extends StateNotifier<String> {
  ToLanguageNotify(String state) : super(state);

  String get value => state;

  void change(String key) {
    state = key;
    HiveBox().appConfig.put(HiveBox.cAppConfigToLanguage, key);
  }

  void load() {
    state = HiveBox().toLanguage;
  }
}
