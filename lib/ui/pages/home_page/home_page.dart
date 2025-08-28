import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:your_reps/data/objects/set.dart' as exercise_set;
import 'package:your_reps/data/providers/app_settings_provider.dart';
import 'package:your_reps/data/providers/unified_provider.dart';
import 'package:your_reps/ui/pages/app_settings_page/app_settings_page.dart';
import 'package:your_reps/ui/pages/database_management_page.dart';
import 'package:your_reps/ui/pages/exercise_page/exercise_page.dart';
import 'package:your_reps/ui/dialogs/exercise_dialog.dart';
import 'package:your_reps/ui/pages/home_page/home_drawer.dart';
import 'package:your_reps/ui/pages/home_page/widgets/title_bar.dart';
import 'package:your_reps/ui/pages/home_page/widgets/today_summary_cards.dart';
import 'package:your_reps/ui/pages/muscles_page/muscles_page.dart';
import 'package:your_reps/ui/pages/user_setup_page/user_setup_page.dart';
import 'package:your_reps/ui/widgets/exercise_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  bool _pushedUserSetup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<UnifiedProvider>();
      await provider.fetchAll();

      if (provider.users.isEmpty && !_pushedUserSetup) {
        _pushedUserSetup = true;

        final created = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserSetupPage()),
        );

        if (created == true) {
          await provider.fetchAll();
          setState(() {});
        }
      }
    });
  }

  Future<void> createExercise(exercise, muscles) async {
    await context.read<UnifiedProvider>().addExercise(exercise);
    var exerciseWithId = context.read<UnifiedProvider>().exercises.last;
    context.read<UnifiedProvider>().addExerciseMuscles(exerciseWithId, muscles);
  }

  Future<void> pinExercise(exercise) async {
    var pinned = context.read<AppSettingsProvider>().pinnedExercises;

    if (pinned.contains(exercise.id)) {
      pinned.remove(exercise.id);
    } else {
      pinned.add(exercise.id);
    }

    context.read<AppSettingsProvider>().setPinnedExercises(pinned);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unified = context.watch<UnifiedProvider>();
    final settingsProvider = context.watch<AppSettingsProvider>();

    // Only continue if user exists
    if (unified.users.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final exercises = unified.exercises;
    final exerciseMuscles = unified.exerciseMuscles;
    final muscles = unified.muscles;
    final sets = unified.sets;
    final reps = unified.reps;
    final logs = unified.exerciseLogs;
    final pinnedExercises = settingsProvider.pinnedExercises;

    final filteredExercises = (searchQuery.isEmpty
            ? exercises
            : exercises.where((e) => e.name.toLowerCase().contains(searchQuery.toLowerCase())))
        .toList()
      ..sort((a, b) {
        final aPinned = pinnedExercises.contains(a.id);
        final bPinned = pinnedExercises.contains(b.id);
        if (aPinned != bPinned) return bPinned ? 1 : -1;

        final aDate = logs
                .where((l) => l.exerciseId == a.id)
                .map((l) => l.date)
                .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a) ??
            DateTime(0);
        final bDate = logs
                .where((l) => l.exerciseId == b.id)
                .map((l) => l.date)
                .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a) ??
            DateTime(0);
        return bDate.compareTo(aDate);
      });

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add_rounded),
          onPressed: () async =>
              await showDialog(context: context, builder: (context) => ExerciseDialog(onComplete: createExercise))),
      drawer: HomeDrawer(context).getInstance(
        onMuscles: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MusclesPage()),
        ),
        onDatabase: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DatabaseManagementPage()),
        ),
        onSettings: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AppSettingsPage()),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    settingsProvider.isDarkMode ? "assets/images/app_icon_white.png" : "assets/images/app_icon.png",
                    height: 50,
                  ),
                  const SizedBox(height: 8),
                  TitleBar(
                    controller: _searchController,
                    onChanged: (val) => setState(() => searchQuery = val),
                  ),
                  Expanded(
                    child: RawScrollbar(
                      thumbColor: Theme.of(context).colorScheme.outline,
                      thickness: 3.0,
                      radius: const Radius.circular(4),
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          const SizedBox(height: 8),
                          TodaySummaryWidget(
                            logs: logs,
                            sets: sets,
                            reps: reps,
                            exercises: exercises,
                            exerciseMuscles: exerciseMuscles,
                            muscles: muscles,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 8, bottom: 12),
                            child: Text(
                              "Exercise History",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                          ...filteredExercises.map((exercise) {
                            final muscleNames = unified
                                .getMuscleIdsForExercise(exercise.id!)
                                .map((id) => muscles.firstWhereOrNull((m) => m.id == id))
                                .map((m) => m?.name ?? "Deleted Muscle")
                                .toList();

                            final exerciseLogs = logs.where((log) => log.exerciseId == exercise.id).toList();
                            final latestLog = exerciseLogs.isNotEmpty ? exerciseLogs.last : null;

                            final latestSets = latestLog != null
                                ? sets.where((s) => s.exerciseLogId == latestLog.id).toList()
                                : <exercise_set.WorkoutSet>[];

                            final latestSetData = latestSets.map((s) {
                              final r = reps.firstWhereOrNull((r) => r.setId == s.id);
                              return '${s.weight}kg x ${r?.count ?? 0} reps';
                            }).toList();

                            final dateStr = latestLog != null
                                ? DateUtils.isSameDay(latestLog.date, DateTime.now())
                                    ? 'Today'
                                    : DateFormat.yMMMd().format(latestLog.date)
                                : 'No Logs';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 0,
                              color: Theme.of(context).colorScheme.surface,
                              child: ExerciseTile(
                                exercise: exercise,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ExercisePage(exerciseId: exercise.id!)),
                                ),
                                muscles: muscleNames,
                                lastSetInfo: latestSetData.join(', '),
                                lastDate: dateStr,
                                isPinned: pinnedExercises.contains(exercise.id),
                                onPin: () => pinExercise(exercise),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
