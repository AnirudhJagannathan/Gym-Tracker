import 'package:hive/hive.dart';

part 'workout.g.dart'; // generated file

@HiveType(typeId: 0)
class Workout extends HiveObject {
  @HiveField(0)
  String dayType;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  List<Exercise> exercises;

  Workout({
    required this.dayType,
    required this.date,
    required this.exercises,
  });
}

@HiveType(typeId: 1)
class Exercise extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<SetEntry> sets; // 👈 now a list of SetEntry objects

  Exercise({required this.name, required this.sets});
}

@HiveType(typeId: 2)
class SetEntry extends HiveObject {
  @HiveField(0)
  int reps;

  @HiveField(1)
  double weight; // in kg or lbs

  SetEntry({required this.reps, required this.weight});
}

