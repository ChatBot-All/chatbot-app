// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_bean.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AllModelBeanAdapter extends TypeAdapter<AllModelBean> {
  @override
  final int typeId = 3;

  @override
  AllModelBean read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AllModelBean(
      apiKey: fields[0] as String?,
      model: fields[1] as int?,
      apiServer: fields[2] as String?,
      defaultModelType: fields[7] as SupportedModels?,
      organization: fields[3] as String?,
      alias: fields[4] as String?,
      supportedModels: (fields[6] as List?)?.cast<SupportedModels>(),
      time: fields[5] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, AllModelBean obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.apiKey)
      ..writeByte(1)
      ..write(obj.model)
      ..writeByte(2)
      ..write(obj.apiServer)
      ..writeByte(3)
      ..write(obj.organization)
      ..writeByte(4)
      ..write(obj.alias)
      ..writeByte(7)
      ..write(obj.defaultModelType)
      ..writeByte(5)
      ..write(obj.time)
      ..writeByte(6)
      ..write(obj.supportedModels);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AllModelBeanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
