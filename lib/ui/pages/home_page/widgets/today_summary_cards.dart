import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/exercise_muscle.dart';
import 'package:your_reps/data/objects/muscle.dart';
import 'package:your_reps/data/objects/rep.dart';
import 'package:your_reps/data/objects/set.dart' as exercise_set;

class TodaySummaryWidget extends StatelessWidget {
  final List logs;
  final List<exercise_set.WorkoutSet> sets;
  final List<Rep> reps;
  final List<Exercise> exercises;
  final List<ExerciseMuscle> exerciseMuscles;
  final List<Muscle> muscles;

  const TodaySummaryWidget({
    super.key,
    required this.logs,
    required this.sets,
    required this.reps,
    required this.exercises,
    required this.exerciseMuscles,
    required this.muscles,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayLogs = logs.where((l) => DateUtils.isSameDay(l.date, today)).toList();

    if (todayLogs.isEmpty) return const SizedBox.shrink();

    final todaySetList = sets.where((s) => todayLogs.any((l) => l.id == s.exerciseLogId)).toList();

    double totalWeightMoved = 0;
    final muscleCounts = <String, int>{};
    final pushPullCounts = {'Push': 0, 'Pull': 0, 'Neutral': 0};

    for (var set in todaySetList) {
      final rep = reps.firstWhereOrNull((r) => r.setId == set.id);
      if (rep != null) {
        totalWeightMoved += set.weight * rep.count;
      }

      final log = todayLogs.firstWhere((l) => l.id == set.exerciseLogId);
      final exercise = exercises.firstWhereOrNull((e) => e.id == log.exerciseId);
      final em = exerciseMuscles.where((em) => em.exerciseId == exercise!.id).map((em) => em.muscleId).toList();

      for (var mId in em) {
        final m = muscles.firstWhereOrNull((muscle) => muscle.id == mId);
        if (m != null) {
          muscleCounts[m.location] = (muscleCounts[m.location] ?? 0) + 1;
          pushPullCounts[m.pushPull] = (pushPullCounts[m.pushPull] ?? 0) + 1;
        }
      }
    }

    final sortedMuscles = muscleCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final focus = sortedMuscles.map((e) => e.key).join(', ');
    final pushPullSummary = pushPullCounts.entries.where((e) => e.value > 0).map((e) => e.key).join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(
            "Today's Summary",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            final cardWidth = isWide ? (constraints.maxWidth - 48) / 3 : constraints.maxWidth;

            final children = [
              _buildMetricCard(
                title: "Focus Area",
                value: focus.isNotEmpty ? focus : 'Mixed',
                icon: Icons.fitness_center,
                width: cardWidth,
                context: context,
              ),
              _buildMetricCard(
                title: "Weight Moved",
                value: "${totalWeightMoved.toStringAsFixed(1)} kg",
                icon: Icons.scale,
                width: cardWidth,
                context: context,
              ),
              if (pushPullSummary.isNotEmpty)
                _buildMetricCard(
                  title: "Push/Pull",
                  value: pushPullSummary,
                  icon: Icons.compare_arrows,
                  width: cardWidth,
                  context: context,
                ),
            ];

            return Align(
              alignment: isWide ? Alignment.center : Alignment.centerLeft,
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                children: children,
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required double width,
    required BuildContext context,
  }) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
