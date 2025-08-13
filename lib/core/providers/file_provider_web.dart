import 'dart:async';
import 'dart:typed_data';

import 'package:treatment_center/core/providers/file_wrapper_interface.dart';

import 'file_provider_interface.dart';

class FileProviderImpl implements FileProvider {
  @override
  Future<FileWrapper> getFile(String path) async =>
      throw UnsupportedError('There is no file-system path on the web.');

  @override
  Future<Uint8List> readAsBytes(FileWrapper file) async {
    final bytes = await file.readAsBytes();
    return Uint8List.fromList(bytes);
  }

  @override
  Future<String> readAsString(FileWrapper file) => file.readAsString();

  @override
  Future<FileWrapper> writeAsBytes(FileWrapper file, List<int> bytes) async =>
      throw UnsupportedError('Writing files is not supported on the web.');

  @override
  Future<FileWrapper> writeAsString(FileWrapper file, String contents) async =>
      throw UnsupportedError('Writing files is not supported on the web.');
}
