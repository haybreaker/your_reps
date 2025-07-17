import 'dart:typed_data';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

/// Opens the database on native platforms (mobile, desktop).
Future<CommonDatabase> openConnection() async {
  final dbPath = await getApplicationDocumentsDirectory();
  final path = join(dbPath.path, "workout_db.db");
  return sqlite3.sqlite3.open(path);
}

Future<CommonDatabase> writeDbBytes(String databaseName, Uint8List bytes) async {
  throw UnimplementedError("");
}

Future<Uint8List> readDbBytes(String databaseName) async {
  throw UnimplementedError("");
}

Future<void> deleteDbBytes(String databaseName) async {
  throw UnimplementedError("");
}
