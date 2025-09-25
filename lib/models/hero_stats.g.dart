// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hero_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HeroStatsAdapter extends TypeAdapter<HeroStats> {
  @override
  final int typeId = 5;

  @override
  HeroStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HeroStats(
      xp: fields[0] as int,
    );
  }

  @override
  void write(BinaryWriter writer, HeroStats obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.xp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeroStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
