import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/workout.dart';
import '../models/hero_stats.dart';
import 'package:confetti/confetti.dart';

class WorkoutScreen extends StatefulWidget {
  final Workout? existingWorkout;

  const WorkoutScreen({super.key, this.existingWorkout});

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
  List<Exercise> _exercises = [];

  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();

    if (widget.existingWorkout != null) {
      _selectedDay = widget.existingWorkout!.dayType;
      _exercises = List<Exercise>.from(widget.existingWorkout!.exercises);
    }

    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _addExercise() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Exercise"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Exercise name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _exercises.add(Exercise(name: controller.text, sets: []));
                });
                Navigator.pop(context, true);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _addSet(int index) async {
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Set"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Reps"),
            ),
            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Weight (lbs)"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text);
              final weight = double.tryParse(weightController.text);
              if (reps != null && weight != null) {
                setState(() {
                  _exercises[index].sets.add(SetEntry(reps: reps, weight: weight));
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
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text("Hero Training Log")),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Workout Type:", style: TextStyle(fontSize: 16)),
                Wrap(
                  spacing: 8,
                  children: _dayTypes.map((day) {
                    return ChoiceChip(
                      label: Text(day),
                      selected: _selectedDay == day,
                      selectedColor: Colors.red,
                      onSelected: (_) {
                        setState(() => _selectedDay = day);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                ElevatedButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Exercise"),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: _exercises.isEmpty
                      ? const Center(
                          child: Text("No exercises yet. Tap + to add one."),
                        )
                      : ListView.builder(
                          itemCount: _exercises.length,
                          itemBuilder: (context, index) {
                            final exercise = _exercises[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          exercise.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          onPressed: () {
                                            setState(() => _exercises.removeAt(index));
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text("Exercise deleted")),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                    const Divider(),
                                    if (exercise.sets.isEmpty)
                                      const Text("No sets yet")
                                    else
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: exercise.sets
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          final i = entry.key;
                                          final set = entry.value;
                                          return Chip(
                                            label: Text("${set.reps} × ${set.weight} lbs"),
                                            onDeleted: () {
                                              setState(() => exercise.sets.removeAt(i));
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Set deleted")),
                                              );
                                            },
                                          );
                                        }).toList(),
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
            backgroundColor: Colors.red,
            icon: const Icon(Icons.save),
            label: const Text("💥 Save Training"),
            onPressed: () async {
              if (widget.existingWorkout == null) {
                // NEW workout
                final workout = Workout(
                  dayType: _selectedDay,
                  date: DateTime.now(),
                  exercises: List<Exercise>.from(_exercises),
                );
                final box = Hive.box<Workout>('workouts');
                await box.add(workout);
              } else {
                // EDIT existing workout
                widget.existingWorkout!.dayType = _selectedDay;
                widget.existingWorkout!.exercises = List<Exercise>.from(_exercises);
                await widget.existingWorkout!.save();
              }

              // 👇 Award XP
              final heroBox = Hive.box<HeroStats>('hero_stats');
              final hero = heroBox.getAt(0)!;

              final prevRank = hero.rank;
              int gainedXP = 0;

              for (final ex in _exercises) {
                for (final set in ex.sets) {
                  gainedXP += (set.reps * set.weight ~/ 100);
                }
              }

              hero.xp += gainedXP;
              await hero.save();

              final newRank = hero.rank;

              if (context.mounted) {
                Navigator.pop(context);

                String message;
                if (newRank != prevRank) {
                  message =
                      "Workout saved! +$gainedXP XP earned 🎉 PROMOTED to $newRank!";
                  _confettiController.play(); // 🎉 trigger confetti
                } else {
                  message = "Workout saved! +$gainedXP XP earned";
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
          ),
        ),

        // 🎉 Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: [Colors.red, Colors.yellow, Colors.black],
            gravity: 0.4,
          ),
        ),
      ],
    );
  }
}
