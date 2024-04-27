// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_chat_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatParentItemAdapter extends TypeAdapter<ChatParentItem> {
  @override
  final int typeId = 0;

  @override
  ChatParentItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatParentItem(
      moduleType: fields[3] as String?,
      id: fields[0] as int?,
      moduleName: fields[2] as int?,
      pin: fields[9] as bool?,
      title: fields[1] as String?,
      apiKey: fields[6] as String?,
      temperature: fields[7] as String?,
      historyMessageCount: fields[8] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ChatParentItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(3)
      ..write(obj.moduleType)
      ..writeByte(2)
      ..write(obj.moduleName)
      ..writeByte(6)
      ..write(obj.apiKey)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(7)
      ..write(obj.temperature)
      ..writeByte(8)
      ..write(obj.historyMessageCount)
      ..writeByte(9)
      ..write(obj.pin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatParentItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
