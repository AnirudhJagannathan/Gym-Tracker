import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/hero_stats.dart';
import 'workout_screen.dart';
import 'history_screen.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final heroBox = Hive.box<HeroStats>('hero_stats');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hero Dashboard"),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: heroBox.listenable(),
        builder: (context, Box<HeroStats> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No hero stats found."));
          }

          final hero = box.getAt(0)!;

          // XP thresholds
          final thresholds = {
            "C-Class": 0,
            "B-Class": 500,
            "A-Class": 1500,
            "S-Class": 4000,
          };

          final ranks = thresholds.keys.toList();
          final nextRankIndex = ranks.indexOf(hero.rank) + 1;
          final nextRank =
              nextRankIndex < ranks.length ? ranks[nextRankIndex] : null;
          final nextThreshold =
              nextRank != null ? thresholds[nextRank]! : hero.xp;
          final currentThreshold = thresholds[hero.rank] ?? 0;

          final progress = ((hero.xp - currentThreshold) /
                  (nextThreshold - currentThreshold))
              .clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Hero Rank + XP Ring
                Expanded(
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 800),
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 14,
                                backgroundColor: Colors.grey.shade800,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(
                                        Colors.red),
                              );
                            },
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              hero.rank,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: hero.xp),
                              duration: const Duration(milliseconds: 800),
                              builder: (context, value, child) {
                                return Text(
                                  "$value XP",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                            if (nextRank != null)
                              Text(
                                "Next: $nextRank",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                const Text(
                  "Push Beyond Your Limits 💥",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionCard(
                      context,
                      icon: Icons.fitness_center,
                      label: "Start Workout",
                      color: Colors.red,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WorkoutScreen()),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.history,
                      label: "History",
                      color: Colors.yellow[700]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryScreen()),
                        );
                      },
                    ),
                    _buildActionCard(
                      context,
                      icon: Icons.insights,
                      label: "Analytics",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AnalyticsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 100,
          height: 110,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
