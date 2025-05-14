
import 'dart:io';

abstract class FileProvider {
  Future<File> getFile(String path);
  Future<String> readAsString(File file);
  Future<List<int>> readAsBytes(File file);
  Future<File> writeAsString(File file, String contents);
  Future<File> writeAsBytes(File file, List<int> bytes);
}

class FileProviderImpl implements FileProvider {
  @override
  Future<File> getFile(String path) async {
    return File(path);
  }

  @override
  Future<String> readAsString(File file) async {
    return await file.readAsString();
  }

  @override
  Future<List<int>> readAsBytes(File file) async {
    return await file.readAsBytes();
  }

  @override
  Future<File> writeAsString(File file, String contents) async {
    return await file.writeAsString(contents);
  }

  @override
  Future<File> writeAsBytes(File file, List<int> bytes) async {
    return await file.writeAsBytes(bytes);
  }
}