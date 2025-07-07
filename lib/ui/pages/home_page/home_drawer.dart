import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:your_reps/data/providers/app_settings_provider.dart';

class HomeDrawer {
  BuildContext context;
  HomeDrawer(this.context);

  Widget getInstance(
      {required void Function() onMuscles, required void Function() onDatabase, required void Function() onSettings}) {
    final darkMode = context.read<AppSettingsProvider>().isDarkMode;
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Image.asset("assets/images/YourRepsIcon.png", color: darkMode ? Colors.white : null, height: 96),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Text(
                "Welcome to Your Reps, a FOSS workout tracking app with ChatGPT-powered suggestions and planning.",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              /// List section with dense styling
              ListTileTheme(
                contentPadding: EdgeInsets.zero,
                minVerticalPadding: 4,
                minLeadingWidth: 32,
                dense: true,
                child: Column(
                  children: [
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      leading:
                          Image.asset("assets/icons/arm.png", height: 20, color: darkMode ? Colors.white : Colors.black),
                      title: Text("Muscles", style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text("View and edit muscles", style: Theme.of(context).textTheme.bodySmall),
                      onTap: onMuscles,
                    ),
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      leading: Image.asset("assets/icons/db.png", height: 20, color: darkMode ? Colors.white : Colors.black),
                      title: Text("Database", style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text("Import/Export your data", style: Theme.of(context).textTheme.bodySmall),
                      onTap: onDatabase,
                    ),
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      leading: const Icon(Icons.settings, size: 20),
                      title: Text("Settings", style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text("Adjust App Behaviour and Looks", style: Theme.of(context).textTheme.bodySmall),
                      onTap: onSettings,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
