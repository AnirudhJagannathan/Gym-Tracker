import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/workout.dart';
import '../models/exercise_def.dart';
import '../utils/analytics.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

enum _MuscleView { bar, heatmap }

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  _MuscleView _muscleView = _MuscleView.bar;
  String? _selectedExercise; // persisted within tab for nicer UX

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final workoutBox = Hive.box<Workout>('workouts');
    final defBox = Hive.box<ExerciseDef>('exercise_defs');

    final workouts = workoutBox.values.toList();
    final defs = defBox.values.toList();

    final perExercise = AnalyticsEngine.perExerciseProgression(workouts, defs);
    final perMuscle = AnalyticsEngine.perMuscleVolume(workouts, defs);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hero Analytics"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Exercises"),
            Tab(text: "Muscles"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildExerciseProgressionTab(perExercise),
          _buildMuscleTab(perMuscle),
        ],
      ),
    );
  }

  // ---------------- EXERCISES TAB ----------------

  Widget _buildExerciseProgressionTab(
    Map<String, List<Map<String, dynamic>>> data,
  ) {
    if (data.isEmpty) {
      return const Center(child: Text("No exercise data yet."));
    }

    final names = data.keys.toList()..sort();
    _selectedExercise ??= names.first;

    // prepare sorted entries (by date)
    final entries = [...data[_selectedExercise] ?? []]
      ..sort((a, b) => (a["date"] as DateTime).compareTo(b["date"] as DateTime));

    // x values need to be small; we transform dates into indices for stable spacing
    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      final est1rm = (entries[i]["est1RM"] as num).toDouble();
      spots.add(FlSpot(i.toDouble(), est1rm));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: DropdownButton<String>(
            isExpanded: true,
            value: _selectedExercise,
            items: names
                .map((n) => DropdownMenuItem<String>(
                      value: n,
                      child: Text(n),
                    ))
                .toList(),
            onChanged: (val) => setState(() => _selectedExercise = val),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: spots.isEmpty
                ? const Center(child: Text("No logged sets for this exercise yet."))
                : LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (spots.length - 1).clamp(0, double.infinity).toDouble(),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, m) =>
                                Text(v.toStringAsFixed(0)),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (spots.length / 4).clamp(1, 4).toDouble(),
                            getTitlesWidget: (v, m) =>
                                Text("W${(v + 1).toInt()}"),
                          ),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          dotData: FlDotData(show: true),
                          color: Colors.red,
                          barWidth: 3,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ---------------- MUSCLES TAB ----------------

  Widget _buildMuscleTab(Map<String, double> data) {
    if (data.isEmpty) {
      return const Center(child: Text("No muscle data yet."));
    }

    final normalized = _normalize(data);
    final muscles = normalized.keys.toList()
      ..sort((a, b) => normalized[b]!.compareTo(normalized[a]!));
    final volumes = muscles.map((m) => data[m] ?? 0).toList();

    return Column(
      children: [
        // Toggle: Bar <-> Heatmap
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<_MuscleView>(
            segments: const [
              ButtonSegment(
                value: _MuscleView.bar,
                label: Text("Bar"),
                icon: Icon(Icons.bar_chart),
              ),
              ButtonSegment(
                value: _MuscleView.heatmap,
                label: Text("Heatmap"),
                icon: Icon(Icons.grid_view),
              ),
            ],
            selected: {_muscleView},
            onSelectionChanged: (s) =>
                setState(() => _muscleView = s.first),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _muscleView == _MuscleView.bar
                ? _buildMuscleBarChart(muscles, volumes)
                : _buildMuscleHeatGrid(muscles, normalized),
          ),
        ),
      ],
    );
  }

  Widget _buildMuscleBarChart(List<String> muscles, List<double> volumes) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= muscles.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    muscles[i],
                    style: const TextStyle(fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(
          muscles.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: volumes[i],
                color: Colors.yellow[700],
                width: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMuscleHeatGrid(
    List<String> muscles,
    Map<String, double> normalized, // 0.0..1.0
  ) {
    // grid of “muscle tiles” with intensity color; sorted by volume desc
    return GridView.builder(
      itemCount: muscles.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // simple responsive grid
        childAspectRatio: 3.4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, i) {
        final m = muscles[i];
        final t = normalized[m] ?? 0.0; // normalized 0..1
        final color = Color.lerp(Colors.yellow.shade200, Colors.red, t)!;

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 8,
                color: Color(0x22000000),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  m,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${(t * 100).round()}%",
                  style: const TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------- helpers -------------

  Map<String, double> _normalize(Map<String, double> raw) {
    if (raw.isEmpty) return {};
    final maxVal = raw.values.fold<double>(0, (m, v) => v > m ? v : m);
    if (maxVal <= 0) {
      // avoid division by zero; all zeros -> return zeros
      return raw.map((k, v) => MapEntry(k, 0));
    }
    return raw.map((k, v) => MapEntry(k, (v / maxVal).clamp(0.0, 1.0)));
  }
}
