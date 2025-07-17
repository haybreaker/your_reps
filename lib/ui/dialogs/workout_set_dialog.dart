import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:your_reps/data/objects/rep.dart';
import 'package:your_reps/data/objects/set.dart';

class WorkoutSetDialog extends StatefulWidget {
  final WorkoutSet workoutSet;
  final Rep rep;
  final void Function(WorkoutSet workoutSet, Rep rep) onCompleted;

  const WorkoutSetDialog({
    super.key,
    required this.workoutSet,
    required this.rep,
    required this.onCompleted,
  });

  @override
  State<WorkoutSetDialog> createState() => _WorkoutSetDialogState();
}

class _WorkoutSetDialogState extends State<WorkoutSetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _repCountController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Populate fields with existing data
    _weightController.text = widget.workoutSet.weight.toString();
    _repCountController.text = widget.rep.count.toString();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedSet = WorkoutSet(
        id: widget.workoutSet.id,
        exerciseLogId: widget.workoutSet.exerciseLogId,
        weight: double.parse(_weightController.text),
        dropSet: widget.workoutSet.dropSet,
        superSet: widget.workoutSet.superSet,
      );

      final updatedRep = Rep(
        id: widget.rep.id,
        setId: widget.rep.setId,
        count: int.parse(_repCountController.text),
        effort: widget.rep.effort,
        repTime: widget.rep.repTime,
      );

      widget.onCompleted(updatedSet, updatedRep);
      Navigator.pop(context);
    }
  }

  void _cancel() => Navigator.pop(context);

  @override
  void dispose() {
    _weightController.dispose();
    _repCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Edit Set", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),

                // Weight
                TextFormField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    suffixText: 'kg',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (double.tryParse(val) == null) return 'Must be a valid number';
                    if (double.parse(val) < 0) return 'Weight must be positive';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Rep Count
                TextFormField(
                  controller: _repCountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    final intVal = int.tryParse(val);
                    if (intVal == null) return 'Must be a number';
                    if (intVal <= 0) return 'Reps must be greater than 0';
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: _cancel, child: const Text("Cancel")),
                    FilledButton(onPressed: _submit, child: const Text("Update")),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
