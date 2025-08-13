class File {
  final String path;
  File(this.path);
  Future<FileStat> stat() async => FileStat(0);
}

class FileStat {
  final int size;
  FileStat(this.size);
}
