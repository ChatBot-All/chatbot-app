import 'dart:convert';

import 'package:ChatBot/base.dart';
import 'package:ChatBot/utils/hive_box.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../theme.dart';

const String tablePromptItem = 'prompt_item';
const String columnTime = 'time';
const String columnAuthor = 'author';
const String columnTitle = 'title';
const String columnPrompt = 'prompt';
const String columnHint = 'hint';
const String columnExtra = 'extra';

class PromptItem {
  String? author;
  String? title;
  String? prompt;
  String? hint;
  int? time;
  String? extra;

  PromptItem({
    this.author,
    this.title,
    this.prompt,
    this.hint,
    this.time,
    this.extra,
  });

  Map<String, Object?> toJson() {
    return {
      'author': author,
      'title': title,
      'prompt': prompt,
      'hint': hint,
      'time': time,
      'extra': extra,
    };
  }

  factory PromptItem.fromJson(Map<String, Object?> map) {
    return PromptItem(
      author: map['author'] as String?,
      title: map['title'] as String?,
      prompt: map['prompt'] as String?,
      hint: map['hint'] as String?,
      time: map['time'] as int?,
      extra: map['extra'] as String?,
    );
  }

  PromptItem copyWith({
    String? author,
    String? title,
    String? prompt,
    String? hint,
    int? time,
    String? extra,
  }) {
    return PromptItem(
      author: author ?? this.author,
      title: title ?? this.title,
      prompt: prompt ?? this.prompt,
      hint: hint ?? this.hint,
      time: time ?? this.time,
      extra: extra ?? this.extra,
    );
  }
}

class PromptItemProvider {
  //单例

  PromptItemProvider._();

  static PromptItemProvider? _instance;

  factory PromptItemProvider() {
    _instance ??= PromptItemProvider._();
    return _instance!;
  }

  Database? db;

  Future open() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'prompt_item.db');

    try {
      await Directory(databasesPath).create(recursive: true);
      db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
        await db.execute('''
create table $tablePromptItem ( 
        $columnTime integer primary key, 
        $columnAuthor text,
        $columnTitle text,
        $columnPrompt text,
        $columnHint text,
        $columnExtra text)
''');
      });
    } catch (e) {
      "Open DataBase failed:${e.toString()}".toast();
    }
  }

  Future<PromptItem> insert(PromptItem item) async {
    if (db == null) {
      await open();
    }
    item.time = await db!.insert(tablePromptItem, item.toJson());
    return item;
  }

  //update
  Future<int> update(PromptItem item) async {
    if (db == null) {
      await open();
    }
    return await db!.update(tablePromptItem, item.toJson(), where: '$columnTime = ?', whereArgs: [item.time]);
  }

  //list
  Future<List<PromptItem>> list() async {
    if (db == null) {
      await open();
    }
    List<Map<String, Object?>> maps = await db!.query(tablePromptItem,
        columns: [columnTime, columnAuthor, columnTitle, columnPrompt, columnHint, columnExtra]);
    var list = List.generate(maps.length, (i) {
      return PromptItem.fromJson(maps[i]);
    });

    //解析assets里的json文件

    var languageCode = getLocaleByDefaultCode().languageCode;

    String file = 'command.json';
    if (languageCode == SupportedLanguage.zh.code) {
      file = 'command.json';
    } else if (languageCode == SupportedLanguage.en.code) {
      file = 'command_en.json';
    } else if (languageCode == SupportedLanguage.ja.code) {
      file = 'command_ja.json';
    } else if (languageCode == SupportedLanguage.ko.code) {
      file = 'command_ko.json';
    }

    var json = await rootBundle.loadString('assets/$file');
    var defaultPrompt = (jsonDecode(json) as List)
        .map((e) => PromptItem(
              title: e["title"],
              prompt: e["content"],
              time: 0,
            ))
        .toList();

    list.addAll(defaultPrompt);

    return list;
  }

  //delete
  Future<int> delete(int time) async {
    if (db == null) {
      await open();
    }
    return await db!.delete(tablePromptItem, where: '$columnTime = ?', whereArgs: [time]);
  }

  //delete all
  Future<int> deleteAll() async {
    if (db == null) {
      await open();
    }
    return await db!.delete(tablePromptItem);
  }

  Future close() async {
    if (db == null) {
      await open();
    }
    db!.close();
  }
}
