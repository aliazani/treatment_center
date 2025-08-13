import 'package:treatment_center/core/providers/web_file.dart';

import 'dart:typed_data';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';

class WebFileWrapper implements FileWrapper {
  final String name;
  Uint8List _bytes;
  final WebFile _file;

  WebFileWrapper(this._file, {required this.name, required Uint8List bytes})
    : _bytes = Uint8List.fromList(bytes);

  @override
  WebFile get raw => _file;

  @override
  String get path => name;

  @override
  Future<bool> exists() async => true;

  @override
  Future<int> length() async => _bytes.length;

  @override
  Future<List<int>> readAsBytes() async => _bytes;

  @override
  Future<String> readAsString() async => String.fromCharCodes(_bytes);

  @override
  Future<void> writeAsBytes(List<int> bytes) async {
    _bytes = Uint8List.fromList(bytes);
  }

  @override
  Future<void> writeAsString(String contents) async {
    _bytes = Uint8List.fromList(contents.codeUnits);
  }
}
