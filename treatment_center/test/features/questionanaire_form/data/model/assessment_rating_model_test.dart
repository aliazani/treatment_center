import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';

void main() {
  // Test model instances
  late AssessmentRatingModel tRatingModel;
  late Map<String, dynamic> tRatingJson;

  setUp(() {
    tRatingModel = const AssessmentRatingModel(
      id: 'rating_id_1',
      value: 3,
      label: 'Meets target (+++) (3)',
      description: 'Fully meets requirements',
    );

    tRatingJson = {
      'id': 'rating_id_1',
      'value': 3,
      'label': 'Meets target (+++) (3)',
      'description': 'Fully meets requirements',
    };
  });

  group('AssessmentRatingModel', () {
    test('should be a subclass of AssessmentRatingEntity', () {
      expect(tRatingModel, isA<AssessmentRatingEntity>());
    });

    group('fromJson factory constructor', () {
      test('should correctly deserialize from valid JSON', () {
        final result = AssessmentRatingModel.fromJson(tRatingJson);

        expect(result.id, tRatingModel.id);
        expect(result.value, tRatingModel.value);
        expect(result.label, tRatingModel.label);
        expect(result.description, tRatingModel.description);
      });

      test('should handle all data types correctly', () {
        final testCases = [
          {
            'json': {
              'id': 'test',
              'value': 3,
              'label': 'Label',
              'description': 'Desc',
            },
            'expectedValue': 3,
          },
          {
            'json': {
              'id': 'test',
              'value': 0,
              'label': 'Label',
              'description': 'Desc',
            },
            'expectedValue': 0,
          },
          {
            'json': {
              'id': 'test',
              'value': -1,
              'label': 'Label',
              'description': 'Desc',
            },
            'expectedValue': -1,
          },
        ];

        for (final testCase in testCases) {
          final result = AssessmentRatingModel.fromJson(
            testCase['json'] as Map<String, dynamic>,
          );
          expect(result.value, testCase['expectedValue']);
        }
      });

      group('JSON edge cases', () {
        test('should handle empty strings', () {
          final json = {'id': '', 'value': 0, 'label': '', 'description': ''};

          final result = AssessmentRatingModel.fromJson(json);

          expect(result.id, '');
          expect(result.label, '');
          expect(result.description, '');
          expect(result.value, 0);
        });

        test('should handle special characters in text fields', () {
          const specialText = 'Special chars: àáâãäå & < > " \' €';
          final json = {
            'id': 'special_id',
            'value': 1,
            'label': specialText,
            'description': specialText,
          };

          final result = AssessmentRatingModel.fromJson(json);

          expect(result.label, specialText);
          expect(result.description, specialText);
        });

        test('should handle very long text fields', () {
          final longText = 'A' * 1000;
          final json = {
            'id': 'long_text',
            'value': 2,
            'label': longText,
            'description': longText,
          };

          final result = AssessmentRatingModel.fromJson(json);

          expect(result.label, longText);
          expect(result.description, longText);
        });

        test('should handle unicode characters', () {
          const unicodeText = 'Unicode: 🏥⚕️🩺 Arabic: العربية Chinese: 中文';
          final json = {
            'id': 'unicode_test',
            'value': 3,
            'label': unicodeText,
            'description': unicodeText,
          };

          final result = AssessmentRatingModel.fromJson(json);

          expect(result.label, unicodeText);
          expect(result.description, unicodeText);
        });

        test('should handle extreme integer values', () {
          final extremeValues = [
            -2147483648, // int32 min
            2147483647, // int32 max
            0,
            -1,
            1,
          ];

          for (final value in extremeValues) {
            final json = {
              'id': 'extreme_$value',
              'value': value,
              'label': 'Label $value',
              'description': 'Description $value',
            };

            final result = AssessmentRatingModel.fromJson(json);
            expect(result.value, value);
          }
        });
      });
    });

    group('toJson method', () {
      test('should serialize correctly to JSON', () {
        final result = tRatingModel.toJson();

        expect(result, equals(tRatingJson));
        expect(result['id'], tRatingModel.id);
        expect(result['value'], tRatingModel.value);
        expect(result['label'], tRatingModel.label);
        expect(result['description'], tRatingModel.description);
      });

      test('should handle empty values correctly', () {
        const emptyRating = AssessmentRatingModel(
          id: '',
          value: 0,
          label: '',
          description: '',
        );

        final result = emptyRating.toJson();

        expect(result['id'], '');
        expect(result['value'], 0);
        expect(result['label'], '');
        expect(result['description'], '');
      });

      test('should preserve special characters', () {
        const specialRating = AssessmentRatingModel(
          id: 'special_&<>"\'',
          value: 1,
          label: 'Label with & < > " \'',
          description: 'Description with special chars: €\$¥£',
        );

        final result = specialRating.toJson();

        expect(result['id'], 'special_&<>"\'');
        expect(result['label'], 'Label with & < > " \'');
        expect(result['description'], 'Description with special chars: €\$¥£');
      });
    });

    group('fromEntity factory constructor', () {
      test('should convert entity to model correctly', () {
        final entity = AssessmentRatingEntity(
          id: 'entity_id',
          value: 2,
          label: 'Entity Label',
          description: 'Entity Description',
        );

        final result = AssessmentRatingModel.fromEntity(entity);

        expect(result, isA<AssessmentRatingModel>());
        expect(result.id, entity.id);
        expect(result.value, entity.value);
        expect(result.label, entity.label);
        expect(result.description, entity.description);
      });

      test('should handle entity with all rating values', () {
        final testValues = [-1, 0, 1, 2, 3];

        for (final value in testValues) {
          final entity = AssessmentRatingEntity(
            id: 'test_$value',
            value: value,
            label: 'Label $value',
            description: 'Description $value',
          );

          final result = AssessmentRatingModel.fromEntity(entity);

          expect(result.value, value);
          expect(result.id, 'test_$value');
        }
      });

      test('should handle entity with empty/null-like values', () {
        final entity = AssessmentRatingEntity(
          id: '',
          value: 0,
          label: '',
          description: '',
        );

        final result = AssessmentRatingModel.fromEntity(entity);

        expect(result.id, '');
        expect(result.value, 0);
        expect(result.label, '');
        expect(result.description, '');
      });
    });

    group('toEntity method', () {
      test('should convert model to entity correctly', () {
        final result = tRatingModel.toEntity();

        expect(result, isA<AssessmentRatingEntity>());
        expect(result.id, tRatingModel.id);
        expect(result.value, tRatingModel.value);
        expect(result.label, tRatingModel.label);
        expect(result.description, tRatingModel.description);
      });

      test('should handle all predefined rating types', () {
        final predefinedRatings = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        for (final rating in predefinedRatings) {
          final entity = rating.toEntity();

          expect(entity.id, rating.id);
          expect(entity.value, rating.value);
          expect(entity.label, rating.label);
          expect(entity.description, rating.description);
        }
      });
    });

    group('Predefined factory constructors', () {
      group('meetsTarget', () {
        test('should create correct model with proper values', () {
          final result = AssessmentRatingModel.meetsTarget();

          expect(result.id, 'meets_target');
          expect(result.value, 3);
          expect(result.label, 'Meets target (+++) (3)');
          expect(
            result.description,
            'The facility fully meets the requirements for this aspect of the assessment.',
          );
        });

        test('should always return same values', () {
          final first = AssessmentRatingModel.meetsTarget();
          final second = AssessmentRatingModel.meetsTarget();

          expect(first.id, second.id);
          expect(first.value, second.value);
          expect(first.label, second.label);
          expect(first.description, second.description);
        });
      });

      group('partiallyMeetsTarget', () {
        test('should create correct model with proper values', () {
          final result = AssessmentRatingModel.partiallyMeetsTarget();

          expect(result.id, 'partially_meets');
          expect(result.value, 2);
          expect(result.label, 'Partially meets target (++) (2)');
          expect(
            result.description,
            'The facility partially meets the requirements for this aspect of the assessment.',
          );
        });

        test('should be consistent across calls', () {
          final first = AssessmentRatingModel.partiallyMeetsTarget();
          final second = AssessmentRatingModel.partiallyMeetsTarget();

          expect(first.value, second.value);
          expect(first.id, second.id);
        });
      });

      group('doesNotMeetTarget', () {
        test('should create correct model with proper values', () {
          final result = AssessmentRatingModel.doesNotMeetTarget();

          expect(result.id, 'does_not_meet');
          expect(result.value, 1);
          expect(result.label, 'Does not meet target (+) (1)');
          expect(
            result.description,
            'The facility does not meet the requirements for this aspect of the assessment.',
          );
        });

        test('should maintain consistency', () {
          final first = AssessmentRatingModel.doesNotMeetTarget();
          final second = AssessmentRatingModel.doesNotMeetTarget();

          expect(first.value, second.value);
          expect(first.description, second.description);
        });
      });

      group('dontKnow', () {
        test('should create correct model with proper values', () {
          final result = AssessmentRatingModel.dontKnow();

          expect(result.id, 'dont_know');
          expect(result.value, 0);
          expect(result.label, 'Don\'t Know (DK)');
          expect(
            result.description,
            'It is not possible to determine if the facility meets this requirement.',
          );
        });

        test('should handle apostrophe in label correctly', () {
          final result = AssessmentRatingModel.dontKnow();

          expect(result.label.contains('\''), true);
          expect(result.label, 'Don\'t Know (DK)');
        });
      });

      group('notApplicable', () {
        test('should create correct model with proper values', () {
          final result = AssessmentRatingModel.notApplicable();

          expect(result.id, 'not_applicable');
          expect(result.value, -1);
          expect(result.label, 'Not Applicable (NA)');
          expect(
            result.description,
            'This requirement does not apply to this facility.',
          );
        });

        test('should have negative value', () {
          final result = AssessmentRatingModel.notApplicable();

          expect(result.value, -1);
          expect(result.value < 0, true);
        });
      });

      test('all predefined constructors should have unique values', () {
        final ratings = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        final values = ratings.map((r) => r.value).toSet();
        final ids = ratings.map((r) => r.id).toSet();

        expect(values.length, 5); // All values should be unique
        expect(ids.length, 5); // All IDs should be unique
      });

      test('predefined constructors should have proper value ordering', () {
        expect(AssessmentRatingModel.meetsTarget().value, 3);
        expect(AssessmentRatingModel.partiallyMeetsTarget().value, 2);
        expect(AssessmentRatingModel.doesNotMeetTarget().value, 1);
        expect(AssessmentRatingModel.dontKnow().value, 0);
        expect(AssessmentRatingModel.notApplicable().value, -1);

        // Verify ordering
        expect(
          AssessmentRatingModel.meetsTarget().value >
              AssessmentRatingModel.partiallyMeetsTarget().value,
          true,
        );
        expect(
          AssessmentRatingModel.partiallyMeetsTarget().value >
              AssessmentRatingModel.doesNotMeetTarget().value,
          true,
        );
        expect(
          AssessmentRatingModel.doesNotMeetTarget().value >
              AssessmentRatingModel.dontKnow().value,
          true,
        );
        expect(
          AssessmentRatingModel.dontKnow().value >
              AssessmentRatingModel.notApplicable().value,
          true,
        );
      });
    });

    group('JSON round-trip tests', () {
      test(
        'should maintain data integrity through JSON serialization cycle',
        () {
          final json = tRatingModel.toJson();
          final restored = AssessmentRatingModel.fromJson(json);
          final jsonAgain = restored.toJson();

          expect(jsonAgain, equals(json));
          expect(restored.id, tRatingModel.id);
          expect(restored.value, tRatingModel.value);
          expect(restored.label, tRatingModel.label);
          expect(restored.description, tRatingModel.description);
        },
      );

      test('should handle all predefined ratings in round-trip', () {
        final predefinedRatings = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        for (final rating in predefinedRatings) {
          final json = rating.toJson();
          final restored = AssessmentRatingModel.fromJson(json);

          expect(restored.id, rating.id);
          expect(restored.value, rating.value);
          expect(restored.label, rating.label);
          expect(restored.description, rating.description);
        }
      });

      test('should handle complex text in round-trip', () {
        const complexRating = AssessmentRatingModel(
          id: 'complex_test',
          value: 2,
          label: 'Complex label with special chars: àáâãäå & < > " \'',
          description:
              'Complex description with unicode: 🏥⚕️🩺 and symbols: €\$¥£',
        );

        final json = complexRating.toJson();
        final restored = AssessmentRatingModel.fromJson(json);

        expect(restored.label, complexRating.label);
        expect(restored.description, complexRating.description);
        expect(restored.value, complexRating.value);
      });
    });

    group('Entity-Model conversion round-trip tests', () {
      test(
        'should maintain data integrity through entity conversion cycle',
        () {
          final entity = tRatingModel.toEntity();
          final restored = AssessmentRatingModel.fromEntity(entity);

          expect(restored.id, tRatingModel.id);
          expect(restored.value, tRatingModel.value);
          expect(restored.label, tRatingModel.label);
          expect(restored.description, tRatingModel.description);
        },
      );

      test('should handle all predefined ratings in entity round-trip', () {
        final predefinedRatings = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        for (final rating in predefinedRatings) {
          final entity = rating.toEntity();
          final restored = AssessmentRatingModel.fromEntity(entity);

          expect(restored.id, rating.id);
          expect(restored.value, rating.value);
          expect(restored.label, rating.label);
          expect(restored.description, rating.description);
        }
      });

      test('should convert between domain and data layers correctly', () {
        // Create domain entity
        final domainEntity = AssessmentRatingEntity(
          id: 'domain_test',
          value: 2,
          label: 'Domain Label',
          description: 'Domain Description',
        );

        // Convert to data model
        final dataModel = AssessmentRatingModel.fromEntity(domainEntity);
        expect(dataModel, isA<AssessmentRatingModel>());

        // Convert back to domain entity
        final backToDomain = dataModel.toEntity();
        expect(backToDomain, isA<AssessmentRatingEntity>());

        // Verify data integrity
        expect(backToDomain.id, domainEntity.id);
        expect(backToDomain.value, domainEntity.value);
        expect(backToDomain.label, domainEntity.label);
        expect(backToDomain.description, domainEntity.description);
      });
    });

    group('Edge cases and error handling', () {
      test('should handle empty string values', () {
        const emptyRating = AssessmentRatingModel(
          id: '',
          value: 0,
          label: '',
          description: '',
        );

        expect(emptyRating.id, '');
        expect(emptyRating.label, '');
        expect(emptyRating.description, '');

        final json = emptyRating.toJson();
        final restored = AssessmentRatingModel.fromJson(json);

        expect(restored.id, '');
        expect(restored.label, '');
        expect(restored.description, '');
      });

      test('should handle very long text content', () {
        final longText = 'A' * 10000;
        final longRating = AssessmentRatingModel(
          id: 'long_test',
          value: 1,
          label: longText,
          description: longText,
        );

        expect(longRating.label, longText);
        expect(longRating.description, longText);

        final json = longRating.toJson();
        final restored = AssessmentRatingModel.fromJson(json);

        expect(restored.label, longText);
        expect(restored.description, longText);
      });

      test('should handle extreme value ranges', () {
        final extremeValues = [-1000000, -1, 0, 1, 1000000];

        for (final value in extremeValues) {
          final rating = AssessmentRatingModel(
            id: 'extreme_$value',
            value: value,
            label: 'Label $value',
            description: 'Description $value',
          );

          expect(rating.value, value);

          final json = rating.toJson();
          final restored = AssessmentRatingModel.fromJson(json);

          expect(restored.value, value);
        }
      });

      test('should handle unicode and special characters', () {
        const unicodeRating = AssessmentRatingModel(
          id: 'unicode_🏥',
          value: 3,
          label: 'Unicode: 🏥⚕️🩺 Arabic: العربية Chinese: 中文',
          description:
              'Special chars: & < > " \' € \$ ¥ £ @ # % ^ * ( ) + = { } [ ] | \\ : ; , . ? / ~',
        );

        final json = unicodeRating.toJson();
        final restored = AssessmentRatingModel.fromJson(json);

        expect(restored.id, unicodeRating.id);
        expect(restored.label, unicodeRating.label);
        expect(restored.description, unicodeRating.description);
      });
    });

    group('Consistency and validation tests', () {
      test('should maintain const constructor immutability', () {
        const rating1 = AssessmentRatingModel(
          id: 'test',
          value: 1,
          label: 'Test',
          description: 'Test',
        );

        const rating2 = AssessmentRatingModel(
          id: 'test',
          value: 1,
          label: 'Test',
          description: 'Test',
        );

        expect(rating1 == rating2, true);
        expect(rating1.hashCode == rating2.hashCode, true);
      });

      test('should have consistent predefined constructor behavior', () {
        // Test multiple calls return equivalent objects
        final meets1 = AssessmentRatingModel.meetsTarget();
        final meets2 = AssessmentRatingModel.meetsTarget();

        expect(meets1.id, meets2.id);
        expect(meets1.value, meets2.value);
        expect(meets1.label, meets2.label);
        expect(meets1.description, meets2.description);
      });

      test('should validate predefined rating descriptions are meaningful', () {
        final ratings = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        for (final rating in ratings) {
          expect(rating.description.isNotEmpty, true);
          expect(
            rating.description.length > 10,
            true,
          ); // Meaningful descriptions
          expect(rating.label.isNotEmpty, true);
          expect(rating.id.isNotEmpty, true);
        }
      });

      test(
        'should have correct label formatting for all predefined ratings',
        () {
          expect(AssessmentRatingModel.meetsTarget().label, contains('(3)'));
          expect(
            AssessmentRatingModel.partiallyMeetsTarget().label,
            contains('(2)'),
          );
          expect(
            AssessmentRatingModel.doesNotMeetTarget().label,
            contains('(1)'),
          );
          expect(AssessmentRatingModel.dontKnow().label, contains('(DK)'));
          expect(AssessmentRatingModel.notApplicable().label, contains('(NA)'));
        },
      );
    });

    group('Performance and boundary tests', () {
      test('should handle multiple ratings efficiently', () {
        final ratings = List.generate(
          1000,
          (index) => AssessmentRatingModel(
            id: 'rating_$index',
            value: index % 4, // 0-3 range
            label: 'Label $index',
            description: 'Description $index',
          ),
        );

        expect(ratings.length, 1000);

        // Test that all ratings can be serialized/deserialized efficiently
        for (final rating in ratings.take(10)) {
          // Test first 10 for performance
          final json = rating.toJson();
          final restored = AssessmentRatingModel.fromJson(json);
          expect(restored.id, rating.id);
          expect(restored.value, rating.value);
        }
      });

      test('should handle boundary integer values', () {
        final boundaryValues = [
          -2147483648, // int32 min
          -1,
          0,
          1,
          2147483647, // int32 max
        ];

        for (final value in boundaryValues) {
          final rating = AssessmentRatingModel(
            id: 'boundary_$value',
            value: value,
            label: 'Boundary $value',
            description: 'Boundary test for $value',
          );

          expect(rating.value, value);

          final json = rating.toJson();
          final restored = AssessmentRatingModel.fromJson(json);
          expect(restored.value, value);

          final entity = rating.toEntity();
          final fromEntity = AssessmentRatingModel.fromEntity(entity);
          expect(fromEntity.value, value);
        }
      });
    });

    group('Integration with assessment system', () {
      test('should work correctly when used in assessment items', () {
        final ratings = [
          AssessmentRatingModel.meetsTarget(),
          AssessmentRatingModel.partiallyMeetsTarget(),
          AssessmentRatingModel.doesNotMeetTarget(),
          AssessmentRatingModel.dontKnow(),
          AssessmentRatingModel.notApplicable(),
        ];

        // Simulate usage in assessment items
        for (int i = 0; i < ratings.length; i++) {
          final rating = ratings[i];

          // Verify rating can be used in JSON context
          final itemJson = {
            'id': 'item_$i',
            'selected_rating': rating.toJson(),
          };

          final restoredRating = AssessmentRatingModel.fromJson(
            itemJson['selected_rating'] as Map<String, dynamic>,
          );

          expect(restoredRating.value, rating.value);
          expect(restoredRating.id, rating.id);
        }
      });

      test('should maintain rating semantics across conversions', () {
        final testScenarios = [
          {
            'rating': AssessmentRatingModel.meetsTarget(),
            'expectedLevel': 'high',
          },
          {
            'rating': AssessmentRatingModel.partiallyMeetsTarget(),
            'expectedLevel': 'medium',
          },
          {
            'rating': AssessmentRatingModel.doesNotMeetTarget(),
            'expectedLevel': 'low',
          },
          {
            'rating': AssessmentRatingModel.dontKnow(),
            'expectedLevel': 'unknown',
          },
          {
            'rating': AssessmentRatingModel.notApplicable(),
            'expectedLevel': 'not_applicable',
          },
        ];

        for (final scenario in testScenarios) {
          final rating = scenario['rating'] as AssessmentRatingModel;

          // Verify semantic meaning is preserved through conversions
          final entity = rating.toEntity();
          final restored = AssessmentRatingModel.fromEntity(entity);

          // Rating semantics should remain consistent
          if (scenario['expectedLevel'] == 'high') {
            expect(restored.value, 3);
          } else if (scenario['expectedLevel'] == 'medium') {
            expect(restored.value, 2);
          } else if (scenario['expectedLevel'] == 'low') {
            expect(restored.value, 1);
          } else if (scenario['expectedLevel'] == 'unknown') {
            expect(restored.value, 0);
          } else if (scenario['expectedLevel'] == 'not_applicable') {
            expect(restored.value, -1);
          }
        }
      });
    });
  });
}
