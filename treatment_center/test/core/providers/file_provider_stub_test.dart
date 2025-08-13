import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/providers/file_provider_stub.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';

class MockFileWrapper extends Mock implements FileWrapper {}

void main() {
  late FileProviderImpl fileProvider;
  late MockFileWrapper mockFileWrapper;

  setUp(() {
    fileProvider = FileProviderImpl();
    mockFileWrapper = MockFileWrapper();
  });

  group('FileProviderImpl', () {
    const String testPath = '/test/path/file.txt';
    const String testContent = 'test content';
    final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
    const String expectedErrorMessage =
        'File operations are not supported here.';

    group('getFile', () {
      test('should throw UnsupportedError with correct message', () async {
        // act & assert
        expect(
          () async => await fileProvider.getFile(testPath),
          throwsA(
            predicate(
              (e) => e is UnsupportedError && e.message == expectedErrorMessage,
            ),
          ),
        );
      });

      test('should throw UnsupportedError for any path input', () async {
        const paths = [
          '/different/path',
          'relative/path',
          'C:\\Windows\\path',
          '',
          '/',
        ];

        for (final path in paths) {
          expect(
            () async => await fileProvider.getFile(path),
            throwsA(isA<UnsupportedError>()),
            reason: 'Should throw UnsupportedError for path: $path',
          );
        }
      });
    });

    group('readAsBytes', () {
      test('should throw UnsupportedError with correct message', () async {
        // act & assert
        expect(
          () async => await fileProvider.readAsBytes(mockFileWrapper),
          throwsA(
            predicate(
              (e) => e is UnsupportedError && e.message == expectedErrorMessage,
            ),
          ),
        );
      });

      test('should throw UnsupportedError for any FileWrapper input', () async {
        final wrappers = [
          mockFileWrapper,
          MockFileWrapper(),
          MockFileWrapper(),
        ];

        for (final wrapper in wrappers) {
          expect(
            () async => await fileProvider.readAsBytes(wrapper),
            throwsA(isA<UnsupportedError>()),
            reason: 'Should throw UnsupportedError for any FileWrapper',
          );
        }
      });
    });

    group('readAsString', () {
      test('should throw UnsupportedError with correct message', () async {
        // act & assert
        expect(
          () async => await fileProvider.readAsString(mockFileWrapper),
          throwsA(
            predicate(
              (e) => e is UnsupportedError && e.message == expectedErrorMessage,
            ),
          ),
        );
      });

      test('should throw UnsupportedError for any FileWrapper input', () async {
        final wrappers = [
          mockFileWrapper,
          MockFileWrapper(),
          MockFileWrapper(),
        ];

        for (final wrapper in wrappers) {
          expect(
            () async => await fileProvider.readAsString(wrapper),
            throwsA(isA<UnsupportedError>()),
            reason: 'Should throw UnsupportedError for any FileWrapper',
          );
        }
      });
    });

    group('writeAsBytes', () {
      test('should throw UnsupportedError with correct message', () async {
        // act & assert
        expect(
          () async =>
              await fileProvider.writeAsBytes(mockFileWrapper, testBytes),
          throwsA(
            predicate(
              (e) => e is UnsupportedError && e.message == expectedErrorMessage,
            ),
          ),
        );
      });

      test('should throw UnsupportedError for any input combination', () async {
        final testData = [
          {'wrapper': mockFileWrapper, 'bytes': testBytes},
          {'wrapper': MockFileWrapper(), 'bytes': Uint8List.fromList([])},
          {
            'wrapper': MockFileWrapper(),
            'bytes': Uint8List.fromList([255, 0, 128]),
          },
        ];

        for (final data in testData) {
          expect(
            () async => await fileProvider.writeAsBytes(
              data['wrapper'] as FileWrapper,
              data['bytes'] as List<int>,
            ),
            throwsA(isA<UnsupportedError>()),
            reason: 'Should throw UnsupportedError for any input combination',
          );
        }
      });

      test(
        'should throw UnsupportedError with different byte arrays',
        () async {
          final byteArrays = [
            <int>[],
            [1],
            [1, 2, 3, 4, 5],
            List.generate(1000, (i) => i % 256),
          ];

          for (final bytes in byteArrays) {
            expect(
              () async =>
                  await fileProvider.writeAsBytes(mockFileWrapper, bytes),
              throwsA(isA<UnsupportedError>()),
              reason: 'Should throw UnsupportedError for bytes: $bytes',
            );
          }
        },
      );
    });

    group('writeAsString', () {
      test('should throw UnsupportedError with correct message', () async {
        // act & assert
        expect(
          () async =>
              await fileProvider.writeAsString(mockFileWrapper, testContent),
          throwsA(
            predicate(
              (e) => e is UnsupportedError && e.message == expectedErrorMessage,
            ),
          ),
        );
      });

      test('should throw UnsupportedError for any input combination', () async {
        final testData = [
          {'wrapper': mockFileWrapper, 'content': testContent},
          {'wrapper': MockFileWrapper(), 'content': ''},
          {'wrapper': MockFileWrapper(), 'content': 'different content'},
          {
            'wrapper': MockFileWrapper(),
            'content': 'content with\nnewlines\tand\ttabs',
          },
        ];

        for (final data in testData) {
          expect(
            () async => await fileProvider.writeAsString(
              data['wrapper'] as FileWrapper,
              data['content'] as String,
            ),
            throwsA(isA<UnsupportedError>()),
            reason: 'Should throw UnsupportedError for any input combination',
          );
        }
      });

      test(
        'should throw UnsupportedError with different string contents',
        () async {
          final contents = [
            '',
            'simple text',
            'text with special chars: àáâãäåæçèéêë',
            'multi\nline\ntext',
            'text with tabs\tand\tspaces',
            '{"json": "content"}',
            '<xml>content</xml>',
          ];

          for (final content in contents) {
            expect(
              () async =>
                  await fileProvider.writeAsString(mockFileWrapper, content),
              throwsA(isA<UnsupportedError>()),
              reason: 'Should throw UnsupportedError for content: $content',
            );
          }
        },
      );
    });
  });
}
