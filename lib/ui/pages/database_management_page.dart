import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:your_reps/data/databases/sqlite3/interfaces/sqlite.dart';
import 'package:your_reps/data/providers/unified_provider.dart';

class DatabaseManagementPage extends StatefulWidget {
  const DatabaseManagementPage({super.key});

  @override
  State<DatabaseManagementPage> createState() => _DatabaseManagementPageState();
}

class _DatabaseManagementPageState extends State<DatabaseManagementPage> {
  final db = DatabaseHelper();
  late Future<void> _dbReady;

  @override
  void initState() {
    super.initState();
    _dbReady = db.database; // Ensure DB is initialized
  }

  Future<void> importDB() async {
    await _dbReady;
    try {
      FilePickerResult? result;
      result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        if (!path.endsWith(".db")) {
          _showSnackbar("Invalid file type selected. Please choose a .db file.");
          return;
        }

        await db.importDb(path);
        _showSnackbar("Database imported successfully.");
      } else {
        _showSnackbar("Import cancelled.");
      }
    } catch (e) {
      _showSnackbar("Error importing DB: $e");
    }
  }

  Future<void> exportDB() async {
    await _dbReady;

    try {
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final exportFileName = "your_reps_export_$timestamp.db";

      String? selectedDir = await FilePicker.platform.getDirectoryPath();

      if (selectedDir == null) {
        _showSnackbar("Export cancelled.");
        return;
      }

      final exportPath = '$selectedDir/$exportFileName';
      await db.exportDB(exportPath);

      _showSnackbar("Exported to:\n$exportPath");
    } catch (e) {
      _showSnackbar("Error exporting DB: $e");
    }
  }

  Future<void> deleteDB() async {
    await _dbReady;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("This will remove all user data. Are you sure?"),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      await db.deleteDB();
      _showSnackbar("Database deleted.");
    }
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          leading: Icon(icon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _dbReady,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Database Management")),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCard(
                  title: "Import Database",
                  subtitle: "Import a routine from another YourReps backup",
                  icon: Icons.file_download,
                  onTap: importDB,
                ),
                const SizedBox(height: 30),
                _buildCard(
                  title: "Export Database",
                  subtitle: "Export your progress to a selected folder",
                  icon: Icons.file_upload,
                  onTap: exportDB,
                ),
                const SizedBox(height: 30),
                _buildCard(
                  title: "Delete Database",
                  subtitle: "Clear all data permanently from YourReps",
                  icon: Icons.delete_forever,
                  onTap: deleteDB,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
