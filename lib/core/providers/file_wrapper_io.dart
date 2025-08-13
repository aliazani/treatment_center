import 'dart:io' as io;
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';

class IoFileWrapper implements FileWrapper {
  final io.File _file;
  IoFileWrapper(this._file);

  @override
  io.File get raw => _file;

  @override
  String get path => _file.path;

  @override
  Future<bool> exists() => _file.exists();

  @override
  Future<int> length() async => (await _file.stat()).size;

  @override
  Future<List<int>> readAsBytes() => _file.readAsBytes();

  @override
  Future<String> readAsString() => _file.readAsString();

  @override
  Future<void> writeAsBytes(List<int> bytes) => _file.writeAsBytes(bytes);

  @override
  Future<void> writeAsString(String contents) => _file.writeAsString(contents);
}
