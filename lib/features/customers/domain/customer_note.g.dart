// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerNoteAdapter extends TypeAdapter<CustomerNote> {
  @override
  final int typeId = 2;

  @override
  CustomerNote read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerNote(
      id: fields[0] as String,
      customerId: fields[1] as String,
      text: fields[2] as String,
      createdAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerNote obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerNoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
