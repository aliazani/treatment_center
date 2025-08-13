import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:treatment_center/core/providers/file_provider_web.dart';
import 'package:treatment_center/core/providers/file_wrapper_interface.dart';

@GenerateMocks([FileWrapper])
import 'file_provider_web_test.mocks.dart';

void main() {
  late FileProviderImpl fileProvider;
  late MockFileWrapper mockFileWrapper;

  setUp(() {
    fileProvider = FileProviderImpl();
    mockFileWrapper = MockFileWrapper();
  });

  group('FileProviderImpl (Web)', () {
    const String testPath = '/test/path/file.txt';
    const String testContent = 'test content';
    final testBytesAsList = [1, 2, 3, 4, 5];

    // Expected error messages
    const String expectedFileSystemErrorMessage =
        'There is no file-system path on the web.';
    const String expectedWriteErrorMessage =
        'Writing files is not supported on the web.';

    group('getFile', () {
      test('should throw UnsupportedError with correct message', () async {
        // act & assert
        expect(
          () async => await fileProvider.getFile(testPath),
          throwsA(
            predicate(
              (e) =>
                  e is UnsupportedError &&
                  e.message == expectedFileSystemErrorMessage,
            ),
          ),
        );
      });

      test('should throw UnsupportedError for any path input', () async {
        const paths = [
          '/absolute/path/file.txt',
          'relative/path/file.txt',
          'C:\\Windows\\path\\file.txt',
          'single_file.txt',
          '/root/file',
          '',
          '/',
          'very/long/path/with/many/segments/file.extension',
        ];

        for (final path in paths) {
          expect(
            () async => await fileProvider.getFile(path),
            throwsA(isA<UnsupportedError>()),
            reason: 'Should throw UnsupportedError for path: $path',
          );
        }
      });

      test(
        'should throw UnsupportedError with consistent message across calls',
        () async {
          const paths = [testPath, 'another/path', ''];

          for (final path in paths) {
            try {
              await fileProvider.getFile(path);
              fail('Expected UnsupportedError to be thrown');
            } on UnsupportedError catch (e) {
              expect(e.message, equals(expectedFileSystemErrorMessage));
            }
          }
        },
      );
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
        verify(mockFileWrapper.readAsBytes()).called(1);
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

      test('should propagate exceptions from file wrapper', () async {
        // arrange
        when(mockFileWrapper.readAsBytes()).thenThrow(Exception('Read error'));

        // act & assert
        expect(
          () async => await fileProvider.readAsBytes(mockFileWrapper),
          throwsA(isA<Exception>()),
        );
        verify(mockFileWrapper.readAsBytes()).called(1);
      });

      test(
        'should handle different exception types from file wrapper',
        () async {
          final exceptions = [
            Exception('Generic error'),
            ArgumentError('Invalid argument'),
            StateError('Invalid state'),
            FormatException('Format error'),
          ];

          for (final exception in exceptions) {
            // arrange
            when(mockFileWrapper.readAsBytes()).thenThrow(exception);

            // act & assert
            expect(
              () async => await fileProvider.readAsBytes(mockFileWrapper),
              throwsA(equals(exception)),
            );
            verify(mockFileWrapper.readAsBytes()).called(1);

            // Reset for next iteration
            reset(mockFileWrapper);
          }
        },
      );

      test('should work with multiple FileWrapper instances', () async {
        final anotherMockFileWrapper = MockFileWrapper();
        final bytes1 = [1, 2, 3];
        final bytes2 = [4, 5, 6];

        // arrange
        when(mockFileWrapper.readAsBytes()).thenAnswer((_) async => bytes1);
        when(
          anotherMockFileWrapper.readAsBytes(),
        ).thenAnswer((_) async => bytes2);

        // act
        final result1 = await fileProvider.readAsBytes(mockFileWrapper);
        final result2 = await fileProvider.readAsBytes(anotherMockFileWrapper);

        // assert
        verify(mockFileWrapper.readAsBytes()).called(1);
        verify(anotherMockFileWrapper.readAsBytes()).called(1);
        expect(result1, equals(Uint8List.fromList(bytes1)));
        expect(result2, equals(Uint8List.fromList(bytes2)));
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
          '   content with leading and trailing spaces   ',
          'content\r\nwith\r\nwindows\r\nline\r\nendings',
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

      test('should propagate exceptions from file wrapper', () async {
        // arrange
        when(
          mockFileWrapper.readAsString(),
        ).thenThrow(Exception('Read string error'));

        // act & assert
        expect(
          () async => await fileProvider.readAsString(mockFileWrapper),
          throwsA(isA<Exception>()),
        );
        verify(mockFileWrapper.readAsString()).called(1);
      });

      test(
        'should handle different exception types from file wrapper',
        () async {
          final exceptions = [
            Exception('Generic error'),
            ArgumentError('Invalid encoding'),
            StateError('Invalid state'),
            FormatException('Invalid format'),
          ];

          for (final exception in exceptions) {
            // arrange
            when(mockFileWrapper.readAsString()).thenThrow(exception);

            // act & assert
            expect(
              () async => await fileProvider.readAsString(mockFileWrapper),
              throwsA(equals(exception)),
            );
            verify(mockFileWrapper.readAsString()).called(1);

            // Reset for next iteration
            reset(mockFileWrapper);
          }
        },
      );

      test('should work with multiple FileWrapper instances', () async {
        final anotherMockFileWrapper = MockFileWrapper();
        const content1 = 'first content';
        const content2 = 'second content';

        // arrange
        when(mockFileWrapper.readAsString()).thenAnswer((_) async => content1);
        when(
          anotherMockFileWrapper.readAsString(),
        ).thenAnswer((_) async => content2);

        // act
        final result1 = await fileProvider.readAsString(mockFileWrapper);
        final result2 = await fileProvider.readAsString(anotherMockFileWrapper);

        // assert
        verify(mockFileWrapper.readAsString()).called(1);
        verify(anotherMockFileWrapper.readAsString()).called(1);
        expect(result1, equals(content1));
        expect(result2, equals(content2));
      });
    });

    group('writeAsBytes', () {
      test('should throw UnsupportedError with correct message', () async {
        // act & assert
        expect(
          () async =>
              await fileProvider.writeAsBytes(mockFileWrapper, testBytesAsList),
          throwsA(
            predicate(
              (e) =>
                  e is UnsupportedError &&
                  e.message == expectedWriteErrorMessage,
            ),
          ),
        );
      });

      test('should throw UnsupportedError for any input combination', () async {
        final testData = [
          {'wrapper': mockFileWrapper, 'bytes': testBytesAsList},
          {'wrapper': MockFileWrapper(), 'bytes': <int>[]},
          {
            'wrapper': MockFileWrapper(),
            'bytes': [255, 0, 128],
          },
          {
            'wrapper': MockFileWrapper(),
            'bytes': Uint8List.fromList([1, 2, 3]),
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
            [255, 0, 128, 64, 192],
            List.generate(1000, (i) => i % 256),
            Uint8List.fromList([100, 200, 50]),
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

      test(
        'should throw UnsupportedError with consistent message across calls',
        () async {
          final testCases = [
            testBytesAsList,
            <int>[],
            [255, 128, 0],
          ];

          for (final bytes in testCases) {
            try {
              await fileProvider.writeAsBytes(mockFileWrapper, bytes);
              fail('Expected UnsupportedError to be thrown');
            } on UnsupportedError catch (e) {
              expect(e.message, equals(expectedWriteErrorMessage));
            }
          }
        },
      );

      test(
        'should not call any methods on FileWrapper before throwing',
        () async {
          // act & assert
          expect(
            () async => await fileProvider.writeAsBytes(
              mockFileWrapper,
              testBytesAsList,
            ),
            throwsA(isA<UnsupportedError>()),
          );

          // verify no interactions with mock
          verifyZeroInteractions(mockFileWrapper);
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
              (e) =>
                  e is UnsupportedError &&
                  e.message == expectedWriteErrorMessage,
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
            'Very long text content with emojis 🎉 and symbols @#\$%^&*()',
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

      test(
        'should throw UnsupportedError with consistent message across calls',
        () async {
          final testCases = [testContent, '', 'different content'];

          for (final content in testCases) {
            try {
              await fileProvider.writeAsString(mockFileWrapper, content);
              fail('Expected UnsupportedError to be thrown');
            } on UnsupportedError catch (e) {
              expect(e.message, equals(expectedWriteErrorMessage));
            }
          }
        },
      );

      test(
        'should not call any methods on FileWrapper before throwing',
        () async {
          // act & assert
          expect(
            () async =>
                await fileProvider.writeAsString(mockFileWrapper, testContent),
            throwsA(isA<UnsupportedError>()),
          );

          // verify no interactions with mock
          verifyZeroInteractions(mockFileWrapper);
        },
      );
    });

    group('integration scenarios - supported operations only', () {
      test('should handle sequential read operations', () async {
        const content1 = 'first read';
        const content2 = 'second read';
        final bytes1 = [1, 2, 3];
        final bytes2 = [4, 5, 6];

        // arrange
        int stringCallCount = 0;
        when(mockFileWrapper.readAsString()).thenAnswer((_) async {
          if (stringCallCount == 0) {
            stringCallCount++;
            return content1;
          } else {
            return content2;
          }
        });
        int bytesCallCount = 0;
        when(mockFileWrapper.readAsBytes()).thenAnswer((_) async {
          if (bytesCallCount == 0) {
            bytesCallCount++;
            return bytes1;
          } else {
            return bytes2;
          }
        });

        // act
        final stringResult1 = await fileProvider.readAsString(mockFileWrapper);
        final stringResult2 = await fileProvider.readAsString(mockFileWrapper);
        final bytesResult1 = await fileProvider.readAsBytes(mockFileWrapper);
        final bytesResult2 = await fileProvider.readAsBytes(mockFileWrapper);

        // assert
        expect(stringResult1, equals(content1));
        expect(stringResult2, equals(content2));
        expect(bytesResult1, equals(Uint8List.fromList(bytes1)));
        expect(bytesResult2, equals(Uint8List.fromList(bytes2)));
        verify(mockFileWrapper.readAsString()).called(2);
        verify(mockFileWrapper.readAsBytes()).called(2);
      });

      test(
        'should handle read operations with different FileWrapper instances',
        () async {
          final anotherMockFileWrapper = MockFileWrapper();
          const content1 = 'content from wrapper 1';
          const content2 = 'content from wrapper 2';
          final bytes1 = [10, 20];
          final bytes2 = [30, 40];

          // arrange
          when(
            mockFileWrapper.readAsString(),
          ).thenAnswer((_) async => content1);
          when(
            anotherMockFileWrapper.readAsString(),
          ).thenAnswer((_) async => content2);
          when(mockFileWrapper.readAsBytes()).thenAnswer((_) async => bytes1);
          when(
            anotherMockFileWrapper.readAsBytes(),
          ).thenAnswer((_) async => bytes2);

          // act
          final stringResult1 = await fileProvider.readAsString(
            mockFileWrapper,
          );
          final stringResult2 = await fileProvider.readAsString(
            anotherMockFileWrapper,
          );
          final bytesResult1 = await fileProvider.readAsBytes(mockFileWrapper);
          final bytesResult2 = await fileProvider.readAsBytes(
            anotherMockFileWrapper,
          );

          // assert
          expect(stringResult1, equals(content1));
          expect(stringResult2, equals(content2));
          expect(bytesResult1, equals(Uint8List.fromList(bytes1)));
          expect(bytesResult2, equals(Uint8List.fromList(bytes2)));
          verify(mockFileWrapper.readAsString()).called(1);
          verify(anotherMockFileWrapper.readAsString()).called(1);
          verify(mockFileWrapper.readAsBytes()).called(1);
          verify(anotherMockFileWrapper.readAsBytes()).called(1);
        },
      );
    });

    group('platform-specific behavior validation', () {
      test('should consistently throw for file system operations', () async {
        const paths = ['/path1', '/path2', '/path3'];

        for (final path in paths) {
          expect(
            () async => await fileProvider.getFile(path),
            throwsA(
              predicate(
                (e) =>
                    e is UnsupportedError &&
                    e.message == expectedFileSystemErrorMessage,
              ),
            ),
          );
        }
      });

      test('should consistently throw for write operations', () async {
        final writeOperations = [
          () => fileProvider.writeAsBytes(mockFileWrapper, [1, 2, 3]),
          () => fileProvider.writeAsString(mockFileWrapper, 'content'),
        ];

        for (final operation in writeOperations) {
          expect(
            () async => await operation(),
            throwsA(
              predicate(
                (e) =>
                    e is UnsupportedError &&
                    e.message == expectedWriteErrorMessage,
              ),
            ),
          );
        }
      });

      test(
        'should support only read operations from existing FileWrapper',
        () async {
          // arrange
          when(
            mockFileWrapper.readAsString(),
          ).thenAnswer((_) async => 'readable content');
          when(
            mockFileWrapper.readAsBytes(),
          ).thenAnswer((_) async => [1, 2, 3]);

          // act & assert - these should work
          final stringContent = await fileProvider.readAsString(
            mockFileWrapper,
          );
          final bytesContent = await fileProvider.readAsBytes(mockFileWrapper);

          expect(stringContent, equals('readable content'));
          expect(bytesContent, equals(Uint8List.fromList([1, 2, 3])));

          // act & assert - these should throw
          expect(
            () async => await fileProvider.getFile('/any/path'),
            throwsA(isA<UnsupportedError>()),
          );
          expect(
            () async =>
                await fileProvider.writeAsBytes(mockFileWrapper, [1, 2, 3]),
            throwsA(isA<UnsupportedError>()),
          );
          expect(
            () async =>
                await fileProvider.writeAsString(mockFileWrapper, 'content'),
            throwsA(isA<UnsupportedError>()),
          );
        },
      );
    });
  });
}
