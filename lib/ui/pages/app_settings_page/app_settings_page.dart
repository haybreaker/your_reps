import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_reps/data/providers/app_settings_provider.dart';
import 'package:your_reps/data/settings/app_settings.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool isDark = false;
  Color primaryColor = Colors.blue;
  int requiredReps = 1;

  void _updateTheme(BuildContext context) {
    context.read<AppSettingsProvider>().setTheme(primaryColor, isDark);
  }

  void _pickColor() async {
    final colorOptions = [
      Colors.redAccent,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.lightBlueAccent,
      Colors.orangeAccent,
      Colors.purpleAccent,
      Colors.tealAccent,
    ];

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        elevation: 3,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose a Primary Color',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: colorOptions.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final color = colorOptions[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () {
                        setState(() => primaryColor = color);
                        _updateTheme(context);
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 24,
                        child: color == primaryColor ? Icon(Icons.check, color: Colors.white) : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _changeReps(BuildContext context) async {
    final controller = TextEditingController(text: requiredReps.toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Required Reps for PR'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Reps',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final reps = int.tryParse(controller.text);
              if (reps != null && reps > 0) {
                Navigator.pop(ctx, reps);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => requiredReps = result);
      AppSettings.saveRequiredReps(result);
    }
  }

  @override
  void initState() {
    super.initState();
    isDark = context.read<AppSettingsProvider>().isDarkMode;
    primaryColor = context.read<AppSettingsProvider>().primaryColor;
    requiredReps = context.read<AppSettingsProvider>().requiredReps;
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        appBar: AppBar(title: const Text("Settings")),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            SwitchListTile(
              title: const Text("Dark Theme"),
              subtitle: const Text("Enable dark mode throughout the app"),
              value: isDark,
              onChanged: (val) {
                setState(() => isDark = val);
                _updateTheme(context);
              },
            ),
            ListTile(
              title: const Text("Primary Color"),
              subtitle: const Text("Tap to change color"),
              trailing: CircleAvatar(backgroundColor: primaryColor),
              onTap: _pickColor,
            ),
            ListTile(
              title: const Text("Required Reps for PR"),
              subtitle: Text("Current: $requiredReps"),
              onTap: () => _changeReps(context),
            ),
          ],
        ),
      );
    } catch (e) {
      return SingleChildScrollView(child: Text(e.toString()));
    }
  }
}
