import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';

void main() {
  group('PhotoEntity', () {
    const tId = 'test-id-123';
    const tFileName = 'test_photo.jpg';
    const tFilePath = '/path/to/test_photo.jpg';
    const tSource = PhotoSource.camera;
    const tFileSizeBytes = 1024000; // 1MB
    final tCapturedAt = DateTime(2024, 1, 15, 10, 30, 45);
    const tDescription = 'Test photo description';

    final tPhotoEntity = PhotoEntity(
      id: tId,
      fileName: tFileName,
      filePath: tFilePath,
      source: tSource,
      fileSizeBytes: tFileSizeBytes,
      capturedAt: tCapturedAt,
      description: tDescription,
    );

    group('constructor', () {
      test('should create PhotoEntity with all required parameters', () {
        // arrange & act
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
        );

        // assert
        expect(photoEntity.id, tId);
        expect(photoEntity.fileName, tFileName);
        expect(photoEntity.filePath, tFilePath);
        expect(photoEntity.source, tSource);
        expect(photoEntity.fileSizeBytes, tFileSizeBytes);
        expect(photoEntity.capturedAt, tCapturedAt);
        expect(photoEntity.description, null);
      });

      test('should create PhotoEntity with optional description', () {
        // arrange & act
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: tDescription,
        );

        // assert
        expect(photoEntity.description, tDescription);
      });
    });

    group('copyWith', () {
      test('should return same object when no parameters are passed', () {
        // act
        final result = tPhotoEntity.copyWith();

        // assert
        expect(result, tPhotoEntity);
        expect(result.id, tPhotoEntity.id);
        expect(result.fileName, tPhotoEntity.fileName);
        expect(result.filePath, tPhotoEntity.filePath);
        expect(result.source, tPhotoEntity.source);
        expect(result.fileSizeBytes, tPhotoEntity.fileSizeBytes);
        expect(result.capturedAt, tPhotoEntity.capturedAt);
        expect(result.description, tPhotoEntity.description);
      });

      test('should return new object with updated id', () {
        // arrange
        const newId = 'new-id-456';

        // act
        final result = tPhotoEntity.copyWith(id: newId);

        // assert
        expect(result.id, newId);
        expect(result.fileName, tPhotoEntity.fileName);
        expect(result.filePath, tPhotoEntity.filePath);
        expect(result.source, tPhotoEntity.source);
        expect(result.fileSizeBytes, tPhotoEntity.fileSizeBytes);
        expect(result.capturedAt, tPhotoEntity.capturedAt);
        expect(result.description, tPhotoEntity.description);
      });

      test('should return new object with updated fileName', () {
        // arrange
        const newFileName = 'new_photo.png';

        // act
        final result = tPhotoEntity.copyWith(fileName: newFileName);

        // assert
        expect(result.fileName, newFileName);
        expect(result.id, tPhotoEntity.id);
      });

      test('should return new object with updated filePath', () {
        // arrange
        const newFilePath = '/new/path/to/photo.jpg';

        // act
        final result = tPhotoEntity.copyWith(filePath: newFilePath);

        // assert
        expect(result.filePath, newFilePath);
        expect(result.id, tPhotoEntity.id);
      });

      test('should return new object with updated source', () {
        // arrange
        const newSource = PhotoSource.gallery;

        // act
        final result = tPhotoEntity.copyWith(source: newSource);

        // assert
        expect(result.source, newSource);
        expect(result.id, tPhotoEntity.id);
      });

      test('should return new object with updated fileSizeBytes', () {
        // arrange
        const newFileSizeBytes = 2048000; // 2MB

        // act
        final result = tPhotoEntity.copyWith(fileSizeBytes: newFileSizeBytes);

        // assert
        expect(result.fileSizeBytes, newFileSizeBytes);
        expect(result.id, tPhotoEntity.id);
      });

      test('should return new object with updated capturedAt', () {
        // arrange
        final newCapturedAt = DateTime(2024, 2, 20, 15, 45, 30);

        // act
        final result = tPhotoEntity.copyWith(capturedAt: newCapturedAt);

        // assert
        expect(result.capturedAt, newCapturedAt);
        expect(result.id, tPhotoEntity.id);
      });

      test('should return new object with updated description', () {
        // arrange
        const newDescription = 'Updated photo description';

        // act
        final result = tPhotoEntity.copyWith(description: newDescription);

        // assert
        expect(result.description, newDescription);
        expect(result.id, tPhotoEntity.id);
      });

      test('should return new object with multiple updated fields', () {
        // arrange
        const newId = 'multi-update-id';
        const newFileName = 'multi_update.jpg';
        const newSource = PhotoSource.gallery;
        const newDescription = 'Multi-field update';

        // act
        final result = tPhotoEntity.copyWith(
          id: newId,
          fileName: newFileName,
          source: newSource,
          description: newDescription,
        );

        // assert
        expect(result.id, newId);
        expect(result.fileName, newFileName);
        expect(result.source, newSource);
        expect(result.description, newDescription);
        // Unchanged fields
        expect(result.filePath, tPhotoEntity.filePath);
        expect(result.fileSizeBytes, tPhotoEntity.fileSizeBytes);
        expect(result.capturedAt, tPhotoEntity.capturedAt);
      });
    });

    group('fileSize getter', () {
      test('should return size in bytes when less than 1024 bytes', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 512,
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '512 B');
      });

      test('should return size in bytes when exactly 1023 bytes', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 1023,
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '1023 B');
      });

      test(
        'should return size in KB when 1024 bytes or more but less than 1MB',
        () {
          // arrange
          final photoEntity = PhotoEntity(
            id: tId,
            fileName: tFileName,
            filePath: tFilePath,
            source: tSource,
            fileSizeBytes: 1024,
            capturedAt: tCapturedAt,
          );

          // act
          final result = photoEntity.fileSize;

          // assert
          expect(result, '1.0 KB');
        },
      );

      test('should return size in KB with proper decimal formatting', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 1536, // 1.5 KB
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '1.5 KB');
      });

      test('should return size in KB when exactly 1MB - 1 byte', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 1048575, // 1024 * 1024 - 1
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '1024.0 KB');
      });

      test('should return size in MB when 1MB or larger', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 1048576, // 1MB
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '1.0 MB');
      });

      test('should return size in MB with proper decimal formatting', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 2621440, // 2.5 MB
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '2.5 MB');
      });

      test('should return size in MB for very large files', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 52428800, // 50 MB
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '50.0 MB');
      });

      test('should handle zero bytes', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: 0,
          capturedAt: tCapturedAt,
        );

        // act
        final result = photoEntity.fileSize;

        // assert
        expect(result, '0 B');
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // arrange
        final photoEntity1 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: tDescription,
        );

        final photoEntity2 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: tDescription,
        );

        // act & assert
        expect(photoEntity1, photoEntity2);
        expect(photoEntity1.hashCode, photoEntity2.hashCode);
      });

      test('should not be equal when id is different', () {
        // arrange
        final photoEntity1 = PhotoEntity(
          id: 'id1',
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
        );

        final photoEntity2 = PhotoEntity(
          id: 'id2',
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
        );

        // act & assert
        expect(photoEntity1, isNot(photoEntity2));
        expect(photoEntity1.hashCode, isNot(photoEntity2.hashCode));
      });

      test('should not be equal when fileName is different', () {
        // arrange
        final photoEntity1 = PhotoEntity(
          id: tId,
          fileName: 'file1.jpg',
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
        );

        final photoEntity2 = PhotoEntity(
          id: tId,
          fileName: 'file2.jpg',
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
        );

        // act & assert
        expect(photoEntity1, isNot(photoEntity2));
      });

      test('should not be equal when source is different', () {
        // arrange
        final photoEntity1 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: PhotoSource.camera,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
        );

        final photoEntity2 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: PhotoSource.gallery,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
        );

        // act & assert
        expect(photoEntity1, isNot(photoEntity2));
      });

      test('should not be equal when description is different', () {
        // arrange
        final photoEntity1 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: 'description1',
        );

        final photoEntity2 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: 'description2',
        );

        // act & assert
        expect(photoEntity1, isNot(photoEntity2));
      });

      test('should handle null description equality', () {
        // arrange
        final photoEntity1 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: null,
        );

        final photoEntity2 = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: null,
        );

        // act & assert
        expect(photoEntity1, photoEntity2);
      });

      test(
        'should not be equal when one has null description and other has value',
        () {
          // arrange
          final photoEntity1 = PhotoEntity(
            id: tId,
            fileName: tFileName,
            filePath: tFilePath,
            source: tSource,
            fileSizeBytes: tFileSizeBytes,
            capturedAt: tCapturedAt,
            description: null,
          );

          final photoEntity2 = PhotoEntity(
            id: tId,
            fileName: tFileName,
            filePath: tFilePath,
            source: tSource,
            fileSizeBytes: tFileSizeBytes,
            capturedAt: tCapturedAt,
            description: 'some description',
          );

          // act & assert
          expect(photoEntity1, isNot(photoEntity2));
        },
      );
    });

    group('props', () {
      test(
        'should return correct list of properties for equality comparison',
        () {
          // act
          final props = tPhotoEntity.props;

          // assert
          expect(props, [
            tId,
            tFileName,
            tFilePath,
            tSource,
            tFileSizeBytes,
            tCapturedAt,
            tDescription,
          ]);
        },
      );

      test('should include null description in props', () {
        // arrange
        final photoEntity = PhotoEntity(
          id: tId,
          fileName: tFileName,
          filePath: tFilePath,
          source: tSource,
          fileSizeBytes: tFileSizeBytes,
          capturedAt: tCapturedAt,
          description: null,
        );

        // act
        final props = photoEntity.props;

        // assert
        expect(props.last, null);
        expect(props.length, 7);
      });
    });
  });

  group('PhotoSource enum', () {
    test('should have camera value', () {
      expect(PhotoSource.camera, isA<PhotoSource>());
      expect(PhotoSource.camera.toString(), 'PhotoSource.camera');
    });

    test('should have gallery value', () {
      expect(PhotoSource.gallery, isA<PhotoSource>());
      expect(PhotoSource.gallery.toString(), 'PhotoSource.gallery');
    });

    test('should have exactly 2 values', () {
      expect(PhotoSource.values.length, 2);
      expect(PhotoSource.values, [PhotoSource.camera, PhotoSource.gallery]);
    });

    test('camera and gallery should not be equal', () {
      expect(PhotoSource.camera, isNot(PhotoSource.gallery));
    });
  });
}
