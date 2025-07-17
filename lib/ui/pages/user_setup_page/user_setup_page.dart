import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_reps/data/objects/user.dart';
import 'package:your_reps/data/providers/unified_provider.dart';

class UserSetupPage extends StatefulWidget {
  const UserSetupPage({super.key});

  @override
  State<UserSetupPage> createState() => _UserSetupPageState();
}

class _UserSetupPageState extends State<UserSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String? _trainingGoal;

  final List<String> _trainingGoals = [
    'Strength',
    'Hypertrophy',
    'Endurance',
    'General Fitness',
    'Weight Loss',
  ];

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final user = User(
        name: _nameController.text,
        age: int.tryParse(_ageController.text),
        weight: double.tryParse(_weightController.text),
        height: double.tryParse(_heightController.text),
        trainingGoal: _trainingGoal,
      );
      context.read<UnifiedProvider>().addUser(user);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text("Let's set up your profile", style: textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Enter a name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final age = int.tryParse(value ?? '');
                    return (age == null || age <= 0) ? 'Enter a valid age' : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final weight = double.tryParse(value ?? '');
                    return (weight == null || weight <= 0) ? 'Enter a valid weight' : null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final height = double.tryParse(value ?? '');
                    return (height == null || height <= 0) ? 'Enter a valid height' : null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Training Goal',
                    border: OutlineInputBorder(),
                  ),
                  value: _trainingGoal,
                  items: _trainingGoals.map((goal) => DropdownMenuItem(value: goal, child: Text(goal))).toList(),
                  onChanged: (val) => setState(() => _trainingGoal = val),
                  validator: (val) => val == null ? 'Select a training goal' : null,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _submit,
                  child: const Text('Create Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
