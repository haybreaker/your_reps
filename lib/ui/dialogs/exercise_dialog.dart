import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_reps/data/objects/exercise.dart';
import 'package:your_reps/data/objects/muscle.dart';
import 'package:your_reps/data/providers/unified_provider.dart';

class ExerciseDialog extends StatefulWidget {
  // 1. Add an optional exercise parameter for editing
  final Exercise? exercise;
  final List<Muscle>? muscles;
  final Function(Exercise, List<Muscle>) onComplete;

  const ExerciseDialog({super.key, this.exercise, this.muscles, required this.onComplete});

  @override
  State<ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<ExerciseDialog> {
  final _formKey = GlobalKey<FormState>();

  // 2. Use TextEditingControllers for text fields
  late final TextEditingController _nameController;
  late final TextEditingController _photoLinkController;
  late final TextEditingController _videoLinkController;
  late final TextEditingController _notesController;

  // State variables for non-text fields
  List<int> muscleIds = [];
  int functionIsolationScale = 5;

  // Helper to determine if we are in "edit" mode
  bool get isEditing => widget.exercise != null;

  @override
  void initState() {
    super.initState();
    context.read<UnifiedProvider>().fetchMuscles();

    // Initialize controllers
    _nameController = TextEditingController();
    _photoLinkController = TextEditingController();
    _videoLinkController = TextEditingController();
    _notesController = TextEditingController();

    // 3. If editing, pre-fill the form with existing exercise data
    if (isEditing) {
      final exercise = widget.exercise!;
      final muscles = widget.muscles!;
      _nameController.text = exercise.name;
      _photoLinkController.text = exercise.photoLink ?? '';
      _videoLinkController.text = exercise.videoLink ?? '';
      _notesController.text = exercise.notes ?? '';
      muscleIds = List<int>.from(muscles.map((m) => m.id!)).toList(); // Create a mutable copy
      functionIsolationScale = exercise.functionIsolationScale;
    }
  }

  @override
  void dispose() {
    // 4. Dispose controllers to prevent memory leaks
    _nameController.dispose();
    _photoLinkController.dispose();
    _videoLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final muscles = context.watch<UnifiedProvider>().muscles;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 5. Update title based on mode
                Text(isEditing ? "Edit Exercise" : "Create New Exercise", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameController, // Use controller
                  decoration: const InputDecoration(labelText: 'Exercise Name', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Multi-select muscle field (no changes needed here)
                GestureDetector(
                  onTap: () async {
                    final selected = await showDialog<List<int>>(
                      context: context,
                      builder: (context) {
                        List<int> tempSelected = [...muscleIds];
                        return AlertDialog(
                          title: const Text("Select Muscles"),
                          content: StatefulBuilder(
                            builder: (context, setState) {
                              return SizedBox(
                                width: double.maxFinite,
                                child: ListView(
                                  shrinkWrap: true,
                                  children: muscles.map((muscle) {
                                    final isSelected = tempSelected.contains(muscle.id);
                                    return CheckboxListTile(
                                      value: isSelected,
                                      title: Text(muscle.name),
                                      onChanged: (checked) {
                                        setState(() {
                                          if (checked == true) {
                                            tempSelected.add(muscle.id!);
                                          } else {
                                            tempSelected.remove(muscle.id);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              child: const Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                            ),
                            FilledButton(
                              child: const Text("OK"),
                              onPressed: () => Navigator.pop(context, tempSelected),
                            ),
                          ],
                        );
                      },
                    );

                    if (selected != null) {
                      setState(() {
                        muscleIds = selected;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: muscleIds.isEmpty
                        ? Text("Tap to select muscles", style: Theme.of(context).textTheme.titleMedium)
                        : Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: muscleIds
                                .map((id) =>
                                    muscles.firstWhere((m) => m.id == id, orElse: () => throw Exception('Muscle not found')))
                                .map((m) => InputChip(
                                      label: Text(m.name),
                                      onDeleted: () => setState(() => muscleIds.remove(m.id)),
                                    ))
                                .toList(),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Photo Link
                TextFormField(
                  controller: _photoLinkController, // Use controller
                  decoration: const InputDecoration(labelText: 'Photo Link', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),

                // Video Link
                TextFormField(
                  controller: _videoLinkController, // Use controller
                  decoration: const InputDecoration(labelText: 'Video Link', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 24),

                // Function/Isolation Slider
                Text("Function-Isolation Scale: $functionIsolationScale", style: Theme.of(context).textTheme.labelLarge),
                Slider(
                  value: functionIsolationScale.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: functionIsolationScale.toString(),
                  onChanged: (value) {
                    setState(() {
                      functionIsolationScale = value.round();
                    });
                  },
                ),
                const SizedBox(height: 24),

                // Notes Input
                Text("Notes", style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  minLines: 4,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    labelText: 'Enter any extra information here...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("Cancel"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      // 6. Update button text and logic
                      child: Text(isEditing ? "Save" : "Create"),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          final newExercise = Exercise(
                              id: widget.exercise?.id, // Preserve ID if editing
                              name: _nameController.text,
                              photoLink: _photoLinkController.text,
                              videoLink: _videoLinkController.text,
                              functionIsolationScale: functionIsolationScale,
                              notes: _notesController.text);
                          widget.onComplete(
                              newExercise, [...muscleIds].map((mid) => muscles.firstWhere((m) => m.id == mid)).toList());
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
