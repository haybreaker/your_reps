// lib/database/connection/connection_web.dart
import 'dart:typed_data';
import 'package:sqlite3/wasm.dart';

/// Opens the database on the web platform.
Future<CommonDatabase> openConnection() async {
  const dbName = "workout_db.db";

  // Load the WASM SQLite library
  final wasmSqlite = await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));

  // Create and register the IndexedDB file system
  final fs = await IndexedDbFileSystem.open(dbName: dbName);
  wasmSqlite.registerVirtualFileSystem(fs, makeDefault: false);

  // Open the database using the registered VFS
  return wasmSqlite.open(dbName, vfs: fs.name);
}

Future<void> writeDbBytes(String databaseName, Uint8List bytes) async {
  // The `dbName` for `IndexedDbFileSystem.open` is the name of the VFS store itself,
  // often a constant like 'sqlite3_databases'. The `databaseName` parameter
  // for this function is the file path *within* that VFS.
  final fs = await IndexedDbFileSystem.open(dbName: databaseName);

  try {
    // The path must be absolute within the VFS.
    const String filePath = "workout_db.db";
    String fullPath = fs.xFullPathName(filePath);

    // 1. Delete the old file if it exists.
    // `xAccess` returns 0 if the path cannot be accessed (e.g., doesn't exist).
    if (fs.xAccess(fullPath, 0) != 0) {
      fs.xDelete(fullPath, 0);
    }

    // 2. Open a new file for writing, creating it if it doesn't exist.
    final openResult = fs.xOpen(
      Sqlite3Filename(fullPath),
      SqlFlag.SQLITE_OPEN_READWRITE | SqlFlag.SQLITE_OPEN_CREATE,
    );
    final file = openResult.file;

    // 3. Write the new byte data starting from the beginning of the file (offset 0).
    file.xWrite(bytes, 0);

    // 4. IMPORTANT: Flush the pending changes to the underlying IndexedDB.
    // Since the VFS is asynchronous, this ensures the write operation completes.
    await fs.flush();
  } finally {
    // 5. Close the VFS to release resources.
    await fs.close();
  }
}

