import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/database/daos/assessment_dao.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource_drift_impl.dart';

import '../../../../fixtures/test_assessment_fixtures.dart';
import 'assessment_local_datasource_drift_impl_test.mocks.dart';

@GenerateMocks([AssessmentDao])
void main() {
  late AssessmentLocalDataSourceDriftImpl dataSource;
  late MockAssessmentDao mockAssessmentDao;

  setUp(() {
    mockAssessmentDao = MockAssessmentDao();
    dataSource = AssessmentLocalDataSourceDriftImpl(
      assessmentDao: mockAssessmentDao,
    );
  });

  // Test data
  final tAssessmentId1 = 'test-assessment-id-1';
  final tAssessmentId2 = 'test-assessment-id-2';
  final tAssessmentModel1 =
      TestAssessmentFixtures.createTestAssessmentFormModel(id: tAssessmentId1);
  final tAssessmentModel2 =
      TestAssessmentFixtures.createTestAssessmentFormModel(id: tAssessmentId2);
  final tSubmittedAssessment = tAssessmentModel1.markAsSubmitted();

  group('getAssessment', () {
    test(
      'should return AssessmentFormModel from DAO when assessment exists',
      () async {
        // arrange
        when(
          mockAssessmentDao.getAssessment(tAssessmentId1),
        ).thenAnswer((_) async => tAssessmentModel1);

        // act
        final result = await dataSource.getAssessment(tAssessmentId1);

        // assert
        verify(mockAssessmentDao.getAssessment(tAssessmentId1));
        expect(result.id, equals(tAssessmentModel1.id));
        expect(
          result.assessorInfo.name,
          equals(tAssessmentModel1.assessorInfo.name),
        );
      },
    );

    test('should throw CacheException when assessment does not exist', () {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => null);

      // act
      final call = dataSource.getAssessment;

      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.getAssessment;

      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
    });
  });

  group('getAllAssessments', () {
    test('should return all assessments from DAO', () async {
      // arrange
      final assessmentsList = [tAssessmentModel1, tAssessmentModel2];
      when(
        mockAssessmentDao.getAllAssessments(),
      ).thenAnswer((_) async => assessmentsList);

      // act
      final result = await dataSource.getAllAssessments();

      // assert
      verify(mockAssessmentDao.getAllAssessments());
      expect(result.length, equals(2));
      expect(result[0].id, equals(tAssessmentModel1.id));
      expect(result[1].id, equals(tAssessmentModel2.id));
    });

    test('should return empty list when no assessments exist', () async {
      // arrange
      when(mockAssessmentDao.getAllAssessments()).thenAnswer((_) async => []);

      // act
      final result = await dataSource.getAllAssessments();

      // assert
      verify(mockAssessmentDao.getAllAssessments());
      expect(result, isEmpty);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getAllAssessments(),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.getAllAssessments;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getAllAssessments());
    });
  });

  group('getEditableAssessments', () {
    test('should return unsubmitted assessments from DAO', () async {
      // arrange
      final editableAssessments = [tAssessmentModel1, tAssessmentModel2];
      when(
        mockAssessmentDao.getUnsubmittedAssessments(),
      ).thenAnswer((_) async => editableAssessments);

      // act
      final result = await dataSource.getEditableAssessments();

      // assert
      verify(mockAssessmentDao.getUnsubmittedAssessments());
      expect(result.length, equals(2));
      expect(result, equals(editableAssessments));
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getUnsubmittedAssessments(),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.getEditableAssessments;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getUnsubmittedAssessments());
    });
  });

  group('getSubmittedAssessments', () {
    test('should return submitted assessments from DAO', () async {
      // arrange
      final submittedAssessments = [tSubmittedAssessment];
      when(
        mockAssessmentDao.getSubmittedAssessments(),
      ).thenAnswer((_) async => submittedAssessments);

      // act
      final result = await dataSource.getSubmittedAssessments();

      // assert
      verify(mockAssessmentDao.getSubmittedAssessments());
      expect(result.length, equals(1));
      expect(result, equals(submittedAssessments));
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getSubmittedAssessments(),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.getSubmittedAssessments;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getSubmittedAssessments());
    });
  });

  group('canEditAssessment', () {
    test(
      'should return true when assessment exists and is not submitted',
      () async {
        // arrange
        when(
          mockAssessmentDao.getAssessment(tAssessmentId1),
        ).thenAnswer((_) async => tAssessmentModel1);

        // act
        final result = await dataSource.canEditAssessment(tAssessmentId1);

        // assert
        verify(mockAssessmentDao.getAssessment(tAssessmentId1));
        expect(result, isTrue);
      },
    );

    test('should return false when assessment is submitted', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => tSubmittedAssessment);

      // act
      final result = await dataSource.canEditAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      expect(result, isFalse);
    });

    test('should return false when assessment does not exist', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => null);

      // act
      final result = await dataSource.canEditAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      expect(result, isFalse);
    });

    test('should return false when DAO throws an error', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenThrow(Exception('Database error'));

      // act
      final result = await dataSource.canEditAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      expect(result, isFalse);
    });
  });

  group('saveAssessment', () {
    test('should save assessment successfully', () async {
      // arrange
      when(
        mockAssessmentDao.saveAssessment(tAssessmentModel1),
      ).thenAnswer((_) async => true);

      // act
      final result = await dataSource.saveAssessment(tAssessmentModel1);

      // assert
      verify(mockAssessmentDao.saveAssessment(tAssessmentModel1));
      expect(result, isTrue);
    });

    test('should return false when save fails', () async {
      // arrange
      when(
        mockAssessmentDao.saveAssessment(tAssessmentModel1),
      ).thenAnswer((_) async => false);

      // act
      final result = await dataSource.saveAssessment(tAssessmentModel1);

      // assert
      verify(mockAssessmentDao.saveAssessment(tAssessmentModel1));
      expect(result, isFalse);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.saveAssessment(tAssessmentModel1),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.saveAssessment;

      // assert
      expect(() => call(tAssessmentModel1), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.saveAssessment(tAssessmentModel1));
    });
  });

  group('saveEditableAssessment', () {
    test('should save assessment when not submitted', () async {
      // arrange
      when(
        mockAssessmentDao.saveAssessment(tAssessmentModel1),
      ).thenAnswer((_) async => true);

      // act
      final result = await dataSource.saveEditableAssessment(tAssessmentModel1);

      // assert
      verify(mockAssessmentDao.saveAssessment(tAssessmentModel1));
      expect(result, isTrue);
    });

    test('should return false when assessment is submitted', () async {
      // arrange
      // act
      final result = await dataSource.saveEditableAssessment(
        tSubmittedAssessment,
      );

      // assert
      verifyNever(mockAssessmentDao.saveAssessment(any));
      expect(result, isFalse);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.saveAssessment(tAssessmentModel1),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.saveEditableAssessment;

      // assert
      expect(() => call(tAssessmentModel1), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.saveAssessment(tAssessmentModel1));
    });
  });

  group('updateAssessment', () {
    test(
      'should update assessment when it exists and is not submitted',
      () async {
        // arrange
        when(
          mockAssessmentDao.getAssessment(tAssessmentId1),
        ).thenAnswer((_) async => tAssessmentModel1);
        when(
          mockAssessmentDao.updateAssessment(any),
        ).thenAnswer((_) async => true);

        // act
        final result = await dataSource.updateAssessment(
          tAssessmentId1,
          tAssessmentModel1,
        );

        // assert
        verify(mockAssessmentDao.getAssessment(tAssessmentId1));
        verify(mockAssessmentDao.updateAssessment(any));
        expect(result, isTrue);
      },
    );

    test('should return false when assessment does not exist', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => null);

      // act
      final result = await dataSource.updateAssessment(
        tAssessmentId1,
        tAssessmentModel1,
      );

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      verifyNever(mockAssessmentDao.updateAssessment(any));
      expect(result, isFalse);
    });

    test('should return false when assessment is submitted', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => tSubmittedAssessment);

      // act
      final result = await dataSource.updateAssessment(
        tAssessmentId1,
        tAssessmentModel1,
      );

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      verifyNever(mockAssessmentDao.updateAssessment(any));
      expect(result, isFalse);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.updateAssessment;

      // assert
      expect(
        () => call(tAssessmentId1, tAssessmentModel1),
        throwsA(isA<CacheException>()),
      );
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
    });
  });

  group('submitAssessment', () {
    test('should submit assessment when it exists', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => tAssessmentModel1);
      when(
        mockAssessmentDao.updateAssessment(any),
      ).thenAnswer((_) async => true);

      // act
      final result = await dataSource.submitAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      verify(mockAssessmentDao.updateAssessment(any));
      expect(result, isTrue);
    });

    test('should return false when assessment does not exist', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => null);

      // act
      final result = await dataSource.submitAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      verifyNever(mockAssessmentDao.updateAssessment(any));
      expect(result, isFalse);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.submitAssessment;

      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
    });
  });

  group('deleteAssessment', () {
    test('should delete assessment successfully', () async {
      // arrange
      when(
        mockAssessmentDao.deleteAssessment(tAssessmentId1),
      ).thenAnswer((_) async => true);

      // act
      final result = await dataSource.deleteAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.deleteAssessment(tAssessmentId1));
      expect(result, isTrue);
    });

    test('should return false when deletion fails', () async {
      // arrange
      when(
        mockAssessmentDao.deleteAssessment(tAssessmentId1),
      ).thenAnswer((_) async => false);

      // act
      final result = await dataSource.deleteAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.deleteAssessment(tAssessmentId1));
      expect(result, isFalse);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.deleteAssessment(tAssessmentId1),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.deleteAssessment;

      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.deleteAssessment(tAssessmentId1));
    });
  });

  group('deleteEditableAssessment', () {
    test(
      'should delete assessment when it exists and is not submitted',
      () async {
        // arrange
        when(
          mockAssessmentDao.getAssessment(tAssessmentId1),
        ).thenAnswer((_) async => tAssessmentModel1);
        when(
          mockAssessmentDao.deleteAssessment(tAssessmentId1),
        ).thenAnswer((_) async => true);

        // act
        final result = await dataSource.deleteEditableAssessment(
          tAssessmentId1,
        );

        // assert
        verify(mockAssessmentDao.getAssessment(tAssessmentId1));
        verify(mockAssessmentDao.deleteAssessment(tAssessmentId1));
        expect(result, isTrue);
      },
    );

    test('should return false when assessment does not exist', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => null);

      // act
      final result = await dataSource.deleteEditableAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      verifyNever(mockAssessmentDao.deleteAssessment(any));
      expect(result, isFalse);
    });

    test('should return false when assessment is submitted', () async {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenAnswer((_) async => tSubmittedAssessment);

      // act
      final result = await dataSource.deleteEditableAssessment(tAssessmentId1);

      // assert
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
      verifyNever(mockAssessmentDao.deleteAssessment(any));
      expect(result, isFalse);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getAssessment(tAssessmentId1),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.deleteEditableAssessment;

      // assert
      expect(() => call(tAssessmentId1), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getAssessment(tAssessmentId1));
    });
  });
  group('Search and Filter Methods', () {
    group('searchByFacilityName', () {
      test('should return search results from DAO', () async {
        // arrange
        final searchTerm = 'Test Facility';
        final searchResults = [tAssessmentModel1];
        when(
          mockAssessmentDao.searchByFacilityName(searchTerm),
        ).thenAnswer((_) async => searchResults);

        // act
        final result = await dataSource.searchByFacilityName(searchTerm);

        // assert
        verify(mockAssessmentDao.searchByFacilityName(searchTerm));
        expect(result, equals(searchResults));
      });

      test('should return all assessments when search term is empty', () async {
        // arrange
        final allAssessments = [tAssessmentModel1, tAssessmentModel2];
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenAnswer((_) async => allAssessments);

        // act
        final result = await dataSource.searchByFacilityName('');

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        verifyNever(mockAssessmentDao.searchByFacilityName(any));
        expect(result, equals(allAssessments));
      });

      test('should throw CacheException when DAO throws an error', () {
        // arrange
        when(
          mockAssessmentDao.searchByFacilityName(any),
        ).thenThrow(Exception('Database error'));

        // act
        final call = dataSource.searchByFacilityName;

        // assert
        expect(() => call('test'), throwsA(isA<CacheException>()));
      });
    });

    group('searchByAssessorName', () {
      test('should return search results from DAO', () async {
        // arrange
        final searchTerm = 'John Doe';
        final searchResults = [tAssessmentModel1];
        when(
          mockAssessmentDao.searchByAssessorName(searchTerm),
        ).thenAnswer((_) async => searchResults);

        // act
        final result = await dataSource.searchByAssessorName(searchTerm);

        // assert
        verify(mockAssessmentDao.searchByAssessorName(searchTerm));
        expect(result, equals(searchResults));
      });

      test('should return all assessments when search term is empty', () async {
        // arrange
        final allAssessments = [tAssessmentModel1, tAssessmentModel2];
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenAnswer((_) async => allAssessments);

        // act
        final result = await dataSource.searchByAssessorName('');

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        verifyNever(mockAssessmentDao.searchByAssessorName(any));
        expect(result, equals(allAssessments));
      });

      test('should throw CacheException when DAO throws an error', () {
        // arrange
        when(
          mockAssessmentDao.searchByAssessorName(any),
        ).thenThrow(Exception('Database error'));

        // act
        final call = dataSource.searchByAssessorName;

        // assert
        expect(() => call('test'), throwsA(isA<CacheException>()));
      });
    });

    group('getAssessmentsByDateRange', () {
      test('should return assessments within date range', () async {
        // arrange
        final startDate = DateTime(2023, 1, 1);
        final endDate = DateTime(2023, 12, 31);
        final dateRangeResults = [tAssessmentModel1];
        when(
          mockAssessmentDao.getAssessmentsByDateRange(
            startDate: startDate,
            endDate: endDate,
          ),
        ).thenAnswer((_) async => dateRangeResults);

        // act
        final result = await dataSource.getAssessmentsByDateRange(
          startDate: startDate,
          endDate: endDate,
        );

        // assert
        verify(
          mockAssessmentDao.getAssessmentsByDateRange(
            startDate: startDate,
            endDate: endDate,
          ),
        );
        expect(result, equals(dateRangeResults));
      });

      test('should throw CacheException when DAO throws an error', () {
        // arrange
        final startDate = DateTime(2023, 1, 1);
        final endDate = DateTime(2023, 12, 31);
        when(
          mockAssessmentDao.getAssessmentsByDateRange(
            startDate: anyNamed('startDate'),
            endDate: anyNamed('endDate'),
          ),
        ).thenThrow(Exception('Database error'));

        // act
        final call = dataSource.getAssessmentsByDateRange;

        // assert
        expect(
          () => call(startDate: startDate, endDate: endDate),
          throwsA(isA<CacheException>()),
        );
      });
    });
  });

  group('Utility Methods', () {
    group('getAssessmentCounts', () {
      test('should return correct assessment counts', () async {
        // arrange
        final allAssessments = [
          tAssessmentModel1, // not submitted
          tAssessmentModel2, // not submitted
          tSubmittedAssessment, // submitted
        ];
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenAnswer((_) async => allAssessments);

        // act
        final result = await dataSource.getAssessmentCounts();

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        expect(result['total'], equals(3));
        expect(result['submitted'], equals(1));
        expect(result['editable'], equals(2));
      });

      test('should throw CacheException when DAO throws an error', () {
        // arrange
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenThrow(Exception('Database error'));

        // act
        final call = dataSource.getAssessmentCounts;

        // assert
        expect(() => call(), throwsA(isA<CacheException>()));
      });
    });

    group('hasAssessments', () {
      test('should return true when assessments exist', () async {
        // arrange
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenAnswer((_) async => [tAssessmentModel1]);

        // act
        final result = await dataSource.hasAssessments();

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        expect(result, isTrue);
      });

      test('should return false when no assessments exist', () async {
        // arrange
        when(mockAssessmentDao.getAllAssessments()).thenAnswer((_) async => []);

        // act
        final result = await dataSource.hasAssessments();

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        expect(result, isFalse);
      });

      test('should return false when DAO throws an error', () async {
        // arrange
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenThrow(Exception('Database error'));

        // act
        final result = await dataSource.hasAssessments();

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        expect(result, isFalse);
      });
    });

    group('getLatestAssessment', () {
      test('should return the most recently created assessment', () async {
        // arrange
        final olderAssessment =
            TestAssessmentFixtures.createTestAssessmentFormModel(
              id: 'older',
              createdAt: DateTime(2023, 1, 1),
            );
        final newerAssessment =
            TestAssessmentFixtures.createTestAssessmentFormModel(
              id: 'newer',
              createdAt: DateTime(2023, 1, 2),
            );
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenAnswer((_) async => [olderAssessment, newerAssessment]);

        // act
        final result = await dataSource.getLatestAssessment();

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        expect(result?.id, equals('newer'));
      });

      test('should return null when no assessments exist', () async {
        // arrange
        when(mockAssessmentDao.getAllAssessments()).thenAnswer((_) async => []);

        // act
        final result = await dataSource.getLatestAssessment();

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        expect(result, isNull);
      });

      test('should return null when DAO throws an error', () async {
        // arrange
        when(
          mockAssessmentDao.getAllAssessments(),
        ).thenThrow(Exception('Database error'));

        // act
        final result = await dataSource.getLatestAssessment();

        // assert
        verify(mockAssessmentDao.getAllAssessments());
        expect(result, isNull);
      });
    });

    group('clearAllAssessments', () {
      test('should clear all assessments successfully', () async {
        // arrange
        when(
          mockAssessmentDao.clearAllAssessments(),
        ).thenAnswer((_) async => true);

        // act
        final result = await dataSource.clearAllAssessments();

        // assert
        verify(mockAssessmentDao.clearAllAssessments());
        expect(result, isTrue);
      });

      test('should throw CacheException when DAO throws an error', () {
        // arrange
        when(
          mockAssessmentDao.clearAllAssessments(),
        ).thenThrow(Exception('Database error'));

        // act
        final call = dataSource.clearAllAssessments;

        // assert
        expect(() => call(), throwsA(isA<CacheException>()));
        verify(mockAssessmentDao.clearAllAssessments());
      });
    });
  });

  group('getUnsubmittedAssessments', () {
    test('should return unsubmitted assessments from DAO', () async {
      // arrange
      final unsubmittedAssessments = [tAssessmentModel1, tAssessmentModel2];
      when(
        mockAssessmentDao.getUnsubmittedAssessments(),
      ).thenAnswer((_) async => unsubmittedAssessments);

      // act
      final result = await dataSource.getUnsubmittedAssessments();

      // assert
      verify(mockAssessmentDao.getUnsubmittedAssessments());
      expect(result, equals(unsubmittedAssessments));
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      when(
        mockAssessmentDao.getUnsubmittedAssessments(),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.getUnsubmittedAssessments;

      // assert
      expect(() => call(), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.getUnsubmittedAssessments());
    });
  });

  group('Stream Methods', () {
    test('watchAllAssessments should return stream from DAO', () {
      // arrange
      final assessmentsStream = Stream.value([
        tAssessmentModel1,
        tAssessmentModel2,
      ]);
      when(
        mockAssessmentDao.watchAllAssessments(),
      ).thenAnswer((_) => assessmentsStream);

      // act
      final result = dataSource.watchAllAssessments();

      // assert
      verify(mockAssessmentDao.watchAllAssessments());
      expect(result, equals(assessmentsStream));
    });

    test('watchEditableAssessments should return stream from DAO', () {
      // arrange
      final editableStream = Stream.value([tAssessmentModel1]);
      when(
        mockAssessmentDao.watchUnsubmittedAssessments(),
      ).thenAnswer((_) => editableStream);

      // act
      final result = dataSource.watchEditableAssessments();

      // assert
      verify(mockAssessmentDao.watchUnsubmittedAssessments());
      expect(result, equals(editableStream));
    });

    test('watchSubmittedAssessments should return stream from DAO', () {
      // arrange
      final submittedStream = Stream.value([tSubmittedAssessment]);
      when(
        mockAssessmentDao.watchSubmittedAssessments(),
      ).thenAnswer((_) => submittedStream);

      // act
      final result = dataSource.watchSubmittedAssessments();

      // assert
      verify(mockAssessmentDao.watchSubmittedAssessments());
      expect(result, equals(submittedStream));
    });
  });

  group('deleteAllAssessments', () {
    test(
      'should delete all assessments successfully when all are deleted',
      () async {
        // arrange
        final assessmentIds = [tAssessmentId1, tAssessmentId2];
        when(
          mockAssessmentDao.deleteAllAssessments(assessmentIds),
        ).thenAnswer((_) async => 2); // All 2 assessments deleted

        // act
        final result = await dataSource.deleteAllAssessments(assessmentIds);

        // assert
        verify(mockAssessmentDao.deleteAllAssessments(assessmentIds));
        expect(result, isTrue);
      },
    );

    test('should return true when assessmentIds list is empty', () async {
      // arrange
      final emptyList = <String>[];

      // act
      final result = await dataSource.deleteAllAssessments(emptyList);

      // assert
      verifyZeroInteractions(mockAssessmentDao);
      expect(result, isTrue);
    });

    test('should return false when not all assessments are deleted', () async {
      // arrange
      final assessmentIds = [tAssessmentId1, tAssessmentId2, 'test-id-3'];
      when(
        mockAssessmentDao.deleteAllAssessments(assessmentIds),
      ).thenAnswer((_) async => 2); // Only 2 out of 3 deleted

      // act
      final result = await dataSource.deleteAllAssessments(assessmentIds);

      // assert
      verify(mockAssessmentDao.deleteAllAssessments(assessmentIds));
      expect(result, isFalse);
    });

    test('should return false when no assessments are deleted', () async {
      // arrange
      final assessmentIds = [tAssessmentId1, tAssessmentId2];
      when(
        mockAssessmentDao.deleteAllAssessments(assessmentIds),
      ).thenAnswer((_) async => 0); // None deleted

      // act
      final result = await dataSource.deleteAllAssessments(assessmentIds);

      // assert
      verify(mockAssessmentDao.deleteAllAssessments(assessmentIds));
      expect(result, isFalse);
    });

    test('should throw CacheException when DAO throws an error', () {
      // arrange
      final assessmentIds = [tAssessmentId1, tAssessmentId2];
      when(
        mockAssessmentDao.deleteAllAssessments(assessmentIds),
      ).thenThrow(Exception('Database error'));

      // act
      final call = dataSource.deleteAllAssessments;

      // assert
      expect(() => call(assessmentIds), throwsA(isA<CacheException>()));
      verify(mockAssessmentDao.deleteAllAssessments(assessmentIds));
    });

    test(
      'should pass correct number of IDs in error message when exception occurs',
      () async {
        // arrange
        final assessmentIds = ['id1', 'id2', 'id3', 'id4', 'id5'];
        when(
          mockAssessmentDao.deleteAllAssessments(assessmentIds),
        ).thenThrow(Exception('Database error'));

        // act & assert
        try {
          await dataSource.deleteAllAssessments(assessmentIds);
          fail('Should have thrown CacheException');
        } catch (e) {
          expect(e, isA<CacheException>());
          expect(
            (e as CacheException).message,
            contains('Failed to delete 5 assessments'),
          );
        }
      },
    );

    test(
      'should handle single assessment deletion via deleteAllAssessments',
      () async {
        // arrange
        final singleId = [tAssessmentId1];
        when(
          mockAssessmentDao.deleteAllAssessments(singleId),
        ).thenAnswer((_) async => 1);

        // act
        final result = await dataSource.deleteAllAssessments(singleId);

        // assert
        verify(mockAssessmentDao.deleteAllAssessments(singleId));
        expect(result, isTrue);
      },
    );
  });
}
