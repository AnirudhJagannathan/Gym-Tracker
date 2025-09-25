import 'package:hive/hive.dart';

part 'exercise_def.g.dart';

@HiveType(typeId: 4)
class ExerciseDef extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<String> muscles; // e.g. ["Chest", "Triceps", "Front Delts"]

  @HiveField(2)
  List<double> weights; // e.g. [0.6, 0.15, 0.25]

  ExerciseDef({
    required this.name,
    required this.muscles,
    required this.weights,
  });
}
