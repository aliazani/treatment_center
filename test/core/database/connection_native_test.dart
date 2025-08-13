import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:treatment_center/core/database/app_database.dart';

import 'package:treatment_center/core/database/connection_native.dart'
    show openConnection;

void main() {
  late PathProviderPlatform originalProvider;
  late Directory tempDir;

  setUp(() async {
    originalProvider = PathProviderPlatform.instance;
    tempDir = await Directory.systemTemp.createTemp('open_connection_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir);
  });

  tearDown(() async {
    PathProviderPlatform.instance = originalProvider;
    if (tempDir.existsSync()) await tempDir.delete(recursive: true);
  });

  test('openConnection surfaces failure from LazyDatabase', () async {
    // arrange
    PathProviderPlatform.instance = _FailingPathProvider();

    // act & assert
    expect(() async {
      final exec = openConnection();
      await DatabaseConnection(exec).executor.runSelect('SELECT 1;', const []);
    }, throwsA(isA<Error>()));
  });

  test('openConnection surfaces path-provider errors', () {
    // arrange
    PathProviderPlatform.instance = _FailingPathProvider();
    // act
    final exec = openConnection();
    final db = DatabaseConnection(exec);

    // assert
    expect(
      () async => await db.executor.ensureOpen(MockQueryExecutorUser()),
      throwsA(isA<FileSystemException>()),
    );
  });

  test(
    'openConnection creates the DB file and runs queries via the background executor',
    () async {
      // arrange
      final exec = openConnection();
      final appDb = AppDatabase.forTesting(exec);

      // act
      await appDb.executor.ensureOpen(appDb);

      final rows = await appDb.executor.runSelect(
        'SELECT 123 AS theAnswer;',
        const [],
      );
      // assert
      expect(rows.single['theAnswer'], 123);
      final dbFile = File(p.join(tempDir.path, 'treatment_center.db'));
      expect(
        dbFile.existsSync(),
        isTrue,
        reason: 'The DB file should have been created',
      );

      // cleanup
      await appDb.close();
    },
  );
}

class MockQueryExecutorUser extends Mock implements QueryExecutorUser {}

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.tempDir);
  final Directory tempDir;

  @override
  Future<String?> getApplicationDocumentsPath() async => tempDir.path;
}

class _FailingPathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async =>
      throw const FileSystemException('documents directory unavailable');
}
