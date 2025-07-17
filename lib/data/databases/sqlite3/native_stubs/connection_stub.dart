import 'dart:typed_data';

import 'package:sqlite3/common.dart';

Future<CommonDatabase> openConnection() {
  throw UnsupportedError('Platform not supported');
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
