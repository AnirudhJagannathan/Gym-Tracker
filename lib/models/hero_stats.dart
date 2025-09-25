import 'package:hive/hive.dart';
import '../models/workout.dart';
import '../models/exercise_def.dart';
import '../utils/analytics.dart';

part 'hero_stats.g.dart';

@HiveType(typeId: 5)
class HeroStats extends HiveObject {
  @HiveField(0)
  int xp;

  HeroStats({this.xp = 0});

  String get rank {
    if (xp >= 15000) return "S-Class";
    if (xp >= 5000) return "A-Class";
    if (xp >= 1000) return "B-Class";
    return "C-Class";
  }

  double get progressToNext {
    if (xp >= 15000) return 1.0;
    if (xp >= 5000) return (xp - 5000) / (15000 - 5000);
    if (xp >= 1000) return (xp - 1000) / (5000 - 1000);
    return xp / 1000;
  }
}
