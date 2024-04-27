// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supported_models.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupportedModelsAdapter extends TypeAdapter<SupportedModels> {
  @override
  final int typeId = 6;

  @override
  SupportedModels read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupportedModels(
      id: fields[0] as String?,
      ownedBy: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupportedModels obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.ownedBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportedModelsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
