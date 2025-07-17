import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_reps/data/providers/unified_provider.dart';
import 'package:your_reps/ui/pages/muscles_page/new_muscle_dialog.dart';

class MusclesPage extends StatefulWidget {
  const MusclesPage({super.key});

  @override
  State<MusclesPage> createState() => _MusclesPageState();
}

class _MusclesPageState extends State<MusclesPage> {
  @override
  void initState() {
    super.initState();
    context.read<UnifiedProvider>().fetchMuscles();
  }

  @override
  Widget build(BuildContext context) {
    final muscles = context.watch<UnifiedProvider>().muscles;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Muscles"),
      ),
      body: muscles.isEmpty
          ? const Center(child: Text("No muscles added yet"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: muscles.length,
              itemBuilder: (context, index) {
                final muscle = muscles[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: InkWell(
                    onTap: () async {
                      final newMuscle = await showDialog(
                        context: context,
                        builder: (context) => MuscleDialog(existingMuscle: muscle),
                      );
                      if (newMuscle != null) {
                        context.read<UnifiedProvider>().updateMuscle(newMuscle);
                      }
                    },
                    child: Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        title: Text(
                          muscle.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          "${muscle.location} • Recovery Index: ${muscle.recoveryIndex} • ${muscle.pushPull}",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        ),
                        leading: const Icon(Icons.fitness_center),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () {
                            context.read<UnifiedProvider>().deleteMuscle(muscle.id!);
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newMuscle = await showDialog(
            context: context,
            builder: (context) => const MuscleDialog(),
          );
          if (newMuscle != null) {
            context.read<UnifiedProvider>().updateMuscle(newMuscle);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
