import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:your_reps/data/databases/sqlite3/interfaces/database_helper_interface.dart';
import 'package:your_reps/data/databases/sqlite3/interfaces/sqlite.dart';
import 'package:your_reps/data/providers/app_settings_provider.dart';
import 'package:your_reps/data/providers/unified_provider.dart';
import 'package:your_reps/data/providers/user_provider.dart';
import 'package:your_reps/data/settings/app_settings.dart';
import 'package:your_reps/ui/pages/home_page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up our app settings and providers
  await AppSettings.init();

  // Setup local DB
  // Initialize FFI for desktop/test environments
  sqfliteFfiInit();

  // Set the database factory for ffi usage
  if (kIsWeb) {
    // Use web implementation on the web.
    databaseFactory = databaseFactoryFfiWeb;
  } else if (Platform.isWindows || Platform.isMacOS || Platform.isWindows) {
    databaseFactory = databaseFactoryFfi;
  }
  final DatabaseHelperInterface db;
  db = SqliteDatabaseHelper();
  await db.init();

  // Start the application
  runApp(YourReps(db));
}

class YourReps extends StatelessWidget {
  final DatabaseHelperInterface db;
  const YourReps(this.db, {super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => AppSettingsProvider()),
          ChangeNotifierProvider(create: (context) => UserProvider()),
          ChangeNotifierProvider(create: (context) => UnifiedProvider(dbHelper: db))
        ],
        builder: (context, child) => MaterialApp(
              title: 'Your Reps',
              theme: context.watch<AppSettingsProvider>().theme,
              home: const HomePage(),
            ));
  }
}
