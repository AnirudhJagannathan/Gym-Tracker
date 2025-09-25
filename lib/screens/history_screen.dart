import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import 'workout_detail_screen.dart';
import '../models/hero_stats.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Workout>('workouts');

    return Scaffold(
      appBar: AppBar(title: const Text("Hero Training Logbook")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Workout> workouts, _) {
          if (workouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.fitness_center, size: 72, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No workouts logged yet.\nTap 'Start Workout' to begin training!",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts.getAt(index)!;

              return Dismissible(
                key: Key(workout.key.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white, size: 28),
                ),
                onDismissed: (_) async {
                  await workouts.deleteAt(index);

                  // 👇 Recompute hero XP from scratch
                  final heroBox = Hive.box<HeroStats>('hero_stats');
                  final hero = heroBox.getAt(0)!;

                  int totalXP = 0;
                  for (final w in workouts.values) {
                    for (final ex in w.exercises) {
                      for (final set in ex.sets) {
                        totalXP += (set.reps * set.weight ~/ 100);
                      }
                    }
                  }

                  hero.xp = totalXP;
                  await hero.save();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Deleted ${workout.dayType} workout")),
                  );
                },
                child: Card(
                  elevation: 6,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      "💪 ${workout.dayType}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "Date: ${workout.date.toLocal().toString().split(' ')[0]}",
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          "${workout.exercises.length} exercises, "
                          "${workout.exercises.fold(0, (sum, ex) => sum + ex.sets.length)} sets",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(workout: workout),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}