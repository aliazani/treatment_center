import 'dart:typed_data';
import 'file_wrapper_interface.dart';

abstract class FileProvider {
  Future<FileWrapper> getFile(String path);
  Future<Uint8List> readAsBytes(FileWrapper file);
  Future<String> readAsString(FileWrapper file);

  Future<FileWrapper> writeAsBytes(FileWrapper file, List<int> bytes);
  Future<FileWrapper> writeAsString(FileWrapper file, String contents);
}
