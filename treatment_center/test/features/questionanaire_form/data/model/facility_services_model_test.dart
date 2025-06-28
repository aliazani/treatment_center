import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';

void main() {
  final tFacilityServicesModel = FacilityServicesModel(
    hasOutpatientServices: true,
    hasInpatientServices: true,
    totalInpatientBeds: 100,
    icuBeds: 20,
    hasEmergencyUnit: true,
    hasIcuOrHighDependencyUnit: true,
  );

  final tFacilityServicesJson = {
    'has_outpatient_services': true,
    'has_inpatient_services': true,
    'total_inpatient_beds': 100,
    'icu_beds': 20,
    'has_emergency_unit': true,
    'has_icu_or_high_dependency_unit': true,
  };

  final tFacilityServicesModelNoInpatient = FacilityServicesModel(
    hasOutpatientServices: true,
    hasInpatientServices: false,
    // No inpatient beds or ICU beds for outpatient-only facility
    hasEmergencyUnit: true,
    hasIcuOrHighDependencyUnit: false,
  );

  final tFacilityServicesJsonNoInpatient = {
    'has_outpatient_services': true,
    'has_inpatient_services': false,
    'total_inpatient_beds': null,
    'icu_beds': null,
    'has_emergency_unit': true,
    'has_icu_or_high_dependency_unit': false,
  };

  group('FacilityServicesModel', () {
    test('should be a subclass of FacilityServices entity', () {
      // Arrange
      // Act
      // Assert
      expect(tFacilityServicesModel, isA<FacilityServicesEntity>());
    });

    group('fromJson', () {
      test(
        'should return a valid model when the JSON is valid with all fields',
        () {
          // Arrange
          final Map<String, dynamic> jsonMap = tFacilityServicesJson;
          // Act
          final result = FacilityServicesModel.fromJson(jsonMap);
          // Assert
          expect(result, tFacilityServicesModel);
        },
      );

      test(
        'should return a valid model when the JSON has no inpatient services',
        () {
          // Arrange
          final Map<String, dynamic> jsonMap = tFacilityServicesJsonNoInpatient;
          // Act
          final result = FacilityServicesModel.fromJson(jsonMap);
          // Assert
          expect(result, tFacilityServicesModelNoInpatient);
        },
      );

      test('should correctly handle null values for optional fields', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'has_outpatient_services': true,
          'has_inpatient_services': true,
          'total_inpatient_beds': null,
          'icu_beds': null,
          'has_emergency_unit': null,
          'has_icu_or_high_dependency_unit': null,
        };
        // Act
        final result = FacilityServicesModel.fromJson(jsonMap);
        // Assert
        expect(result.totalInpatientBeds, null);
        expect(result.icuBeds, null);
        expect(result.hasEmergencyUnit, null);
        expect(result.hasIcuOrHighDependencyUnit, null);
      });
    });

    group('toJson', () {
      test(
        'should return a JSON map containing the proper data with all fields',
        () {
          // Arrange
          // Act
          final result = tFacilityServicesModel.toJson();
          // Assert
          expect(result, tFacilityServicesJson);
        },
      );

      test('should return a JSON map with null values for optional fields', () {
        // Arrange
        // Act
        final result = tFacilityServicesModelNoInpatient.toJson();
        // Assert
        expect(result, tFacilityServicesJsonNoInpatient);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // Arrange
        final entity = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 100,
          icuBeds: 20,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );
        // Act
        final result = FacilityServicesModel.fromEntity(entity);
        // Assert
        expect(result, tFacilityServicesModel);
        expect(result.hasOutpatientServices, entity.hasOutpatientServices);
        expect(result.hasInpatientServices, entity.hasInpatientServices);
        expect(result.totalInpatientBeds, entity.totalInpatientBeds);
        expect(result.icuBeds, entity.icuBeds);
        expect(result.hasEmergencyUnit, entity.hasEmergencyUnit);
        expect(
          result.hasIcuOrHighDependencyUnit,
          entity.hasIcuOrHighDependencyUnit,
        );
      });
    });

    group('validation', () {
      test(
        'isIcuBedsCountValid should return true when ICU beds <= total beds',
        () {
          // Arrange
          final validServices = FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: 100,
            icuBeds: 20, // 20 <= 100, valid
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          );
          // Act
          // Assert
          expect(validServices.isIcuBedsCountValid, true);
        },
      );

      test(
        'isIcuBedsCountValid should return true when ICU beds = total beds',
        () {
          // Arrange
          final validServices = FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: 20,
            icuBeds: 20, // 20 = 20, edge case but valid
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          );
          // Act
          // Assert
          expect(validServices.isIcuBedsCountValid, true);
        },
      );

      test(
        'isIcuBedsCountValid should return false when ICU beds > total beds',
        () {
          // Arrange
          final invalidServices = FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: 10,
            icuBeds: 20, // 20 > 10, invalid
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          );
          // Act
          // Assert
          expect(invalidServices.isIcuBedsCountValid, false);
        },
      );

      test(
        'isIcuBedsCountValid should return true when either bed count is null',
        () {
          // Arrange
          final nullTotalServices = FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: null,
            icuBeds: 20,
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          );

          final nullIcuServices = FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: 100,
            icuBeds: null,
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          );

          final bothNullServices = FacilityServicesModel(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: null,
            icuBeds: null,
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          );

          // Act
          // Assert
          expect(nullTotalServices.isIcuBedsCountValid, true);
          expect(nullIcuServices.isIcuBedsCountValid, true);
          expect(bothNullServices.isIcuBedsCountValid, true);
        },
      );
    });
  });
}
