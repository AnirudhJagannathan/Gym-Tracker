import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/workout.dart';
import 'models/exercise_def.dart';  
import 'models/hero_stats.dart';
import 'data/exercise_seeds.dart';
import 'screens/home_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(WorkoutAdapter());
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(SetEntryAdapter());
  Hive.registerAdapter(ExerciseDefAdapter()); 
  Hive.registerAdapter(HeroStatsAdapter());

  // Open boxes
  await Hive.openBox<Workout>('workouts');
  await Hive.openBox<ExerciseDef>('exercise_defs'); 
  await Hive.openBox<HeroStats>('hero_stats');

  // Seed exercise definitions if empty
  final defBox = Hive.box<ExerciseDef>('exercise_defs');
  if (defBox.isEmpty) {
    for (final ex in seedExercises) {
      await defBox.add(ex);
    }
  }

  final heroBox = Hive.box<HeroStats>('hero_stats');
  if (heroBox.isEmpty) {
    await heroBox.add(HeroStats(xp: 0));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
