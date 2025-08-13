import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/photo_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';

void main() {
  group('PhotoModel', () {
    late PhotoModel tPhotoModel;
    late PhotoEntity tPhotoEntity;
    late DateTime tCapturedAt;
    late Map<String, dynamic> tJsonMap;

    setUp(() {
      tCapturedAt = DateTime.parse('2024-01-15T10:30:00.000Z');

      tPhotoModel = const PhotoModel(
        id: 'photo_123',
        fileName: 'test_image.jpg',
        filePath: '/storage/photos/test_image.jpg',
        source: PhotoSource.camera,
        fileSizeBytes: 2048576,
        capturedAt: null, // Will be set in individual tests
        description: 'Test photo description',
      );

      // Update with actual capturedAt for tests
      tPhotoModel = tPhotoModel.copyWith(capturedAt: tCapturedAt);

      tPhotoEntity = PhotoEntity(
        id: 'photo_123',
        fileName: 'test_image.jpg',
        filePath: '/storage/photos/test_image.jpg',
        source: PhotoSource.camera,
        fileSizeBytes: 2048576,
        capturedAt: tCapturedAt,
        description: 'Test photo description',
      );

      tJsonMap = {
        'id': 'photo_123',
        'fileName': 'test_image.jpg',
        'filePath': '/storage/photos/test_image.jpg',
        'source': 'camera',
        'fileSizeBytes': 2048576,
        'capturedAt': '2024-01-15T10:30:00.000Z',
        'description': 'Test photo description',
      };
    });

    group('inheritance', () {
      test('should be a subclass of PhotoEntity', () {
        // assert
        expect(tPhotoModel, isA<PhotoEntity>());
      });

      test('should inherit Equatable properties from PhotoEntity', () {
        // arrange
        final photoModel1 = PhotoModel(
          id: 'photo_123',
          fileName: 'test.jpg',
          filePath: '/path/test.jpg',
          source: PhotoSource.camera,
          fileSizeBytes: 1024,
          capturedAt: tCapturedAt,
        );

        final photoModel2 = PhotoModel(
          id: 'photo_123',
          fileName: 'test.jpg',
          filePath: '/path/test.jpg',
          source: PhotoSource.camera,
          fileSizeBytes: 1024,
          capturedAt: tCapturedAt,
        );

        // assert
        expect(photoModel1, equals(photoModel2));
        expect(photoModel1.hashCode, equals(photoModel2.hashCode));
      });
    });

    group('fromEntity', () {
      test('should create PhotoModel from PhotoEntity with all properties', () {
        // act
        final result = PhotoModel.fromEntity(tPhotoEntity);

        // assert
        expect(result.id, tPhotoEntity.id);
        expect(result.fileName, tPhotoEntity.fileName);
        expect(result.filePath, tPhotoEntity.filePath);
        expect(result.source, tPhotoEntity.source);
        expect(result.fileSizeBytes, tPhotoEntity.fileSizeBytes);
        expect(result.capturedAt, tPhotoEntity.capturedAt);
        expect(result.description, tPhotoEntity.description);
        expect(result, isA<PhotoModel>());
      });

      test(
        'should create PhotoModel from PhotoEntity with null description',
        () {
          // arrange
          final entityWithoutDescription = PhotoEntity(
            id: 'photo_456',
            fileName: 'image.png',
            filePath: '/path/image.png',
            source: PhotoSource.gallery,
            fileSizeBytes: 512000,
            capturedAt: tCapturedAt,
            description: null,
          );

          // act
          final result = PhotoModel.fromEntity(entityWithoutDescription);

          // assert
          expect(result.description, isNull);
          expect(result.id, entityWithoutDescription.id);
          expect(result.source, PhotoSource.gallery);
        },
      );
    });

    group('toEntity', () {
      test('should convert PhotoModel to PhotoEntity with all properties', () {
        // act
        final result = tPhotoModel.toEntity();

        // assert
        expect(result.id, tPhotoModel.id);
        expect(result.fileName, tPhotoModel.fileName);
        expect(result.filePath, tPhotoModel.filePath);
        expect(result.source, tPhotoModel.source);
        expect(result.fileSizeBytes, tPhotoModel.fileSizeBytes);
        expect(result.capturedAt, tPhotoModel.capturedAt);
        expect(result.description, tPhotoModel.description);
        expect(result, isA<PhotoEntity>());
      });

      test(
        'should convert PhotoModel to PhotoEntity preserving null description',
        () {
          // arrange
          final modelWithoutDescription = tPhotoModel.copyWith(
            description: null,
          );

          // act
          final result = modelWithoutDescription.toEntity();

          // assert
          expect(result.description, isNull);
          expect(result.id, modelWithoutDescription.id);
        },
      );
    });

    group('fromJson', () {
      test('should create PhotoModel from valid JSON with all properties', () {
        // act
        final result = PhotoModel.fromJson(tJsonMap);

        // assert
        expect(result.id, 'photo_123');
        expect(result.fileName, 'test_image.jpg');
        expect(result.filePath, '/storage/photos/test_image.jpg');
        expect(result.source, PhotoSource.camera);
        expect(result.fileSizeBytes, 2048576);
        expect(result.capturedAt, tCapturedAt);
        expect(result.description, 'Test photo description');
      });

      test('should create PhotoModel from JSON with gallery source', () {
        // arrange
        final jsonWithGallerySource = Map<String, dynamic>.from(tJsonMap);
        jsonWithGallerySource['source'] = 'gallery';

        // act
        final result = PhotoModel.fromJson(jsonWithGallerySource);

        // assert
        expect(result.source, PhotoSource.gallery);
      });

      test('should create PhotoModel from JSON with null description', () {
        // arrange
        final jsonWithNullDescription = Map<String, dynamic>.from(tJsonMap);
        jsonWithNullDescription['description'] = null;

        // act
        final result = PhotoModel.fromJson(jsonWithNullDescription);

        // assert
        expect(result.description, isNull);
      });

      test('should handle unknown source with fallback to gallery', () {
        // arrange
        final jsonWithUnknownSource = Map<String, dynamic>.from(tJsonMap);
        jsonWithUnknownSource['source'] = 'unknown_source';

        // act
        final result = PhotoModel.fromJson(jsonWithUnknownSource);

        // assert
        expect(result.source, PhotoSource.gallery);
      });

      test('should parse DateTime correctly from ISO string', () {
        // arrange
        final customDateTime = DateTime.parse('2023-12-25T15:45:30.123Z');
        final jsonWithCustomDate = Map<String, dynamic>.from(tJsonMap);
        jsonWithCustomDate['capturedAt'] = customDateTime.toIso8601String();

        // act
        final result = PhotoModel.fromJson(jsonWithCustomDate);

        // assert
        expect(result.capturedAt, customDateTime);
      });

      test('should throw FormatException for invalid DateTime format', () {
        // arrange
        final jsonWithInvalidDate = Map<String, dynamic>.from(tJsonMap);
        jsonWithInvalidDate['capturedAt'] = 'invalid-date-format';

        // assert
        expect(
          () => PhotoModel.fromJson(jsonWithInvalidDate),
          throwsA(isA<FormatException>()),
        );
      });

      test('should throw TypeError for invalid field types', () {
        // arrange
        final jsonWithInvalidTypes = Map<String, dynamic>.from(tJsonMap);
        jsonWithInvalidTypes['fileSizeBytes'] = 'not_a_number';

        // assert
        expect(
          () => PhotoModel.fromJson(jsonWithInvalidTypes),
          throwsA(isA<TypeError>()),
        );
      });
    });

    group('toJson', () {
      test('should convert PhotoModel to valid JSON with all properties', () {
        // act
        final result = tPhotoModel.toJson();

        // assert
        expect(result['id'], 'photo_123');
        expect(result['fileName'], 'test_image.jpg');
        expect(result['filePath'], '/storage/photos/test_image.jpg');
        expect(result['source'], 'camera');
        expect(result['fileSizeBytes'], 2048576);
        expect(result['capturedAt'], '2024-01-15T10:30:00.000Z');
        expect(result['description'], isNull);
      });

      test('should convert PhotoModel with gallery source to JSON', () {
        // arrange
        final galleryPhoto = tPhotoModel.copyWith(source: PhotoSource.gallery);

        // act
        final result = galleryPhoto.toJson();

        // assert
        expect(result['source'], 'gallery');
      });

      test('should convert PhotoModel with null description to JSON', () {
        // arrange
        final photoWithoutDescription = tPhotoModel.copyWith(description: null);

        // act
        final result = photoWithoutDescription.toJson();

        // assert
        expect(result['description'], isNull);
        expect(result.containsKey('description'), isTrue);
      });

      test(
        'should produce JSON that can be parsed back to equivalent PhotoModel',
        () {
          // act
          final json = tPhotoModel.toJson();
          final parsedModel = PhotoModel.fromJson(json);

          // assert
          expect(parsedModel, equals(tPhotoModel));
        },
      );
    });

    group('copyWith', () {
      test('should return new PhotoModel with updated id', () {
        // act
        final result = tPhotoModel.copyWith(id: 'new_id');

        // assert
        expect(result.id, 'new_id');
        expect(result.fileName, tPhotoModel.fileName);
        expect(result, isA<PhotoModel>());
        expect(result, isNot(same(tPhotoModel)));
      });

      test('should return new PhotoModel with updated fileName', () {
        // act
        final result = tPhotoModel.copyWith(fileName: 'updated_image.png');

        // assert
        expect(result.fileName, 'updated_image.png');
        expect(result.id, tPhotoModel.id);
      });

      test('should return new PhotoModel with updated filePath', () {
        // act
        final result = tPhotoModel.copyWith(filePath: '/new/path/image.jpg');

        // assert
        expect(result.filePath, '/new/path/image.jpg');
        expect(result.id, tPhotoModel.id);
      });

      test('should return new PhotoModel with updated source', () {
        // act
        final result = tPhotoModel.copyWith(source: PhotoSource.gallery);

        // assert
        expect(result.source, PhotoSource.gallery);
        expect(result.id, tPhotoModel.id);
      });

      test('should return new PhotoModel with updated fileSizeBytes', () {
        // act
        final result = tPhotoModel.copyWith(fileSizeBytes: 4096000);

        // assert
        expect(result.fileSizeBytes, 4096000);
        expect(result.id, tPhotoModel.id);
      });

      test('should return new PhotoModel with updated capturedAt', () {
        // arrange
        final newDate = DateTime.parse('2024-02-20T14:15:00.000Z');

        // act
        final result = tPhotoModel.copyWith(capturedAt: newDate);

        // assert
        expect(result.capturedAt, newDate);
        expect(result.id, tPhotoModel.id);
      });

      test('should return new PhotoModel with updated description', () {
        // act
        final result = tPhotoModel.copyWith(description: 'New description');

        // assert
        expect(result.description, 'New description');
        expect(result.id, tPhotoModel.id);
      });

      test('should return new PhotoModel with multiple updated properties', () {
        // arrange
        final newDate = DateTime.parse('2024-03-10T09:00:00.000Z');

        // act
        final result = tPhotoModel.copyWith(
          id: 'multi_update_id',
          fileName: 'multi_update.jpg',
          source: PhotoSource.gallery,
          capturedAt: newDate,
          description: 'Multi-property update',
        );

        // assert
        expect(result.id, 'multi_update_id');
        expect(result.fileName, 'multi_update.jpg');
        expect(result.source, PhotoSource.gallery);
        expect(result.capturedAt, newDate);
        expect(result.description, 'Multi-property update');
        expect(result.filePath, tPhotoModel.filePath); // unchanged
        expect(result.fileSizeBytes, tPhotoModel.fileSizeBytes); // unchanged
      });

      test(
        'should return identical PhotoModel when no parameters provided',
        () {
          // act
          final result = tPhotoModel.copyWith();

          // assert
          expect(result, isNot(same(tPhotoModel)));
        },
      );

      test('should handle null values explicitly', () {
        // act
        final result = tPhotoModel.copyWith(description: null);

        // assert
        expect(result.description, isNull);
        expect(result.id, tPhotoModel.id);
      });
    });

    group('edge cases', () {
      test('should handle minimum file size', () {
        // act
        final result = tPhotoModel.copyWith(fileSizeBytes: 0);

        // assert
        expect(result.fileSizeBytes, 0);
      });

      test('should handle maximum int file size', () {
        // arrange
        const maxInt = 9223372036854775807; // Max int64 value

        // act
        final result = tPhotoModel.copyWith(fileSizeBytes: maxInt);

        // assert
        expect(result.fileSizeBytes, maxInt);
      });

      test('should handle very long file names and paths', () {
        // arrange
        final longFileName = 'very_long_file_name_${'a' * 200}.jpg';
        final longFilePath =
            '/very/long/path/${'directory/' * 50}$longFileName';

        // act
        final result = tPhotoModel.copyWith(
          fileName: longFileName,
          filePath: longFilePath,
        );

        // assert
        expect(result.fileName, longFileName);
        expect(result.filePath, longFilePath);
      });

      test('should handle DateTime with microseconds precision', () {
        // arrange
        final preciseDateTime = DateTime.parse('2024-01-15T10:30:00.123456Z');

        // act
        final result = tPhotoModel.copyWith(capturedAt: preciseDateTime);

        // assert
        expect(result.capturedAt, preciseDateTime);
      });
    });

    group('serialization roundtrip', () {
      test(
        'should maintain data integrity through JSON serialization roundtrip',
        () {
          // act
          final json = tPhotoModel.toJson();
          final jsonString = jsonEncode(json);
          final parsedJson = jsonDecode(jsonString) as Map<String, dynamic>;
          final reconstructedModel = PhotoModel.fromJson(parsedJson);

          // assert
          expect(reconstructedModel, equals(tPhotoModel));
          expect(reconstructedModel.hashCode, equals(tPhotoModel.hashCode));
        },
      );

      test('should handle entity conversion roundtrip', () {
        // act
        final entity = tPhotoModel.toEntity();
        final reconstructedModel = PhotoModel.fromEntity(entity);

        // assert
        expect(reconstructedModel, equals(tPhotoModel));
        expect(reconstructedModel, isA<PhotoModel>());
      });
    });
  });
}
