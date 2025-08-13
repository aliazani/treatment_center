import 'dart:typed_data';

import 'file_wrapper_interface.dart';
import 'file_provider_interface.dart';

class FileProviderImpl implements FileProvider {
  Never _fail() =>
      throw UnsupportedError('File operations are not supported here.');

  @override
  Future<FileWrapper> getFile(String path) => _fail();

  @override
  Future<Uint8List> readAsBytes(FileWrapper file) => _fail();

  @override
  Future<String> readAsString(FileWrapper file) => _fail();

  @override
  Future<FileWrapper> writeAsBytes(FileWrapper file, List<int> bytes) =>
      _fail();

  @override
  Future<FileWrapper> writeAsString(FileWrapper file, String contents) =>
      _fail();
}
