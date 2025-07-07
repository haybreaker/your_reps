import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/set.dart' as exercise_set;
import 'package:your_reps/data/providers/app_settings_provider.dart';
import 'package:your_reps/data/providers/unified_provider.dart';
import 'package:your_reps/ui/pages/home_page/dialogs/exercise_dialog.dart';

class ExercisePage extends StatefulWidget {
  final Exercise exercise;
  const ExercisePage({required this.exercise, super.key});

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _expandedDay;
  final TextEditingController _repController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _addSet() {
    if (_repController.text.isNotEmpty && _weightController.text.isNotEmpty) {
      setState(() {
        context.read<UnifiedProvider>().recordSet(
              widget.exercise,
              double.parse(_weightController.text),
              int.parse(_repController.text),
            );
        _repController.clear();
      });
    }
  }

  Future<void> editExercise() async {
    var newExercise = await showDialog(
        context: context,
        builder: (context) => ExerciseDialog(
              exercise: widget.exercise,
            ));
    if (mounted && newExercise != null) context.read<UnifiedProvider>().updateExercise(newExercise);
  }

  @override
  void initState() {
    super.initState();
    context.read<UnifiedProvider>().fetchMuscles();
    context.read<UnifiedProvider>().fetchExerciseLogs();
    context.read<UnifiedProvider>().fetchSets();
    context.read<UnifiedProvider>().fetchReps();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final muscles = context.watch<UnifiedProvider>().muscles;
    final exerciseLogs =
        context.watch<UnifiedProvider>().exerciseLogs.where((el) => el.exerciseId == widget.exercise.id).toList();
    final sets = context
        .watch<UnifiedProvider>()
        .sets
        .where((s) => exerciseLogs.map((el) => el.id).contains(s.exerciseLogId))
        .toList();
    final reps = context.watch<UnifiedProvider>().reps;

    final minRepCount = context.watch<AppSettingsProvider>().requiredReps;

    final prSet = sets.fold<exercise_set.Set?>(null, (prev, set) {
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
        title: Text(widget.exercise.name),
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: editExercise)],
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Targets: ${widget.exercise.muscleId.map((id) => muscles.firstWhereOrNull((muscle) => muscle.id == id)?.name ?? "Deleted Muscle").join(", ")}',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
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
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(51),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("${s.weight}kg", style: theme.textTheme.bodyMedium),
                                    Text("${setReps.count} reps", style: theme.textTheme.bodyMedium),
                                  ],
                                ),
                              );
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("${s.weight}kg", style: theme.textTheme.bodyMedium),
                                Text("${setReps.count} reps", style: theme.textTheme.bodyMedium),
                              ],
                            ),
                          );
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
                    onPressed: _addSet,
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
