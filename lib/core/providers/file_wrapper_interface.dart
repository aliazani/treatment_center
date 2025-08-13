abstract class FileWrapper {
  String get path;
  Object get raw;
  Future<bool> exists();
  Future<int> length();
  Future<List<int>> readAsBytes();
  Future<String> readAsString();
  Future<void> writeAsBytes(List<int> bytes);
  Future<void> writeAsString(String contents);
}
