import 'package:ChatBot/base.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const String tableChatItem = 'chat_item';
const String columnTime = 'time';
const String columnContent = 'content';
const String columnType = 'type';
const String columnImages = 'images';
const String columnModuleName = 'module_name';
const String columnModuleType = 'module_type';
const String columnMessageType = 'message_type';
const String columnStatus = 'status';
const String columnRequestID = 'request_id';
const String columnParentID = 'parent_id';
const String columnExtra = 'extra';

class ChatItem {
  String? content; //markdown内容
  int? time; //时间戳
  List<String>? images; // 发送的图片
  int? type; // 0: user, 1: bot
  int? moduleName; //使用的模型
  String? moduleType; //模型类型
  int? status; //0加载中， 1.成功，2失败，3手动取消
  int? requestID; //当用户类型为bot时，这个id代表的是上一条用户发送的id，所有id均为time
  int? parentID; //chatHistory的id
  int? messageType; //1.正常的消息，2 图片生成
  String? extra;

  ChatItem(
      {this.content,
      this.time,
      this.extra,
      this.type,
      this.moduleType,
      this.moduleName,
      this.requestID,
      this.messageType,
      this.images,
      this.parentID,
      this.status});

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnContent: content,
      columnTime: time,
      columnType: type,
      columnImages: images?.join(","),
      columnModuleName: moduleName,
      columnMessageType: messageType,
      columnModuleType: moduleType,
      columnStatus: status,
      columnRequestID: requestID,
      columnParentID: parentID,
      columnExtra: extra,
    };
    return map;
  }

  ChatItem.fromMap(Map<String, Object?> map) {
    content = map[columnContent] as String?;
    time = map[columnTime] as int?;
    type = map[columnType] as int?;
    images = (map[columnImages] as String?)?.split(",");
    moduleName = map[columnModuleName] as int?;
    moduleType = map[columnModuleType] as String?;
    messageType = map[columnMessageType] as int?;
    status = map[columnStatus] as int?;
    requestID = map[columnRequestID] as int?;
    messageType = map[columnMessageType] as int?;
    parentID = map[columnParentID] as int?;
    extra = map[columnExtra] as String?;
  }

  ChatItem copyWidth(
      {String? content,
      int? time,
      List<String>? images,
      int? type,
      int? moduleName,
      String? moduleType,
      int? messageType,
      int? status,
      int? requestID,
      int? parentID,
      String? extra}) {
    return ChatItem(
        content: content ?? this.content,
        time: time ?? this.time,
        images: images ?? this.images,
        type: type ?? this.type,
        moduleName: moduleName ?? this.moduleName,
        moduleType: moduleType ?? this.moduleType,
        messageType: messageType ?? this.messageType,
        status: status ?? this.status,
        requestID: requestID ?? this.requestID,
        parentID: parentID ?? this.parentID,
        extra: extra ?? this.extra);
  }
}

enum ChatType {
  user(0),
  bot(1),
  system(2);

  final int code;

  const ChatType(this.code);
}

enum MessageType {
  common,
  image,
}

enum MessageStatus {
  loading,
  success,
  failed,
  canceled,
}

class ChatItemProvider {
  //单例

  ChatItemProvider._();

  static ChatItemProvider? _instance;

  factory ChatItemProvider() {
    _instance ??= ChatItemProvider._();
    return _instance!;
  }

  Database? db;

  Future open() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, 'chat_item.db');

    try {
      await Directory(databasesPath).create(recursive: true);
      db = await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
        await db.execute('''
create table $tableChatItem ( 
  $columnTime integer primary key, 
  $columnContent text,
  $columnType integer,
  $columnImages text,
  $columnModuleName integer,
  $columnModuleType text,
  $columnMessageType integer,
  $columnStatus integer,
  $columnRequestID integer,
  $columnParentID integer,
  $columnExtra text)
''');
      });
    } catch (e) {
      "Open DataBase failed:${e.toString()}".toast();
    }
  }

  Future<ChatItem> insert(ChatItem item) async {
    if (db == null) {
      await open();
    }
    item.time = await db!.insert(tableChatItem, item.toMap());
    return item;
  }

  //获取最新的一条chatitem，根据parentID
  Future<ChatItem?> getLatestChatItem(int parentID) async {
    if (db == null) {
      await open();
    }
    List<Map<String, Object?>> maps = await db!.query(tableChatItem,
        columns: [
          columnContent,
          columnImages,
          columnModuleName,
          columnModuleType,
          columnParentID,
          columnRequestID,
          columnStatus,
          columnMessageType,
          columnTime,
          columnType,
          columnExtra
        ],
        where: '$columnParentID = ?',
        whereArgs: [parentID],
        orderBy: '$columnTime DESC',
        limit: 1);
    if (maps.isNotEmpty) {
      return ChatItem.fromMap(maps.first);
    }
    return null;
  }

  Future<List<ChatItem>> getChatItems(int parentID) async {
    if (db == null) {
      await open();
    }
    List<Map<String, Object?>> maps = await db!.query(tableChatItem,
        columns: [
          columnContent,
          columnImages,
          columnModuleName,
          columnModuleType,
          columnMessageType,
          columnParentID,
          columnRequestID,
          columnStatus,
          columnTime,
          columnType,
          columnExtra
        ],
        where: '$columnParentID = ?',
        whereArgs: [parentID]);
    if (maps.isNotEmpty) {
      return maps.map((e) => ChatItem.fromMap(e)).toList();
    }
    return [];
  }

  Future<ChatItem?> getChatItem(int time) async {
    if (db == null) {
      await open();
    }
    List<Map<String, Object?>> maps = await db!.query(tableChatItem,
        columns: [
          columnContent,
          columnImages,
          columnModuleName,
          columnModuleType,
          columnParentID,
          columnRequestID,
          columnStatus,
          columnTime,
          columnMessageType,
          columnType,
          columnTime,
          columnExtra
        ],
        where: '$columnTime = ?',
        whereArgs: [time]);
    if (maps.isNotEmpty) {
      return ChatItem.fromMap(maps.first);
    }
    return null;
  }

  //查询所有parentID的数据，然后全部删除
  Future<int> deleteAll(int parentID) async {
    if (db == null) {
      await open();
    }
    return await db!.delete(tableChatItem, where: '$columnParentID = ?', whereArgs: [parentID]);
  }

  Future<int> delete(int time) async {
    if (db == null) {
      await open();
    }
    return await db!.delete(tableChatItem, where: '$columnTime = ?', whereArgs: [time]);
  }

  //通过requestID， 查询到对应的time，然后删除
  Future<int> deleteRequestIDByTime(int time) async {
    if (db == null) {
      await open();
    }
    return await db!.delete(tableChatItem, where: '$columnRequestID = ?', whereArgs: [time]);
  }

  Future<int> update(ChatItem item) async {
    if (db == null) {
      await open();
    }

    return await db!.update(tableChatItem, item.toMap(), where: '$columnTime = ?', whereArgs: [item.time]);
  }

  Future close() async {
    if (db == null) {
      await open();
    }
    db!.close();
  }

  void updateStatus(int parentID, int i, int j) {
    if (db == null) {
      open();
    }
    db!.update(tableChatItem, {columnStatus: j},
        where: '$columnParentID = ? and $columnStatus = ?', whereArgs: [parentID, i]);
  }
}