Future<Uint8List> readDbBytes(String databaseName) async {
  try {
    // Open file system
    final fs = await IndexedDbFileSystem.open(dbName: databaseName);

    // First, let's check if the file exists and get its full path
    String filePath = "workout_db.db";

    try {
      // Get the full path name for better compatibility
      final fullPath = fs.xFullPathName(filePath);
      print('Full path resolved: $fullPath');
      filePath = fullPath;
    } catch (e) {
      print('Could not resolve full path, using original: $e');
    }

    // Check if file exists
    try {
      final accessResult = fs.xAccess(filePath, 0); // 0 = SQLITE_ACCESS_EXISTS
      print('File exists check result: $accessResult');
    } catch (e) {
      print('File access check failed: $e');
      // Continue anyway, the file might still be openable
    }

    // Open file for reading
    // 0x00000001 = SQLITE_OPEN_READONLY
    final result = fs.xOpen(Sqlite3Filename(filePath), 0x00000001);
    final fileHandle = result.file;
    final outFlags = result.outFlags;

    print('File opened successfully. Output flags: 0x${outFlags.toRadixString(16)}');

    // Get the file length
    final length = fileHandle.xFileSize();
    print('File size: $length bytes');

    if (length == 0) {
      print('Warning: File appears to be empty');
      fileHandle.xClose();
      return Uint8List(0);
    }

    // First, let's read just the header to validate it's a SQLite file
    final headerSize = 100;
    final headerBuffer = Uint8List(headerSize);

    try {
      fileHandle.xRead(headerBuffer, 0);

      // Check SQLite magic header
      if (headerBuffer.length >= 16) {
        final headerString = String.fromCharCodes(headerBuffer.take(16));
        print('File header: "${headerString.replaceAll('\x00', '\\x00')}"');

        if (headerString.startsWith('SQLite format 3\x00')) {
          print('✓ Valid SQLite database header detected');
        } else {
          print('⚠ Warning: File does not appear to be a valid SQLite database');
          print('Header bytes: ${headerBuffer.take(16).toList()}');
        }
      }
    } catch (e) {
      print('Error reading header: $e');
      // Continue anyway, might be a partial read issue
    }

    // Now read the entire file
    final buffer = Uint8List(length);

    // Read in chunks to handle large files and potential VFS limitations
    const chunkSize = 8192; // 8KB chunks
    int totalBytesRead = 0;

    for (int offset = 0; offset < length; offset += chunkSize) {
      final remaining = length - offset;
      final currentChunkSize = remaining < chunkSize ? remaining : chunkSize;
      final chunk = Uint8List.view(buffer.buffer, offset, currentChunkSize);

      try {
        fileHandle.xRead(chunk, offset);
        totalBytesRead += currentChunkSize;

        // Progress indicator for large files
        if (length > 1024 * 1024) {
          // Only show for files > 1MB
          final progress = (totalBytesRead / length * 100).toStringAsFixed(1);
          print('Reading progress: $progress% ($totalBytesRead / $length bytes)');
        }
      } catch (e) {
        print('Error reading chunk at offset $offset: $e');

        // Handle short reads - this might be expected behavior
        if (e is VfsException && e.returnCode == SqlExtendedError.SQLITE_IOERR_SHORT_READ) {
          print('Short read encountered at offset $offset');
          print('This might indicate end of actual file content');

          // The BaseVfsFile should have filled remaining bytes with zeros
          // Let's check if we have valid data up to this point
          final actualLength = offset + currentChunkSize;
          print('Truncating buffer to actual read length: $actualLength');

          // Return only the data we successfully read
          final truncatedBuffer = Uint8List(actualLength);
          truncatedBuffer.setAll(0, buffer.take(actualLength));
          fileHandle.xClose();
          return truncatedBuffer;
        }

        // For other errors, rethrow
        rethrow;
      }
    }

    // Close the file handle
    fileHandle.xClose();

    print('Successfully read $totalBytesRead bytes from database file');

    // Final validation
    if (buffer.length >= 16) {
      final header = String.fromCharCodes(buffer.take(16));
      if (header.startsWith('SQLite format 3\x00')) {
        print('✓ Final validation: Valid SQLite database format confirmed');
      } else {
        print('⚠ Final validation: File does not appear to be a valid SQLite database');
      }
    }

    // Check for excessive zeros at the end (which was your original issue)
    int trailingZeros = 0;
    for (int i = buffer.length - 1; i >= 0; i--) {
      if (buffer[i] == 0) {
        trailingZeros++;
      } else {
        break;
      }
    }

    final zeroPercentage = (trailingZeros / buffer.length * 100).toStringAsFixed(1);
    print('Trailing zeros: $trailingZeros bytes ($zeroPercentage% of file)');

    if (trailingZeros > buffer.length * 0.5) {
      print('⚠ Warning: More than 50% of file is trailing zeros');
      print('This might indicate a problem with the file or reading process');

      // Option to truncate trailing zeros
      if (trailingZeros > 0) {
        final trimmedLength = buffer.length - trailingZeros;
        print('Consider truncating to $trimmedLength bytes to remove trailing zeros');

        // Uncomment the next lines if you want to automatically trim zeros:
        // final trimmedBuffer = Uint8List(trimmedLength);
        // trimmedBuffer.setAll(0, buffer.take(trimmedLength));
        // return trimmedBuffer;
      }
    }

    return buffer;
  } catch (e, stackTrace) {
    print('Error reading database: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}

Future<void> deleteDbBytes(String databaseName) async {
  final fs = await IndexedDbFileSystem.open(dbName: databaseName);

  try {
    // The path must be absolute within the VFS.
    const String filePath = "workout_db.db";
    String fullPath = fs.xFullPathName(filePath);

    // 1. Delete the old file if it exists.
    // `xAccess` returns 0 if the path cannot be accessed (e.g., doesn't exist).
    if (fs.xAccess(fullPath, 0) != 0) {
      fs.xDelete(fullPath, 0);
    }

    await fs.flush();
  } finally {
    // 5. Close the VFS to release resources.
    await fs.close();
  }
}
