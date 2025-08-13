import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:treatment_center/core/providers/file_wrapper_web.dart';
import 'package:treatment_center/core/providers/web_file.dart';

@GenerateMocks([WebFile])
import 'file_wrapper_web_test.mocks.dart';

void main() {
  late WebFileWrapper fileWrapper;
  late MockWebFile mockWebFile;

  setUp(() {
    mockWebFile = MockWebFile();
  });

  group('WebFileWrapper', () {
    const String testName = 'test_file.txt';
    final testBytes = Uint8List.fromList([
      116,
      101,
      115,
      116,
    ]); // "test" in UTF-8

    group('constructor', () {
      test('should initialize with provided web.File, name, and bytes', () {
        // act
        final wrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // assert
        expect(wrapper.raw, equals(mockWebFile));
        expect(wrapper.path, equals(testName));
      });

      test('should work with different parameter combinations', () {
        final testCases = [
          {
            'name': 'document.pdf',
            'bytes': Uint8List.fromList([1, 2, 3, 4]),
          },
          {'name': 'empty_file.txt', 'bytes': Uint8List.fromList([])},
          {
            'name': 'special chars: àáâã.txt',
            'bytes': Uint8List.fromList([195, 160, 195, 161]), // àá in UTF-8
          },
          {
            'name': '',
            'bytes': Uint8List.fromList([255, 0, 128]),
          },
        ];

        for (final testCase in testCases) {
          // act
          final wrapper = WebFileWrapper(
            mockWebFile,
            name: testCase['name'] as String,
            bytes: testCase['bytes'] as Uint8List,
          );

          // assert
          expect(wrapper.raw, equals(mockWebFile));
          expect(wrapper.path, equals(testCase['name']));
        }
      });

      test('should copy bytes parameter to internal storage', () async {
        final originalBytes = Uint8List.fromList([1, 2, 3]);

        // act
        final wrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: originalBytes,
        );

        // Modify original bytes to verify independence
        originalBytes[0] = 99;

        final result = await wrapper.readAsBytes();

        // assert
        expect(
          result,
          equals([1, 2, 3]),
        ); // Should not be affected by originalBytes modification
      });
    });

    group('raw', () {
      test('should return the internal web.File instance', () {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act
        final result = fileWrapper.raw;

        // assert
        expect(result, equals(mockWebFile));
        expect(result, isA<WebFile>());
      });

      test('should return same instance on multiple calls', () {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act
        final result1 = fileWrapper.raw;
        final result2 = fileWrapper.raw;

        // assert
        expect(result1, equals(result2));
        expect(result1, same(mockWebFile));
      });
    });

    group('path', () {
      test('should return the name provided in constructor', () {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act
        final result = fileWrapper.path;

        // assert
        expect(result, equals(testName));
      });

      test('should handle different name formats', () {
        final testNames = [
          'simple_file.txt',
          'file with spaces.pdf',
          'file-with-dashes.doc',
          'file.with.dots.txt',
          'special_chars_àáâã.txt',
          '123456.bin',
          '',
          'very_long_filename_that_exceeds_normal_expectations.extension',
        ];

        for (final name in testNames) {
          // arrange
          final wrapper = WebFileWrapper(
            mockWebFile,
            name: name,
            bytes: testBytes,
          );

          // act
          final result = wrapper.path;

          // assert
          expect(result, equals(name), reason: 'Failed for name: $name');
        }
      });
    });

    group('exists', () {
      test('should always return true', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act
        final result = await fileWrapper.exists();

        // assert
        expect(result, isTrue);
      });

      test('should return true regardless of file state', () async {
        final testCases = [
          {'name': 'existing_file.txt', 'bytes': testBytes},
          {'name': '', 'bytes': Uint8List.fromList([])},
          {
            'name': 'non_existent.txt',
            'bytes': Uint8List.fromList([1, 2, 3]),
          },
        ];

        for (final testCase in testCases) {
          // arrange
          final wrapper = WebFileWrapper(
            mockWebFile,
            name: testCase['name'] as String,
            bytes: testCase['bytes'] as Uint8List,
          );

          // act
          final result = await wrapper.exists();

          // assert
          expect(result, isTrue, reason: 'Should always return true');
        }
      });

      test('should return true on multiple calls', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act
        final result1 = await fileWrapper.exists();
        final result2 = await fileWrapper.exists();
        final result3 = await fileWrapper.exists();

        // assert
        expect(result1, isTrue);
        expect(result2, isTrue);
        expect(result3, isTrue);
      });
    });

    group('length', () {
      test('should return length of internal bytes', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act
        final result = await fileWrapper.length();

        // assert
        expect(result, equals(testBytes.length));
      });

      test('should handle different byte array sizes', () async {
        final testCases = [
          Uint8List.fromList([]), // 0 bytes
          Uint8List.fromList([1]), // 1 byte
          Uint8List.fromList([1, 2, 3, 4, 5]), // 5 bytes
          Uint8List.fromList(List.generate(100, (i) => i % 256)), // 100 bytes
          Uint8List.fromList(List.generate(10000, (i) => i % 256)), // 10K bytes
        ];

        for (final bytes in testCases) {
          // arrange
          final wrapper = WebFileWrapper(
            mockWebFile,
            name: testName,
            bytes: bytes,
          );

          // act
          final result = await wrapper.length();

          // assert
          expect(
            result,
            equals(bytes.length),
            reason: 'Failed for ${bytes.length} bytes',
          );
        }
      });

      test('should update length after write operations', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        // act & assert - initial length
        expect(await fileWrapper.length(), equals(3));

        // act - write new bytes
        await fileWrapper.writeAsBytes([1, 2, 3, 4, 5]);

        // assert - length should update
        expect(await fileWrapper.length(), equals(5));

        // act - write string
        await fileWrapper.writeAsString('hello');

        // assert - length should reflect string length
        expect(await fileWrapper.length(), equals('hello'.codeUnits.length));
      });
    });

    group('readAsBytes', () {
      test('should return internal bytes', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act
        final result = await fileWrapper.readAsBytes();

        // assert
        expect(result, equals(testBytes));
      });

      test('should handle different byte arrays', () async {
        final testByteArrays = [
          Uint8List.fromList([]),
          Uint8List.fromList([1]),
          Uint8List.fromList([255, 0, 128]),
          Uint8List.fromList([1, 2, 3, 4, 5]),
          Uint8List.fromList(List.generate(1000, (i) => i % 256)),
        ];

        for (final bytes in testByteArrays) {
          // arrange
          final wrapper = WebFileWrapper(
            mockWebFile,
            name: testName,
            bytes: bytes,
          );

          // act
          final result = await wrapper.readAsBytes();

          // assert
          expect(result, equals(bytes), reason: 'Failed for bytes: $bytes');
        }
      });

      test('should return updated bytes after write operations', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        // act & assert - initial bytes
        expect(await fileWrapper.readAsBytes(), equals([1, 2, 3]));

        // act - write new bytes
        final newBytes = [4, 5, 6, 7];
        await fileWrapper.writeAsBytes(newBytes);

        // assert - should return new bytes
        expect(await fileWrapper.readAsBytes(), equals(newBytes));
      });
    });

    group('readAsString', () {
      test(
        'should convert internal bytes to string using fromCharCodes',
        () async {
          // arrange
          final helloBytes = Uint8List.fromList([
            72,
            101,
            108,
            108,
            111,
          ]); // "Hello"
          fileWrapper = WebFileWrapper(
            mockWebFile,
            name: testName,
            bytes: helloBytes,
          );

          // act
          final result = await fileWrapper.readAsString();

          // assert
          expect(result, equals('Hello'));
        },
      );

      test('should return updated string after write operations', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList('initial'.codeUnits),
        );

        // act & assert - initial string
        expect(await fileWrapper.readAsString(), equals('initial'));

        // act - write new string
        await fileWrapper.writeAsString('updated');

        // assert - should return new string
        expect(await fileWrapper.readAsString(), equals('updated'));
      });

      test('should handle special characters', () async {
        final testStrings = [
          'Hello World!',
          'Text with spaces   ',
          'Multi\nLine\nText',
          'Tab\tSeparated\tValues',
          'Special: @#\$%^&*()',
          '   Leading and trailing spaces   ',
        ];

        for (final str in testStrings) {
          // arrange
          final wrapper = WebFileWrapper(
            mockWebFile,
            name: testName,
            bytes: Uint8List.fromList(str.codeUnits),
          );

          // act
          final result = await wrapper.readAsString();

          // assert
          expect(result, equals(str), reason: 'Failed for string: $str');
        }
      });
    });

    group('writeAsBytes', () {
      test('should update internal bytes with provided bytes', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([1, 2, 3]),
        );
        final newBytes = [4, 5, 6, 7, 8];

        // act
        await fileWrapper.writeAsBytes(newBytes);

        // assert
        final result = await fileWrapper.readAsBytes();
        expect(result, equals(newBytes));
      });

      test('should handle different byte array types', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([]),
        );

        final testByteArrays = [
          <int>[],
          [1],
          [255, 0, 128],
          [1, 2, 3, 4, 5],
          Uint8List.fromList([100, 200, 50]),
          List.generate(100, (i) => i % 256),
        ];

        for (final bytes in testByteArrays) {
          // act
          await fileWrapper.writeAsBytes(bytes);

          // assert
          final result = await fileWrapper.readAsBytes();
          expect(result, equals(bytes), reason: 'Failed for bytes: $bytes');
        }
      });

      test('should convert List<int> to Uint8List internally', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([]),
        );
        final regularList = [1, 2, 3, 4, 5];

        // act
        await fileWrapper.writeAsBytes(regularList);

        // assert
        final result = await fileWrapper.readAsBytes();
        expect(result, isA<Uint8List>());
        expect(result, equals(regularList));
      });

      test('should update length after write', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        // act
        await fileWrapper.writeAsBytes([1, 2, 3, 4, 5, 6, 7]);

        // assert
        expect(await fileWrapper.length(), equals(7));
      });

      test('should not return anything (void)', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([]),
        );

        // act
        await fileWrapper.writeAsBytes([1, 2, 3]);

        // assert
        // No return value to check, just ensure no error is thrown
      });
    });

    group('writeAsString', () {
      test(
        'should convert string to bytes using codeUnits and update internal bytes',
        () async {
          // arrange
          fileWrapper = WebFileWrapper(
            mockWebFile,
            name: testName,
            bytes: Uint8List.fromList([]),
          );
          const newContent = 'Hello World';

          // act
          await fileWrapper.writeAsString(newContent);

          // assert
          final resultBytes = await fileWrapper.readAsBytes();
          final expectedBytes = newContent.codeUnits;
          expect(resultBytes, equals(expectedBytes));

          final resultString = await fileWrapper.readAsString();
          expect(resultString, equals(newContent));
        },
      );

      test('should handle different string contents', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([]),
        );

        final testStrings = [
          '',
          'a',
          'Hello World',
          'Text with\nnewlines',
          'Text with\ttabs',
          'Special chars: @#\$%^&*()',
          '   Spaces everywhere   ',
          '123456789',
          'Multi\nLine\nText\nContent',
        ];

        for (final str in testStrings) {
          // act
          await fileWrapper.writeAsString(str);

          // assert
          final result = await fileWrapper.readAsString();
          expect(result, equals(str), reason: 'Failed for string: $str');

          final resultBytes = await fileWrapper.readAsBytes();
          expect(
            resultBytes,
            equals(str.codeUnits),
            reason: 'Bytes mismatch for: $str',
          );
        }
      });

      test('should update length after write', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([1, 2, 3]),
        );
        const newContent = 'Hello World';

        // act
        await fileWrapper.writeAsString(newContent);

        // assert
        expect(await fileWrapper.length(), equals(newContent.codeUnits.length));
      });

      test('should not return anything (void)', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([]),
        );

        // act
        // assert
        // No return value to check, just ensure no error is thrown
      });

      test(
        'should properly handle string-to-bytes-to-string round trip',
        () async {
          // arrange
          fileWrapper = WebFileWrapper(
            mockWebFile,
            name: testName,
            bytes: Uint8List.fromList([]),
          );

          final testStrings = [
            'Simple text',
            'Text with numbers 123',
            'Text\nwith\nnewlines',
            'Text\twith\ttabs',
            'Text with symbols: !@#\$%^&*()',
          ];

          for (final originalString in testStrings) {
            // act
            await fileWrapper.writeAsString(originalString);
            final result = await fileWrapper.readAsString();

            // assert
            expect(
              result,
              equals(originalString),
              reason: 'Round trip failed for: $originalString',
            );
          }
        },
      );
    });

    group('integration scenarios', () {
      test('should handle mixed read and write operations', () async {
        // arrange
        const initialContent = 'initial content';
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList(initialContent.codeUnits),
        );

        // act & assert - initial state
        expect(await fileWrapper.readAsString(), equals(initialContent));
        expect(await fileWrapper.length(), equals(initialContent.length));
        expect(await fileWrapper.exists(), isTrue);

        // act - write bytes
        await fileWrapper.writeAsBytes([72, 101, 108, 108, 111]); // "Hello"

        // assert - should read as string
        expect(await fileWrapper.readAsString(), equals('Hello'));
        expect(await fileWrapper.length(), equals(5));

        // act - write string
        await fileWrapper.writeAsString('World');

        // assert - should read as bytes
        expect(
          await fileWrapper.readAsBytes(),
          equals([87, 111, 114, 108, 100]),
        ); // "World"
        expect(await fileWrapper.length(), equals(5));
      });

      test('should maintain object identity and state', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: testBytes,
        );

        // act & assert - properties should remain consistent
        expect(fileWrapper.raw, same(mockWebFile));
        expect(fileWrapper.path, equals(testName));

        // act - perform operations
        await fileWrapper.writeAsString('new content');

        // assert - properties should still be consistent
        expect(fileWrapper.raw, same(mockWebFile));
        expect(fileWrapper.path, equals(testName));
        expect(await fileWrapper.exists(), isTrue);
      });

      test('should handle sequential write operations', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([]),
        );

        // act - multiple writes
        await fileWrapper.writeAsString('first');
        expect(await fileWrapper.readAsString(), equals('first'));

        await fileWrapper.writeAsBytes([
          115,
          101,
          99,
          111,
          110,
          100,
        ]); // "second"
        expect(await fileWrapper.readAsString(), equals('second'));

        await fileWrapper.writeAsString('third');
        expect(await fileWrapper.readAsString(), equals('third'));
        expect(await fileWrapper.length(), equals(5));
      });
    });

    group('edge cases', () {
      test('should handle empty file operations', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: 'empty.txt',
          bytes: Uint8List.fromList([]),
        );

        // act & assert
        expect(await fileWrapper.length(), equals(0));
        expect(await fileWrapper.readAsBytes(), equals([]));
        expect(await fileWrapper.readAsString(), equals(''));
        expect(await fileWrapper.exists(), isTrue);

        // act - write empty content
        await fileWrapper.writeAsString('');
        await fileWrapper.writeAsBytes([]);

        // assert
        expect(await fileWrapper.length(), equals(0));
        expect(await fileWrapper.readAsString(), equals(''));
      });

      test('should handle large content', () async {
        // arrange
        final largeString = 'x' * 10000;
        final largeBytes = List.generate(10000, (i) => i % 256);

        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: testName,
          bytes: Uint8List.fromList([]),
        );

        // act & assert - large string
        await fileWrapper.writeAsString(largeString);
        expect(await fileWrapper.readAsString(), equals(largeString));
        expect(await fileWrapper.length(), equals(10000));

        // act & assert - large bytes
        await fileWrapper.writeAsBytes(largeBytes);
        expect(await fileWrapper.readAsBytes(), equals(largeBytes));
        expect(await fileWrapper.length(), equals(10000));
      });

      test('should handle file with no extension', () async {
        // arrange
        fileWrapper = WebFileWrapper(
          mockWebFile,
          name: 'filename_without_extension',
          bytes: testBytes,
        );

        // act & assert
        expect(fileWrapper.path, equals('filename_without_extension'));
        expect(await fileWrapper.exists(), isTrue);
        expect(await fileWrapper.readAsBytes(), equals(testBytes));
      });
    });
  });
}
