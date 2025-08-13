import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/providers/file_wrapper_io.dart';

@GenerateMocks([io.File, io.FileStat])
import 'file_wrapper_io_test.mocks.dart';

void main() {
  late IoFileWrapper fileWrapper;
  late MockFile mockFile;
  late MockFileStat mockFileStat;

  setUp(() {
    mockFile = MockFile();
    mockFileStat = MockFileStat();
    fileWrapper = IoFileWrapper(mockFile);
  });

  group('IoFileWrapper', () {
    const String testPath = '/test/path/file.txt';
    const String testContent = 'test content';
    final testBytes = [1, 2, 3, 4, 5];
    const int testFileSize = 1024;

    group('constructor', () {
      test('should initialize with provided io.File', () {
        // arrange
        final file = MockFile();

        // act
        final wrapper = IoFileWrapper(file);

        // assert
        expect(wrapper.raw, equals(file));
      });

      test('should work with different io.File instances', () {
        final files = [MockFile(), MockFile(), MockFile()];

        for (final file in files) {
          // act
          final wrapper = IoFileWrapper(file);

          // assert
          expect(wrapper.raw, equals(file));
          expect(wrapper.raw, isA<io.File>());
        }
      });
    });

    group('raw', () {
      test('should return the internal io.File instance', () {
        // act
        final result = fileWrapper.raw;

        // assert
        expect(result, equals(mockFile));
        expect(result, isA<io.File>());
      });

      test('should return same instance on multiple calls', () {
        // act
        final result1 = fileWrapper.raw;
        final result2 = fileWrapper.raw;

        // assert
        expect(result1, equals(result2));
        expect(result1, same(mockFile));
      });
    });

    group('path', () {
      test('should return path from io.File', () {
        // arrange
        when(mockFile.path).thenReturn(testPath);

        // act
        final result = fileWrapper.path;

        // assert
        expect(result, equals(testPath));
      });

      test('should handle different path formats', () {
        final testPaths = [
          '/absolute/unix/path',
          'relative/path',
          'C:\\Windows\\path',
          '/root/file.txt',
          'simple_file.txt',
          '',
        ];

        for (final path in testPaths) {
          // arrange
          when(mockFile.path).thenReturn(path);

          // act
          final result = fileWrapper.path;

          // assert
          expect(result, equals(path), reason: 'Failed for path: $path');
        }
      });

      test('should call path getter on io.File only when accessed', () {
        // arrange
        when(mockFile.path).thenReturn(testPath);

        // act
        final result = fileWrapper.path;

        // assert
        verify(mockFile.path).called(1);
        expect(result, equals(testPath));
      });
    });

    group('exists', () {
      test('should call exists on io.File and return result', () async {
        // arrange
        when(mockFile.exists()).thenAnswer((_) async => true);

        // act
        final result = await fileWrapper.exists();

        // assert
        verify(mockFile.exists()).called(1);
        expect(result, isTrue);
      });

      test('should return false when file does not exist', () async {
        // arrange
        when(mockFile.exists()).thenAnswer((_) async => false);

        // act
        final result = await fileWrapper.exists();

        // assert
        verify(mockFile.exists()).called(1);
        expect(result, isFalse);
      });

      test('should propagate exceptions from io.File', () async {
        // arrange
        when(
          mockFile.exists(),
        ).thenThrow(io.FileSystemException('Permission denied'));

        // act & assert
        expect(
          () async => await fileWrapper.exists(),
          throwsA(isA<io.FileSystemException>()),
        );
        verify(mockFile.exists()).called(1);
      });

      test('should handle different exception types', () async {
        final exceptions = [
          io.FileSystemException('Access denied'),
          Exception('Generic error'),
          ArgumentError('Invalid path'),
        ];

        for (final exception in exceptions) {
          // arrange
          when(mockFile.exists()).thenThrow(exception);

          // act & assert
          expect(
            () async => await fileWrapper.exists(),
            throwsA(equals(exception)),
          );
          verify(mockFile.exists()).called(1);

          // Reset for next iteration
          reset(mockFile);
        }
      });
    });

    group('length', () {
      test('should call stat on io.File and return size', () async {
        // arrange
        when(mockFile.stat()).thenAnswer((_) async => mockFileStat);
        when(mockFileStat.size).thenReturn(testFileSize);

        // act
        final result = await fileWrapper.length();

        // assert
        verify(mockFile.stat()).called(1);
        verify(mockFileStat.size).called(1);
        expect(result, equals(testFileSize));
      });

      test('should handle different file sizes', () async {
        final fileSizes = [0, 1, 100, 1024, 1048576, 2147483647]; // 0B to 2GB

        for (final size in fileSizes) {
          // arrange
          when(mockFile.stat()).thenAnswer((_) async => mockFileStat);
          when(mockFileStat.size).thenReturn(size);

          // act
          final result = await fileWrapper.length();

          // assert
          verify(mockFile.stat()).called(1);
          expect(result, equals(size), reason: 'Failed for file size: $size');

          // Reset for next iteration
          reset(mockFile);
          reset(mockFileStat);
        }
      });

      test('should propagate exceptions from io.File.stat()', () async {
        // arrange
        when(
          mockFile.stat(),
        ).thenThrow(io.FileSystemException('File not found'));

        // act & assert
        expect(
          () async => await fileWrapper.length(),
          throwsA(isA<io.FileSystemException>()),
        );
        verify(mockFile.stat()).called(1);
      });
    });

    group('readAsBytes', () {
      test('should call readAsBytes on io.File and return result', () async {
        // arrange
        when(
          mockFile.readAsBytes(),
        ).thenAnswer((_) async => Uint8List.fromList(testBytes));

        // act
        final result = await fileWrapper.readAsBytes();

        // assert
        verify(mockFile.readAsBytes()).called(1);
        expect(result, equals(testBytes));
      });

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
          when(mockFile.readAsBytes()).thenAnswer(
            (_) async => bytes is Uint8List ? bytes : Uint8List.fromList(bytes),
          );

          // act
          final result = await fileWrapper.readAsBytes();

          // assert
          verify(mockFile.readAsBytes()).called(1);
          expect(result, equals(bytes), reason: 'Failed for bytes: $bytes');

          // Reset for next iteration
          reset(mockFile);
        }
      });

      test('should propagate FileSystemException from io.File', () async {
        // arrange
        when(
          mockFile.readAsBytes(),
        ).thenThrow(io.FileSystemException('File not found'));

        // act & assert
        expect(
          () async => await fileWrapper.readAsBytes(),
          throwsA(isA<io.FileSystemException>()),
        );
        verify(mockFile.readAsBytes()).called(1);
      });

      test('should handle different exception types', () async {
        final exceptions = [
          io.FileSystemException('Permission denied'),
          Exception('Read error'),
          ArgumentError('Invalid argument'),
          OutOfMemoryError(),
        ];

        for (final exception in exceptions) {
          // arrange
          when(mockFile.readAsBytes()).thenThrow(exception);

          // act & assert
          expect(
            () async => await fileWrapper.readAsBytes(),
            throwsA(equals(exception)),
          );
          verify(mockFile.readAsBytes()).called(1);

          // Reset for next iteration
          reset(mockFile);
        }
      });
    });

    group('readAsString', () {
      test('should call readAsString on io.File and return result', () async {
        // arrange
        when(mockFile.readAsString()).thenAnswer((_) async => testContent);

        // act
        final result = await fileWrapper.readAsString();

        // assert
        verify(mockFile.readAsString()).called(1);
        expect(result, equals(testContent));
      });

      test('should handle different string contents', () async {
        final testContents = [
          '',
          'simple text',
          'text with special chars: àáâãäåæçèéêë',
          'multi\nline\ntext\nwith\nbreaks',
          'text with tabs\tand\tspaces   ',
          '{"json": "content", "number": 42}',
          '<xml><tag>content</tag></xml>',
          'Very long text content that spans multiple lines and contains various characters including emojis 🎉 and symbols @#\$%^&*()',
          '   content with leading and trailing spaces   ',
          'content\r\nwith\r\nwindows\r\nline\r\nendings',
        ];

        for (final content in testContents) {
          // arrange
          when(mockFile.readAsString()).thenAnswer((_) async => content);

          // act
          final result = await fileWrapper.readAsString();

          // assert
          verify(mockFile.readAsString()).called(1);
          expect(
            result,
            equals(content),
            reason: 'Failed for content: $content',
          );

          // Reset for next iteration
          reset(mockFile);
        }
      });

      test('should propagate FileSystemException from io.File', () async {
        // arrange
        when(
          mockFile.readAsString(),
        ).thenThrow(io.FileSystemException('Permission denied'));

        // act & assert
        expect(
          () async => await fileWrapper.readAsString(),
          throwsA(isA<io.FileSystemException>()),
        );
        verify(mockFile.readAsString()).called(1);
      });

      test('should handle different exception types', () async {
        final exceptions = [
          io.FileSystemException('File not found'),
          FormatException('Invalid encoding'),
          Exception('Read error'),
          ArgumentError('Invalid encoding'),
        ];

        for (final exception in exceptions) {
          // arrange
          when(mockFile.readAsString()).thenThrow(exception);

          // act & assert
          expect(
            () async => await fileWrapper.readAsString(),
            throwsA(equals(exception)),
          );
          verify(mockFile.readAsString()).called(1);

          // Reset for next iteration
          reset(mockFile);
        }
      });
    });

    group('writeAsBytes', () {
      test(
        'should call writeAsBytes on io.File with correct parameters',
        () async {
          // arrange
          when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);

          // act
          await fileWrapper.writeAsBytes(testBytes);

          // assert
          verify(mockFile.writeAsBytes(testBytes)).called(1);
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
          when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);

          // act
          await fileWrapper.writeAsBytes(bytes);

          // assert
          verify(mockFile.writeAsBytes(bytes)).called(1);

          // Reset for next iteration
          reset(mockFile);
        }
      });

      test('should propagate FileSystemException from io.File', () async {
        // arrange
        when(
          mockFile.writeAsBytes(any),
        ).thenThrow(io.FileSystemException('Disk full'));

        // act & assert
        expect(
          () async => await fileWrapper.writeAsBytes(testBytes),
          throwsA(isA<io.FileSystemException>()),
        );
        verify(mockFile.writeAsBytes(testBytes)).called(1);
      });

      test('should handle different exception types', () async {
        final exceptions = [
          io.FileSystemException('Permission denied'),
          Exception('Write error'),
          ArgumentError('Invalid bytes'),
        ];

        for (final exception in exceptions) {
          // arrange
          when(mockFile.writeAsBytes(any)).thenThrow(exception);

          // act & assert
          expect(
            () async => await fileWrapper.writeAsBytes(testBytes),
            throwsA(equals(exception)),
          );
          verify(mockFile.writeAsBytes(testBytes)).called(1);

          // Reset for next iteration
          reset(mockFile);
        }
      });

      test('should not return anything (void)', () async {
        // arrange
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);

        // act
        await fileWrapper.writeAsBytes(testBytes);

        // assert
        verify(mockFile.writeAsBytes(testBytes)).called(1);
      });
    });

    group('writeAsString', () {
      test(
        'should call writeAsString on io.File with correct parameters',
        () async {
          // arrange
          when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);

          // act
          await fileWrapper.writeAsString(testContent);

          // assert
          verify(mockFile.writeAsString(testContent)).called(1);
        },
      );

      test('should handle different string contents', () async {
        final testContents = [
          '',
          'simple text',
          'text with special chars: àáâãäåæçèéêë',
          'multi\nline\ntext\nwith\nbreaks',
          'text with tabs\tand\tspaces   ',
          '{"json": "content", "number": 42}',
          '<xml><tag>content</tag></xml>',
          'Very long text content that spans multiple lines and contains various characters including emojis 🎉 and symbols @#\$%^&*()',
          '   content with leading and trailing spaces   ',
          'content\r\nwith\r\nwindows\r\nline\r\nendings',
        ];

        for (final content in testContents) {
          // arrange
          when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);

          // act
          await fileWrapper.writeAsString(content);

          // assert
          verify(mockFile.writeAsString(content)).called(1);

          // Reset for next iteration
          reset(mockFile);
        }
      });

      test('should propagate FileSystemException from io.File', () async {
        // arrange
        when(
          mockFile.writeAsString(any),
        ).thenThrow(io.FileSystemException('Read-only file system'));

        // act & assert
        expect(
          () async => await fileWrapper.writeAsString(testContent),
          throwsA(isA<io.FileSystemException>()),
        );
        verify(mockFile.writeAsString(testContent)).called(1);
      });

      test('should handle different exception types', () async {
        final exceptions = [
          io.FileSystemException('Permission denied'),
          Exception('Write error'),
          ArgumentError('Invalid encoding'),
        ];

        for (final exception in exceptions) {
          // arrange
          when(mockFile.writeAsString(any)).thenThrow(exception);

          // act & assert
          expect(
            () async => await fileWrapper.writeAsString(testContent),
            throwsA(equals(exception)),
          );
          verify(mockFile.writeAsString(testContent)).called(1);

          // Reset for next iteration
          reset(mockFile);
        }
      });

      test('should not return anything (void)', () async {
        // arrange
        when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);

        // act
        await fileWrapper.writeAsString(testContent);

        // assert
        verify(mockFile.writeAsString(testContent)).called(1);
      });
    });

    group('integration scenarios', () {
      test('should handle sequential operations', () async {
        // arrange
        when(mockFile.path).thenReturn(testPath);
        when(mockFile.exists()).thenAnswer((_) async => true);
        when(mockFile.stat()).thenAnswer((_) async => mockFileStat);
        when(mockFileStat.size).thenReturn(testFileSize);
        when(mockFile.readAsString()).thenAnswer((_) async => testContent);
        when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);

        // act
        final path = fileWrapper.path;
        final exists = await fileWrapper.exists();
        final length = await fileWrapper.length();
        final content = await fileWrapper.readAsString();
        await fileWrapper.writeAsString('new content');

        // assert
        expect(path, equals(testPath));
        expect(exists, isTrue);
        expect(length, equals(testFileSize));
        expect(content, equals(testContent));

        verify(mockFile.path).called(1);
        verify(mockFile.exists()).called(1);
        verify(mockFile.stat()).called(1);
        verify(mockFile.readAsString()).called(1);
        verify(mockFile.writeAsString('new content')).called(1);
      });

      test('should handle bytes and string operations', () async {
        const newContent = 'updated content';
        final newBytes = [10, 20, 30];

        // arrange
        when(
          mockFile.readAsBytes(),
        ).thenAnswer((_) async => Uint8List.fromList(testBytes));
        when(mockFile.readAsString()).thenAnswer((_) async => testContent);
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);
        when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);

        // act
        final originalBytes = await fileWrapper.readAsBytes();
        final originalString = await fileWrapper.readAsString();
        await fileWrapper.writeAsBytes(newBytes);
        await fileWrapper.writeAsString(newContent);

        // assert
        expect(originalBytes, equals(testBytes));
        expect(originalString, equals(testContent));

        verify(mockFile.readAsBytes()).called(1);
        verify(mockFile.readAsString()).called(1);
        verify(mockFile.writeAsBytes(newBytes)).called(1);
        verify(mockFile.writeAsString(newContent)).called(1);
      });

      test(
        'should maintain reference to same io.File throughout operations',
        () async {
          // arrange
          when(mockFile.path).thenReturn(testPath);
          when(mockFile.exists()).thenAnswer((_) async => true);

          // act
          final raw1 = fileWrapper.raw;
          final path = fileWrapper.path;
          await fileWrapper.exists();
          final raw2 = fileWrapper.raw;

          // assert
          expect(raw1, same(mockFile));
          expect(raw2, same(mockFile));
          expect(raw1, same(raw2));
          expect(path, equals(testPath));
        },
      );
    });

    group('edge cases', () {
      test('should handle empty file operations', () async {
        const emptyContent = '';
        const emptyBytes = <int>[];

        // arrange
        when(mockFile.stat()).thenAnswer((_) async => mockFileStat);
        when(mockFileStat.size).thenReturn(0);
        when(mockFile.readAsString()).thenAnswer((_) async => emptyContent);
        when(
          mockFile.readAsBytes(),
        ).thenAnswer((_) async => Uint8List.fromList(emptyBytes));
        when(mockFile.writeAsString(any)).thenAnswer((_) async => mockFile);
        when(mockFile.writeAsBytes(any)).thenAnswer((_) async => mockFile);

        // act
        final length = await fileWrapper.length();
        final content = await fileWrapper.readAsString();
        final bytes = await fileWrapper.readAsBytes();
        await fileWrapper.writeAsString(emptyContent);
        await fileWrapper.writeAsBytes(emptyBytes);

        // assert
        expect(length, equals(0));
        expect(content, equals(emptyContent));
        expect(bytes, equals(emptyBytes));

        verify(mockFile.readAsString()).called(1);
        verify(mockFile.readAsBytes()).called(1);
        verify(mockFile.writeAsString(emptyContent)).called(1);
        verify(mockFile.writeAsBytes(emptyBytes)).called(1);
      });

      test('should handle null or special path values', () async {
        final specialPaths = ['', '/', '.', '..', '/dev/null'];

        for (final path in specialPaths) {
          // arrange
          when(mockFile.path).thenReturn(path);

          // act
          final result = fileWrapper.path;

          // assert
          expect(result, equals(path), reason: 'Failed for path: $path');
        }
      });
    });
  });
}
