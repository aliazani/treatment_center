import 'dart:io' show Directory;

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

typedef GetSavePath =
    Future<String> Function({
      required String fileName,
      required String mimeType,
      Uint8List? bytes,
    });

/// Resolves a file save path depending on platform.
/// - On Web, opens a save dialog via FilePicker and returns the chosen path,
///   or a 'download:' URI if bytes are provided and the user cancels.
///   Throws if canceled and no bytes are provided.
/// - On mobile/desktop, uses the application documents directory, creating an
///   'FVD_Assessments' folder if needed, and returns the full file path.
Future<String> defaultSavePath({
  required String fileName,
  required String mimeType,
  Uint8List? bytes,
}) async {
  if (kIsWeb) {
    final selectedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Save "\$fileName"',
      fileName: fileName,
      bytes: bytes,
      type: FileType.custom,
      allowedExtensions: [path.extension(fileName).replaceFirst('.', '')],
    );

    if (selectedPath == null) {
      if (bytes != null) {
        return 'download:\$fileName';
      }
      throw Exception('Save cancelled by user');
    }

    return selectedPath;
  }

  final appDocDir = await getApplicationDocumentsDirectory();
  final exportDirPath = path.join(appDocDir.path, 'FVD_Assessments');
  final exportDir = Directory(exportDirPath);
  if (!await exportDir.exists()) {
    await exportDir.create(recursive: true);
  }
  return path.join(exportDirPath, fileName);
}
