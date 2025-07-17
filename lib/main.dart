import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:your_reps/data/databases/interfaces/database_helper_interface.dart';
import 'package:your_reps/data/databases/sqlite3/sqlite.dart';
import 'package:your_reps/data/providers/app_settings_provider.dart';
import 'package:your_reps/data/providers/unified_provider.dart';
import 'package:your_reps/data/providers/user_provider.dart';
import 'package:your_reps/data/settings/app_settings.dart';
import 'package:your_reps/ui/pages/home_page/home_page.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Set up our app settings and providers
  await AppSettings.init();

  final DatabaseHelperInterface db = SqliteDatabaseHelper();
  await db.init();

  // Start the application
  FlutterNativeSplash.remove();
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
