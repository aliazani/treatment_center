import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/providers/file_provider_io.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';
import 'package:treatment_center/core/providers/file_wrapper_io.dart';

@GenerateMocks([FileWrapper, File])
import 'file_provider_io_test.mocks.dart';

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
    final testBytesAsList = [1, 2, 3, 4, 5];

    group('getFile', () {
      test('should return IoFileWrapper with correct file path', () async {
        // act
        final result = await fileProvider.getFile(testPath);

        // assert
        expect(result, isA<IoFileWrapper>());
        // Note: We can't easily test the internal File object without exposing it
        // This test verifies the correct type is returned
      });

      test('should return IoFileWrapper for different path formats', () async {
        const paths = [
          '/absolute/path/file.txt',
          'relative/path/file.txt',
          'C:\\Windows\\path\\file.txt',
          'single_file.txt',
          '/root/file',
        ];

        for (final path in paths) {
          // act
          final result = await fileProvider.getFile(path);

          // assert
          expect(
            result,
            isA<IoFileWrapper>(),
            reason: 'Should return IoFileWrapper for path: $path',
          );
        }
      });

      test('should handle empty path', () async {
        // act
        final result = await fileProvider.getFile('');

        // assert
        expect(result, isA<IoFileWrapper>());
      });
    });

    group('readAsBytes', () {
      test(
        'should call readAsBytes on file wrapper and return Uint8List',
        () async {
          // arrange
          when(
            mockFileWrapper.readAsBytes(),
          ).thenAnswer((_) async => testBytesAsList);

          // act
          final result = await fileProvider.readAsBytes(mockFileWrapper);

          // assert
          verify(mockFileWrapper.readAsBytes()).called(1);
          expect(result, isA<Uint8List>());
          expect(result, equals(Uint8List.fromList(testBytesAsList)));
        },
      );

      test('should convert List<int> to Uint8List correctly', () async {
        final differentBytes = [255, 0, 128, 64, 192];

        // arrange
        when(
          mockFileWrapper.readAsBytes(),
        ).thenAnswer((_) async => differentBytes);

        // act
        final result = await fileProvider.readAsBytes(mockFileWrapper);

        // assert
        expect(result, equals(Uint8List.fromList(differentBytes)));
        expect(result, isA<Uint8List>());
      });

      test('should handle empty byte array', () async {
        const emptyBytes = <int>[];

        // arrange
        when(mockFileWrapper.readAsBytes()).thenAnswer((_) async => emptyBytes);

        // act
        final result = await fileProvider.readAsBytes(mockFileWrapper);

        // assert
        verify(mockFileWrapper.readAsBytes()).called(1);
        expect(result, equals(Uint8List.fromList(emptyBytes)));
        expect(result.length, equals(0));
      });

      test('should propagate FileSystemException from file wrapper', () async {
        // arrange
        when(
          mockFileWrapper.readAsBytes(),
        ).thenThrow(const FileSystemException('File not found'));

        // act & assert
        expect(
          () async => await fileProvider.readAsBytes(mockFileWrapper),
          throwsA(isA<FileSystemException>()),
        );
        verify(mockFileWrapper.readAsBytes()).called(1);
      });

      test('should handle large byte arrays', () async {
        final largeBytes = List.generate(10000, (i) => i % 256);

        // arrange
        when(mockFileWrapper.readAsBytes()).thenAnswer((_) async => largeBytes);

        // act
        final result = await fileProvider.readAsBytes(mockFileWrapper);

        // assert
        verify(mockFileWrapper.readAsBytes()).called(1);
        expect(result, equals(Uint8List.fromList(largeBytes)));
        expect(result.length, equals(10000));
      });
    });

    group('readAsString', () {
      test(
        'should call readAsString on file wrapper and return content',
        () async {
          // arrange
          when(
            mockFileWrapper.readAsString(),
          ).thenAnswer((_) async => testContent);

          // act
          final result = await fileProvider.readAsString(mockFileWrapper);

          // assert
          verify(mockFileWrapper.readAsString()).called(1);
          expect(result, equals(testContent));
        },
      );

      test('should handle different string contents', () async {
        final testCases = [
          '',
          'simple text',
          'text with special chars: àáâãäåæçèéêë',
          'multi\nline\ntext\nwith\nbreaks',
          'text with tabs\tand\tspaces   ',
          '{"json": "content", "number": 42}',
          '<xml><tag>content</tag></xml>',
          'Very long text content that spans multiple lines and contains various characters including emojis 🎉 and symbols @#\$%^&*()',
        ];

        for (final content in testCases) {
          // arrange
          when(mockFileWrapper.readAsString()).thenAnswer((_) async => content);

          // act
          final result = await fileProvider.readAsString(mockFileWrapper);

          // assert
          verify(mockFileWrapper.readAsString()).called(1);
          expect(
            result,
            equals(content),
            reason: 'Failed for content: $content',
          );

          // Reset for next iteration
          reset(mockFileWrapper);
        }
      });

      test('should propagate FileSystemException from file wrapper', () async {
        // arrange
        when(
          mockFileWrapper.readAsString(),
        ).thenThrow(const FileSystemException('Permission denied'));

        // act & assert
        expect(
          () async => await fileProvider.readAsString(mockFileWrapper),
          throwsA(isA<FileSystemException>()),
        );
        verify(mockFileWrapper.readAsString()).called(1);
      });

      test('should propagate other exceptions from file wrapper', () async {
        // arrange
        when(
          mockFileWrapper.readAsString(),
        ).thenThrow(Exception('Custom error'));

        // act & assert
        expect(
          () async => await fileProvider.readAsString(mockFileWrapper),
          throwsA(isA<Exception>()),
        );
        verify(mockFileWrapper.readAsString()).called(1);
      });
    });

    group('writeAsBytes', () {
      test(
        'should call writeAsBytes on file wrapper and return same file',
        () async {
          // arrange
          when(
            mockFileWrapper.writeAsBytes(any),
          ).thenAnswer((_) async => Future.value());

          // act
          final result = await fileProvider.writeAsBytes(
            mockFileWrapper,
            testBytesAsList,
          );

          // assert
          verify(mockFileWrapper.writeAsBytes(testBytesAsList)).called(1);
          expect(result, equals(mockFileWrapper));
        },
      );

      test('should handle different byte arrays', () async {
        final testByteArrays = [
          <int>[],
          [1],
          [255, 0, 128],
          [1, 2, 3, 4, 5],
          List.generate(1000, (i) => i % 256),
          Uint8List.fromList([100, 200, 50]),
        ];

        for (final bytes in testByteArrays) {
          // arrange
          when(
            mockFileWrapper.writeAsBytes(any),
          ).thenAnswer((_) async => Future.value());

          // act
          final result = await fileProvider.writeAsBytes(
            mockFileWrapper,
            bytes,
          );

          // assert
          verify(mockFileWrapper.writeAsBytes(bytes)).called(1);
          expect(result, equals(mockFileWrapper));

          // Reset for next iteration
          reset(mockFileWrapper);
        }
      });

      test('should propagate FileSystemException from file wrapper', () async {
        // arrange
        when(
          mockFileWrapper.writeAsBytes(any),
        ).thenThrow(const FileSystemException('Disk full'));

        // act & assert
        expect(
          () async =>
              await fileProvider.writeAsBytes(mockFileWrapper, testBytesAsList),
          throwsA(isA<FileSystemException>()),
        );
        verify(mockFileWrapper.writeAsBytes(testBytesAsList)).called(1);
      });

      test('should handle Uint8List input', () async {
        final uint8ListInput = Uint8List.fromList([10, 20, 30]);

        // arrange
        when(
          mockFileWrapper.writeAsBytes(any),
        ).thenAnswer((_) async => Future.value());

        // act
        final result = await fileProvider.writeAsBytes(
          mockFileWrapper,
          uint8ListInput,
        );

        // assert
        verify(mockFileWrapper.writeAsBytes(uint8ListInput)).called(1);
        expect(result, equals(mockFileWrapper));
      });
    });

    group('writeAsString', () {
      test(
        'should call writeAsString on file wrapper and return same file',
        () async {
          // arrange
          when(
            mockFileWrapper.writeAsString(any),
          ).thenAnswer((_) async => Future.value());

          // act
          final result = await fileProvider.writeAsString(
            mockFileWrapper,
            testContent,
          );

          // assert
          verify(mockFileWrapper.writeAsString(testContent)).called(1);
          expect(result, equals(mockFileWrapper));
        },
      );

      test('should handle different string contents', () async {
        final testContents = [
          '',
          'simple text',
          'text with special chars: àáâãäåæçèéêë',
          'multi\nline\ntext\nwith\nbreaks',
          'text with tabs\tand\tspaces   ',
          '{"json": "content", "number": 42, "array": [1,2,3]}',
          '<xml><parent><child>nested content</child></parent></xml>',
          'Very long text content that spans multiple lines and contains various characters including emojis 🎉 and symbols @#\$%^&*()',
          '   content with leading and trailing spaces   ',
        ];

        for (final content in testContents) {
          // arrange
          when(
            mockFileWrapper.writeAsString(any),
          ).thenAnswer((_) async => Future.value());

          // act
          final result = await fileProvider.writeAsString(
            mockFileWrapper,
            content,
          );

          // assert
          verify(mockFileWrapper.writeAsString(content)).called(1);
          expect(
            result,
            equals(mockFileWrapper),
            reason: 'Failed for content: $content',
          );

          // Reset for next iteration
          reset(mockFileWrapper);
        }
      });

      test('should propagate FileSystemException from file wrapper', () async {
        // arrange
        when(
          mockFileWrapper.writeAsString(any),
        ).thenThrow(const FileSystemException('Read-only file system'));

        // act & assert
        expect(
          () async =>
              await fileProvider.writeAsString(mockFileWrapper, testContent),
          throwsA(isA<FileSystemException>()),
        );
        verify(mockFileWrapper.writeAsString(testContent)).called(1);
      });

      test('should propagate other exceptions from file wrapper', () async {
        // arrange
        when(
          mockFileWrapper.writeAsString(any),
        ).thenThrow(ArgumentError('Invalid encoding'));

        // act & assert
        expect(
          () async =>
              await fileProvider.writeAsString(mockFileWrapper, testContent),
          throwsA(isA<ArgumentError>()),
        );
        verify(mockFileWrapper.writeAsString(testContent)).called(1);
      });
    });

    group('integration scenarios', () {
      test('should handle sequential read and write operations', () async {
        const writeContent = 'content to write';
        const readContent = 'content that was read';

        // arrange
        when(
          mockFileWrapper.writeAsString(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockFileWrapper.readAsString(),
        ).thenAnswer((_) async => readContent);

        // act
        final writeResult = await fileProvider.writeAsString(
          mockFileWrapper,
          writeContent,
        );
        final readResult = await fileProvider.readAsString(mockFileWrapper);

        // assert
        verify(mockFileWrapper.writeAsString(writeContent)).called(1);
        verify(mockFileWrapper.readAsString()).called(1);
        expect(writeResult, equals(mockFileWrapper));
        expect(readResult, equals(readContent));
      });

      test('should handle bytes and string operations on same file', () async {
        final writeBytes = [72, 101, 108, 108, 111]; // "Hello" in ASCII
        const readString = 'Hello';

        // arrange
        when(
          mockFileWrapper.writeAsBytes(any),
        ).thenAnswer((_) async => Future.value());
        when(
          mockFileWrapper.readAsString(),
        ).thenAnswer((_) async => readString);

        // act
        final writeResult = await fileProvider.writeAsBytes(
          mockFileWrapper,
          writeBytes,
        );
        final readResult = await fileProvider.readAsString(mockFileWrapper);

        // assert
        verify(mockFileWrapper.writeAsBytes(writeBytes)).called(1);
        verify(mockFileWrapper.readAsString()).called(1);
        expect(writeResult, equals(mockFileWrapper));
        expect(readResult, equals(readString));
      });
    });
  });
}
