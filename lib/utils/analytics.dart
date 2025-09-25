import 'package:hive/hive.dart';
import '../models/workout.dart';
import '../models/exercise_def.dart';

class AnalyticsEngine {
  /// Calculate per-exercise progression (best set, estimated 1RM)
  static Map<String, List<Map<String, dynamic>>> perExerciseProgression(
      List<Workout> workouts, List<ExerciseDef> defs) {
    final Map<String, List<Map<String, dynamic>>> progression = {};

    for (final workout in workouts) {
      for (final ex in workout.exercises) {
        // Find matching definition
        final def = defs.firstWhere(
          (d) => d.name.toLowerCase() == ex.name.toLowerCase(),
          orElse: () => ExerciseDef(name: ex.name, muscles: [], weights: []),
        );

        for (final set in ex.sets) {
          final est1RM = set.weight * (1 + set.reps / 30.0);
          final entry = {
            "date": workout.date,
            "reps": set.reps,
            "weight": set.weight,
            "est1RM": est1RM,
          };

          progression.putIfAbsent(def.name, () => []);
          progression[def.name]!.add(entry);
        }
      }
    }

    return progression;
  }

  /// Calculate per-muscle volume (reps × weight × muscle weighting)
  static Map<String, double> perMuscleVolume(
      List<Workout> workouts, List<ExerciseDef> defs) {
    final Map<String, double> volumeByMuscle = {};

    for (final workout in workouts) {
      for (final ex in workout.exercises) {
        // Try to match this exercise with a seeded definition
        final def = defs.firstWhere(
          (d) => d.name.toLowerCase() == ex.name.toLowerCase(),
          orElse: () => ExerciseDef(name: ex.name, muscles: [], weights: []),
        );

        for (final set in ex.sets) {
          final setVolume = set.reps * set.weight;
          for (int i = 0; i < def.muscles.length; i++) {
            final muscle = def.muscles[i];
            final factor = def.weights[i];
            volumeByMuscle[muscle] = (volumeByMuscle[muscle] ?? 0) + setVolume * factor;
          }
        }
      }
    }

    return volumeByMuscle;
  }
}
