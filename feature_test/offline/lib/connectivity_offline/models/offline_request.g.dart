// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_request.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineRequestAdapter extends TypeAdapter<OfflineRequest> {
  @override
  final int typeId = 3;

  @override
  OfflineRequest read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineRequest(
      id: fields[0] as String,
      method: fields[1] as String,
      url: fields[2] as String,
      headers: (fields[3] as Map?)?.cast<String, String>(),
      body: fields[4] as dynamic,
      createdAt: fields[5] as DateTime,
      retryCount: fields[6] as int,
      lastAttemptAt: fields[7] as DateTime?,
      priority: RequestPriority.values[fields[8] as int],
      lastError: fields[9] as String?,
      metadata: (fields[10] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, OfflineRequest obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.method)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.headers)
      ..writeByte(4)
      ..write(obj.body)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.retryCount)
      ..writeByte(7)
      ..write(obj.lastAttemptAt)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.lastError)
      ..writeByte(10)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineRequestAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
