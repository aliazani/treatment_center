import 'dart:io';
import 'dart:typed_data';

import 'package:treatment_center/core/providers/file_wrapper_interface.dart';

import 'file_provider_interface.dart';
import 'file_wrapper_io.dart';

class FileProviderImpl implements FileProvider {
  @override
  Future<FileWrapper> getFile(String path) async => IoFileWrapper(File(path));

  @override
  Future<Uint8List> readAsBytes(FileWrapper file) async {
    final bytes = await file.readAsBytes();
    return Uint8List.fromList(bytes);
  }

  @override
  Future<String> readAsString(FileWrapper file) => file.readAsString();

  @override
  Future<FileWrapper> writeAsBytes(FileWrapper file, List<int> bytes) async {
    await file.writeAsBytes(bytes);
    return file;
  }

  @override
  Future<FileWrapper> writeAsString(FileWrapper file, String contents) async {
    await file.writeAsString(contents);
    return file;
  }
}
