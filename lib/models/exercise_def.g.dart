// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_def.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseDefAdapter extends TypeAdapter<ExerciseDef> {
  @override
  final int typeId = 4;

  @override
  ExerciseDef read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseDef(
      name: fields[0] as String,
      muscles: (fields[1] as List).cast<String>(),
      weights: (fields[2] as List).cast<double>(),
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseDef obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.muscles)
      ..writeByte(2)
      ..write(obj.weights);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseDefAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
