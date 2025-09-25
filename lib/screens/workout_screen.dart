import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/workout.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<String> _dayTypes = [
    "Chest/Back",
    "Shoulders/Arms",
    "Legs",
    "Custom"
  ];
  String _selectedDay = "Chest/Back";
  final List<Map<String, dynamic>> _exercises = [];

  void _addExercise() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Exercise"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Exercise name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _exercises.add({"name": controller.text, "sets": <int>[]});
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addSet(int index) async {
    final repsController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Set"),
        content: TextField(
          controller: repsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Reps"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text);
              if (reps != null && reps > 0) {
                setState(() {
                  _exercises[index]["sets"].add(reps);
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Workout")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Workout Type:", style: TextStyle(fontSize: 16)),
            DropdownButton<String>(
              value: _selectedDay,
              items: _dayTypes.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
              onChanged: (val) => setState(() => _selectedDay = val!),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: _addExercise, icon: const Icon(Icons.add), label: const Text("Add Exercise")),
            const SizedBox(height: 20),
            Expanded(
              child: _exercises.isEmpty
                  ? const Center(child: Text("No exercises yet"))
                  : ListView.builder(
                      itemCount: _exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _exercises[index];
                        final sets = exercise["sets"] as List<int>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exercise["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                if (sets.isEmpty)
                                  const Text("No sets yet")
                                else
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(
                                      sets.length,
                                      (i) => Text("Set ${i + 1}: ${sets[i]} reps"),
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _addSet(index),
                                  icon: const Icon(Icons.add),
                                  label: const Text("Add Set"),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final workout = Workout(
            dayType: _selectedDay,
            date: DateTime.now(),
            exercises: _exercises
                .map((e) => Exercise(name: e["name"], sets: List<int>.from(e["sets"])))
                .toList(),
          );
          final box = Hive.box<Workout>('workouts');
          await box.add(workout);
          Navigator.pop(context);
        },
        icon: const Icon(Icons.save),
        label: const Text("Save Workout"),
      ),
    );
  }
}
