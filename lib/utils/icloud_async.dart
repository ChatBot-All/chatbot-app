import 'dart:async';
import 'dart:convert';
import 'package:chat_bot/hive_bean/local_chat_history.dart';
import 'package:chat_bot/hive_bean/openai_bean.dart';
import 'package:chat_bot/main.dart';
import 'package:chat_bot/module/setting/openai/openai_viewmodel.dart';
import 'package:icloud_storage/icloud_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../base.dart';
import 'hive_box.dart';

class ICloudAsync {
  //单例
  static ICloudAsync? _instance;

  factory ICloudAsync() {
    _instance ??= ICloudAsync._internal();
    return _instance!;
  }

  ICloudAsync._internal();

  StreamSubscription? filesUpdateSub;
  StreamSubscription? downloadProgressSub;
  StreamSubscription? uploadProgressSub;

  Future<void> uploadDirectly() async {
    try {
      //不是 ios 和 macos
      if (!Platform.isMacOS && !Platform.isIOS) {
        return;
      }

      if ((HiveBox().appConfig.get(HiveBox.cAppConfigOpenICloud) ?? "false") == "false") {
        return;
      }

      //获取 HiveBox里的所有数据
      List<AllModelBean> localAllModelBeanList = HiveBox().openAIConfig.values.toList();

      var localPath = "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}";

      File file = File(localPath);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      file.writeAsStringSync(jsonEncode(localAllModelBeanList));

      if (uploadProgressSub != null) {
        uploadProgressSub?.cancel();
      }
      try {
        await ICloudStorage.delete(
          containerId: 'iCloud.top.achatbot.models',
          relativePath: 'allModels',
        );
      } catch (e) {
        print(e);
      }
      //同步到云端
      await ICloudStorage.upload(
        filePath: localPath,
        containerId: 'iCloud.top.achatbot.models',
        destinationRelativePath: 'allModels',
        onProgress: (stream) {
          uploadProgressSub = stream.listen(
            (progress) {},
            onDone: () {
              print("upload done");
            },
            onError: (err) {
              if (err is PlatformException) {
                if (err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
                  print(
                      'Platform Exception: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app');
                } else if (err.code == PlatformExceptionCode.fileNotFound) {
                  print('File not found');
                } else {
                  print('Platform Exception: ${err.message}; Details: ${err.details}');
                }
              } else {
                print(err.toString());
              }
              uploadProgressSub?.cancel();
            },
            cancelOnError: true,
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> startAsync() async {
    try {
      //不是 ios 和 macos
      if (!Platform.isMacOS && !Platform.isIOS) {
        return;
      }
      if ((HiveBox().appConfig.get(HiveBox.cAppConfigOpenICloud) ?? "false") == "false") {
        return;
      }

      //获取 HiveBox里的所有数据
      List<AllModelBean> localAllModelBeanList = HiveBox().openAIConfig.values.toList();

      var localPath = "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}";

      if (!File(localPath).existsSync()) {
        File(localPath).createSync(recursive: true);
      }

      if (downloadProgressSub != null) {
        downloadProgressSub?.cancel();
      }

      //先判断这个文件在不在 icloud 上面
      final fileList = await ICloudStorage.gather(
        containerId: 'iCloud.top.achatbot.models',
        onUpdate: (stream) {
          filesUpdateSub = stream.listen((updatedFileList) {
            for (var file in updatedFileList) {
              print('-- ${file.relativePath}');
            }
          });
        },
      );
      if (fileList.where((element) => element.relativePath == 'allModels').isEmpty) {
        return _asyncReal(localAllModelBeanList, []);
      }

      //获取 icloud 上的数据
      await ICloudStorage.download(
        containerId: 'iCloud.top.achatbot.models',
        relativePath: 'allModels',
        destinationFilePath: localPath,
        onProgress: (stream) {
          downloadProgressSub = stream.listen(
            (progress) {},
            onDone: () {
              try {
                String json = File(localPath).readAsStringSync();

                if (json.isEmpty) {
                  return _asyncReal(localAllModelBeanList, []);
                }
                if (json == "{}") {
                  return _asyncReal(localAllModelBeanList, []);
                }
                List<AllModelBean> remoteModels = [];
                var decodeJson = jsonDecode(json);
                if (decodeJson is List) {
                  for (var item in decodeJson) {
                    remoteModels.add(AllModelBean.fromJson(item));
                  }
                }
                _asyncReal(localAllModelBeanList, remoteModels);
              } catch (e) {
                print(e);
              }
            },
            onError: (err) {
              if (err is PlatformException) {
                if (err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
                  print(
                      'Platform Exception: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app');
                } else if (err.code == PlatformExceptionCode.fileNotFound) {
                  print('File not found');
                } else {
                  print('Platform Exception: ${err.message}; Details: ${err.details}');
                }
              } else {
                print(err.toString());
              }
              downloadProgressSub?.cancel();
            },
            cancelOnError: true,
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  void _asyncReal(List<AllModelBean> localModels, List<AllModelBean> remoteModels) async {
    print("...local:${localModels.length} ..remote:${remoteModels.length}");
    //将 2 个 list 数据整合成 1 个 list，通过 apiKey 来区分唯一性，以 updateTime作为最新的数据
    List<AllModelBean> allModels = [];
    for (var localModel in localModels) {
      var remoteModel = remoteModels.firstWhere((element) => element.time == localModel.time, orElse: () => localModel);
      if (remoteModel.updateTime != null && localModel.updateTime != null) {
        if (remoteModel.updateTime! > localModel.updateTime!) {
          allModels.add(remoteModel);
        } else {
          allModels.add(localModel);
        }
      } else {
        allModels.add(localModel);
      }
    }

    //判断是否有新增的数据
    for (var remoteModel in remoteModels) {
      if (!allModels.any((element) => element.time == remoteModel.time)) {
        allModels.add(remoteModel);
      }
    }

    //循环查 allModels里有没有重复的apiKey，有的话就只保留一个
    for (var i = 0; i < allModels.length; i++) {
      for (var j = i + 1; j < allModels.length; j++) {
        if (allModels[i].apiKey == allModels[j].apiKey) {
          allModels.removeAt(j);
          j--;
        }
      }
    }

    //将数据存入 HiveBox
    for (var model in allModels) {
      if (HiveBox().openAIConfig.values.any((element) => element.time == model.time)) {
        await globalRef
            ?.read(openAiListProvider(APIType.fromCode(model.model ?? 1)).notifier)
            .update(model, needAsync: false, needReload: false);
      } else {
        await globalRef
            ?.read(openAiListProvider(APIType.fromCode(model.model ?? 1)).notifier)
            .add(model, needAsync: false, needReload: false);
      }
      await globalRef?.read(openAiListProvider(APIType.fromCode(model.model ?? 1)).notifier).load();
    }

    var localPath = "${(await getTemporaryDirectory()).path}/${DateTime.now().millisecondsSinceEpoch}";

    File file = File(localPath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    file.writeAsStringSync(jsonEncode(allModels));

    if (uploadProgressSub != null) {
      uploadProgressSub?.cancel();
    }
    try {
      await ICloudStorage.delete(
        containerId: 'iCloud.top.achatbot.models',
        relativePath: 'allModels',
      );
    } catch (e) {
      print(e);
    }
    //同步到云端
    await ICloudStorage.upload(
      filePath: localPath,
      containerId: 'iCloud.top.achatbot.models',
      destinationRelativePath: 'allModels',
      onProgress: (stream) {
        uploadProgressSub = stream.listen(
          (progress) {},
          onDone: () {
            uploadProgressSub?.cancel();
          },
          onError: (err) {
            if (err is PlatformException) {
              if (err.code == PlatformExceptionCode.iCloudConnectionOrPermission) {
                print(
                    'Platform Exception: iCloud container ID is not valid, or user is not signed in for iCloud, or user denied iCloud permission for this app');
              } else if (err.code == PlatformExceptionCode.fileNotFound) {
                print('File not found');
              } else {
                print('Platform Exception: ${err.message}; Details: ${err.details}');
              }
            } else {
              print(err.toString());
            }
            uploadProgressSub?.cancel();
          },
          cancelOnError: true,
        );
      },
    );
  }
}
