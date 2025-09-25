import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/workout.dart';
import 'workout_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Workout>('workouts');

    return Scaffold(
      appBar: AppBar(title: const Text("Workout History")),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Workout> workouts, _) {
          if (workouts.isEmpty) {
            return const Center(child: Text("No workouts yet"));
          }

          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts.getAt(index)!;
              return Dismissible(
                key: Key(workout.key.toString()), // unique Hive key
                direction: DismissDirection.endToStart, // swipe right → left
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  workouts.deleteAt(index); // remove from Hive
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Deleted ${workout.dayType} workout")),
                  );
                },
                child: ListTile(
                  title: Text(
                    "${workout.dayType} - ${workout.date.toLocal().toString().split(' ')[0]}",
                  ),
                  subtitle: Text(
                    "${workout.exercises.length} exercises, "
                    "${workout.exercises.fold(0, (sum, ex) => sum + ex.sets.length)} sets",
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WorkoutDetailScreen(workout: workout),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
