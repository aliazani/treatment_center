import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/core/providers/file_stub.dart';

void main() {
  group('File stub', () {
    const testPath = '/some/fake/path.txt';

    test('stores the path passed into the constructor', () {
      final file = File(testPath);
      expect(file.path, equals(testPath));
    });

    test('stat() returns a FileStat with size 0', () async {
      final file = File(testPath);
      final stat = await file.stat();
      expect(stat, isA<FileStat>());
      expect(stat.size, equals(0));
    });

    test(
      'multiple calls to stat() yield independent FileStat instances',
      () async {
        final file = File(testPath);
        final stat1 = await file.stat();
        final stat2 = await file.stat();

        expect(stat1, isNot(same(stat2)));
        expect(stat1.size, equals(0));
        expect(stat2.size, equals(0));
      },
    );
  });

  group('FileStat stub', () {
    test('stores the size passed into the constructor', () {
      final stat = FileStat(12345);
      expect(stat.size, equals(12345));
    });

    test('size property is immutable', () {
      final stat = FileStat(999);
      // There's no setter, so just verify it stays the same
      expect(stat.size, equals(999));
    });
  });
}
