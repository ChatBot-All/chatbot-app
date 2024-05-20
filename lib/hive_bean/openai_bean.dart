import 'package:chat_bot/const.dart';
import 'package:chat_bot/hive_bean/supported_models.dart';
import 'package:chat_bot/utils/hive_box.dart';
import 'package:hive/hive.dart';

part 'openai_bean.g.dart';

@HiveType(typeId: 3)
class AllModelBean {
  @HiveField(0)
  String? apiKey;
  @HiveField(1)
  int? model;
  @HiveField(2)
  String? apiServer;
  @HiveField(3)
  String? organization;
  @HiveField(4)
  String? alias;
  @HiveField(7)
  SupportedModels? defaultModelType;

  SupportedModels get getDefaultModelType => defaultModelType ?? getTextModels.first;

  List<SupportedModels> get getTextModels =>
      supportedModels
          ?.where((element) =>
      element.id?.contains(ttsModelKey) == false &&
          element.id?.contains(whisperModelKey) == false &&
          paintModelKeys.contains(element.id) == false)
          .toList() ??
          [];

  List<SupportedModels> get getTTSModels =>
      supportedModels?.where((element) => element.id?.contains(ttsModelKey) == true).toList() ?? [];

  List<SupportedModels> get getWhisperModels =>
      supportedModels?.where((element) => element.id?.contains(whisperModelKey) == true).toList() ?? [];

  List<SupportedModels> get getPaintModels =>
      supportedModels?.where((element) => paintModelKeys.contains(element.id) == true).toList() ?? [];

  @HiveField(5)
  int? time;

  @HiveField(8)
  int? updateTime;

  @HiveField(6)
  List<SupportedModels>? supportedModels;

  AllModelBean(
      {this.apiKey,
        this.model,
        this.apiServer,
        this.defaultModelType,
        this.organization,
        this.updateTime,
        this.alias,
        this.supportedModels,
        this.time});

  //copyWith
  AllModelBean copyWith({
    String? apiKey,
    int? model,
    String? apiServer,
    String? organization,
    String? alias,
    int? updateTime,
    SupportedModels? defaultModelType,
    List<SupportedModels>? supportedModels,
    int? time,
  }) {
    return AllModelBean(
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      apiServer: apiServer ?? this.apiServer,
      organization: organization ?? this.organization,
      alias: alias ?? this.alias,
      updateTime: updateTime ?? this.updateTime,
      defaultModelType: defaultModelType ?? this.defaultModelType,
      supportedModels: supportedModels ?? this.supportedModels,
      time: time ?? this.time,
    );
  }

  //fromJson
  factory AllModelBean.fromJson(Map<String, dynamic> json) {
    return AllModelBean(
      apiKey: json['apiKey'],
      model: json['model'],
      apiServer: json['apiServer'],
      organization: json['organization'],
      alias: json['alias'],
      updateTime: json['updateTime'],
      defaultModelType: json['defaultModelType'] != null ? SupportedModels.fromJson(json['defaultModelType']) : null,
      supportedModels: json['supportedModels'] != null
          ? (json['supportedModels'] as List).map((e) => SupportedModels.fromJson(e)).toList()
          : null,
      time: json['time'],
    );
  }

  //toJson
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['apiKey'] = apiKey;
    data['model'] = model;
    data['apiServer'] = apiServer;
    data['updateTime'] = updateTime;
    data['organization'] = organization;
    data['alias'] = alias;
    data['defaultModelType'] = defaultModelType?.toJson();
    data['supportedModels'] = supportedModels?.map((e) => e.toJson()).toList();
    data['time'] = time;
    return data;
  }
}

bool isExistModels() {
  return HiveBox().openAIConfig.values.isNotEmpty;
}

AllModelBean getDefaultChatModel() {
  var defaultApiKey = HiveBox().appConfig.get(HiveBox.cDefaultApiServerKey);
  if (defaultApiKey == null || defaultApiKey.isEmpty) {
    var result = HiveBox().openAIConfig.values.first;
    HiveBox().appConfig.put(HiveBox.cDefaultApiServerKey, result.apiKey ?? "");
    return result;
  } else {
    var model = getModelByApiKey(defaultApiKey);
    return model;
  }
}

void setDefaultApiKey(String key) {
  HiveBox().appConfig.put(HiveBox.cDefaultApiServerKey, key);
}

String getDefaultApiKey() {
  var defaultApiKey = HiveBox().appConfig.get(HiveBox.cDefaultApiServerKey);
  if (defaultApiKey == null || defaultApiKey.isEmpty) {
    if (HiveBox().openAIConfig.values.isEmpty) {
      return "";
    }
    var result = HiveBox().openAIConfig.values.first;
    HiveBox().appConfig.put(HiveBox.cDefaultApiServerKey, result.apiKey ?? "");
    return result.apiKey ?? "";
  } else {
    return defaultApiKey;
  }
}

AllModelBean getModelByApiKey(String apiKey) {
  String key = apiKey;
  if (key.isEmpty) {
    key = getDefaultApiKey();
  }
  //如果不存在就返回null
  var model = HiveBox()
      .openAIConfig
      .values
      .firstWhere((element) => element.apiKey == key, orElse: () => HiveBox().openAIConfig.values.first);
  return model;
}

String getSupportedModelByApiKey(String apiKey, {String? preModelType}) {
  String key = apiKey;
  if (key.isEmpty) {
    key = getDefaultApiKey();
  }
  var model =
  HiveBox().openAIConfig.values.firstWhere((element) => element.apiKey == key, orElse: () => AllModelBean());

  if (model.supportedModels == null || model.supportedModels!.isEmpty) {
    return "gpt-4";
  }

  if (preModelType != null && model.supportedModels!.any((element) => element.id == preModelType)) {
    return preModelType;
  }

  return model.getDefaultModelType.id ?? "gpt-4";
}

bool isExistDallE3Models() {
  return HiveBox()
      .openAIConfig
      .values
      .any((element) => element.supportedModels?.any((element) => element.id == "dall-e-3") ?? false);
}

bool isExistTTSAndWhisperModels() {
  return HiveBox()
      .openAIConfig
      .values
      .any((element) => element.getWhisperModels.isNotEmpty && element.getTTSModels.isNotEmpty);
}
