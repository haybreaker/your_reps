import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/muscle.dart';
import 'package:your_reps/data/objects/rep.dart';
import 'package:your_reps/data/objects/set.dart' as exercise_set;
import 'package:your_reps/data/providers/app_settings_provider.dart';
import 'package:your_reps/data/providers/unified_provider.dart';
import 'package:your_reps/ui/dialogs/exercise_dialog.dart';
import 'package:your_reps/ui/dialogs/workout_set_dialog.dart';

class ExercisePage extends StatefulWidget {
  final int exerciseId; // Change to ID instead of Exercise object
  const ExercisePage({required this.exerciseId, super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _expandedDay;
  final TextEditingController _repController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _addSet(Exercise exercise) {
    if (_repController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      setState(() {
        context.read<UnifiedProvider>().recordSet(
              exercise,
              double.parse(_weightController.text),
              int.parse(_repController.text),
            );
        _repController.clear();
      });
    }
  }

  Future<void> editExercise(Exercise exercise, List<Muscle> musclesForExercise) async {
    showDialog(
        context: context,
        builder: (context) => ExerciseDialog(
            exercise: exercise,
            muscles: musclesForExercise,
            onComplete: (updatedExercise, muscles) async {
              if (mounted) {
                // Update both exercise and muscles
                await context.read<UnifiedProvider>().updateExercise(updatedExercise);
                await context.read<UnifiedProvider>().updateExerciseMuscles(updatedExercise, muscles);

                // Force a rebuild by calling setState
                setState(() {});
              }
            }));
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final provider = context.read<UnifiedProvider>();
    provider.fetchMuscles();
    provider.fetchExerciseMuscles();
    provider.fetchExerciseLogs();
    provider.fetchSets();
    provider.fetchReps();
    provider.fetchExercises(); // Make sure exercises are loaded
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<UnifiedProvider>();

    // Get the current exercise by ID (this will reflect any updates)
    final exercise = provider.exercises.firstWhereOrNull((e) => e.id == widget.exerciseId);

    // If exercise is not found, show error
    if (exercise == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Exercise Not Found')),
        body: const Center(child: Text('Exercise not found')),
      );
    }

    final muscles = provider.muscles;
    final exerciseMuscles = provider.exerciseMuscles;
    final exerciseLogs = provider.exerciseLogs.where((el) => el.exerciseId == exercise.id).toList();
    final sets = provider.sets.where((s) => exerciseLogs.map((el) => el.id).contains(s.exerciseLogId)).toList();
    final reps = provider.reps;

    final linkedMuscleIds = exerciseMuscles.where((em) => em.exerciseId == exercise.id).map((em) => em.muscleId).toList();
    final musclesForExercise = linkedMuscleIds.map((id) => muscles.firstWhereOrNull((m) => m.id == id)).nonNulls.toList();

    final minRepCount = context.watch<AppSettingsProvider>().requiredReps;

    final prSet = sets.fold<exercise_set.WorkoutSet?>(null, (prev, set) {
      final rep = reps.firstWhereOrNull((r) => r.setId == set.id);
      if (rep == null || rep.count < minRepCount) return prev;

      if (prev == null) return set;

      final prevRep = reps.firstWhereOrNull((r) => r.setId == prev.id);
      if (prevRep == null) return set;

      // Compare logic:
      if (set.weight > prev.weight) return set;
      if (set.weight == prev.weight && rep.count > prevRep.count) return set;

      return prev;
    });

    final bestRep = prSet != null ? reps.firstWhere((r) => r.setId == prSet.id) : null;
    final prDate = prSet != null
        ? exerciseLogs.firstWhereOrNull((el) => el.id == prSet.exerciseLogId)?.date ?? DateTime.now()
        : DateTime.now();

    final completedDates = exerciseLogs.map((e) => e.date).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text(exercise.name), // This will update automatically
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () => editExercise(exercise, musclesForExercise))],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Targets: ${musclesForExercise.map((m) => m.name).join(", ")}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Notes', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  exercise.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
              ],
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Personal Record", style: theme.textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Text(DateFormat.yMMMd().format(prDate), style: theme.textTheme.labelSmall),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${prSet?.weight ?? 0} Kg', style: theme.textTheme.headlineLarge),
                          Text("•", style: theme.textTheme.headlineLarge),
                          Text("${bestRep?.count ?? 0} Reps", style: theme.textTheme.headlineLarge),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('History Calendar', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              TableCalendar(
                firstDay: DateTime.utc(2024, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                headerVisible: false,
                calendarFormat: CalendarFormat.week,
                selectedDayPredicate: (day) => DateUtils.isSameDay(day, _expandedDay),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _focusedDay = focusedDay;
                    _expandedDay = DateUtils.isSameDay(_expandedDay, selectedDay) ? null : selectedDay;
                  });
                },
                calendarStyle: CalendarStyle(
                  isTodayHighlighted: false,
                  selectedDecoration:
                      BoxDecoration(color: theme.colorScheme.primary.withAlpha((255 / 2).toInt()), shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                eventLoader: (day) {
                  return completedDates.any((d) => DateUtils.isSameDay(d, day)) ? [1] : [];
                },
              ),
              const SizedBox(height: 12),
              if (_expandedDay != null)
                ...exerciseLogs.where((el) => DateUtils.isSameDay(el.date, _expandedDay!)).map((el) {
                  final setList = sets.where((s) => s.exerciseLogId == el.id).toList();
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(DateFormat.yMMMd().format(el.date), style: theme.textTheme.titleSmall),
                            const SizedBox(height: 8),
                            ...setList.map((s) {
                              final setReps = reps.firstWhere((r) => r.setId == s.id);
                              return WorkoutSetCard(workoutSet: s, rep: setReps);
                            }),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 12),
              Text('Last 3 Workouts', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...exerciseLogs.reversed.take(3).map((el) {
                final dateStr = DateUtils.isSameDay(el.date, DateTime.now()) ? "Today" : DateFormat.yMMMd().format(el.date);
                final setList = sets.where((s) => s.exerciseLogId == el.id).toList();
                return Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(dateStr, style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        ...setList.map((s) {
                          final setReps = reps.firstWhere((r) => r.setId == s.id);
                          return WorkoutSetCard(workoutSet: s, rep: setReps);
                        }),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Text('Add Set', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1),
                  Expanded(
                    child: TextField(
                      controller: _repController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    onPressed: () => _addSet(exercise),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutSetCard extends StatelessWidget {
  final exercise_set.WorkoutSet workoutSet;
  final Rep rep;

  const WorkoutSetCard({
    super.key,
    required this.workoutSet,
    required this.rep,
  });

  void onTap(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => WorkoutSetDialog(
            workoutSet: workoutSet,
            rep: rep,
            onCompleted: (s, r) {
              context.read<UnifiedProvider>().updateSet(s);
              context.read<UnifiedProvider>().updateRep(r); // Fixed: was updateSet twice
            }));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("${workoutSet.weight}kg", style: theme.textTheme.bodyMedium),
            Text("${rep.count} reps", style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
