import 'package:flutter/material.dart';
import 'package:your_reps/data/objects/muscle.dart';

class NewMuscleDialog extends StatefulWidget {
  const NewMuscleDialog({super.key});

  @override
  State<NewMuscleDialog> createState() => _NewMuscleDialogState();
}

class _NewMuscleDialogState extends State<NewMuscleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _recoveryIndexController = TextEditingController();

  String? _selectedLocation;
  String? _selectedPushPull;

  final _locations = ['Arms', 'Chest', 'Back', 'Core', 'Legs'];
  final _pushPullOptions = ['Push', 'Pull', 'Neutral'];

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final muscle = Muscle(
        name: _nameController.text,
        location: _selectedLocation!,
        recoveryIndex: int.parse(_recoveryIndexController.text),
        pushPull: _selectedPushPull!,
      );
      Navigator.pop(context, muscle);
    }
  }

  void _cancel() => Navigator.pop(context, null);

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
                Text("Add Muscle", style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Muscle Name',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Location
                DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  items: _locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
                  onChanged: (val) => setState(() => _selectedLocation = val),
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Recovery Index
                TextFormField(
                  controller: _recoveryIndexController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Recovery Index (e.g. 3)',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (int.tryParse(val) == null) return 'Must be a number';
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Push / Pull
                DropdownButtonFormField<String>(
                  value: _selectedPushPull,
                  items: _pushPullOptions.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => setState(() => _selectedPushPull = val),
                  decoration: const InputDecoration(
                    labelText: 'Push / Pull',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  validator: (val) => val == null ? 'Required' : null,
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: _cancel, child: const Text("Cancel")),
                    FilledButton(onPressed: _submit, child: const Text("Create")),
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
