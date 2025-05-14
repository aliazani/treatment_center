import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services.dart';

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
      // assert
      expect(tFacilityServicesModel, isA<FacilityServices>());
    });

    group('fromJson', () {
      test('should return a valid model when the JSON is valid with all fields', () {
        // arrange
        final Map<String, dynamic> jsonMap = tFacilityServicesJson;
        // act
        final result = FacilityServicesModel.fromJson(jsonMap);
        // assert
        expect(result, tFacilityServicesModel);
      });

      test('should return a valid model when the JSON has no inpatient services', () {
        // arrange
        final Map<String, dynamic> jsonMap = tFacilityServicesJsonNoInpatient;
        // act
        final result = FacilityServicesModel.fromJson(jsonMap);
        // assert
        expect(result, tFacilityServicesModelNoInpatient);
      });

      test('should correctly handle null values for optional fields', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'has_outpatient_services': true,
          'has_inpatient_services': true,
          'total_inpatient_beds': null,
          'icu_beds': null,
          'has_emergency_unit': null,
          'has_icu_or_high_dependency_unit': null,
        };
        // act
        final result = FacilityServicesModel.fromJson(jsonMap);
        // assert
        expect(result.totalInpatientBeds, null);
        expect(result.icuBeds, null);
        expect(result.hasEmergencyUnit, null);
        expect(result.hasIcuOrHighDependencyUnit, null);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data with all fields', () {
        // act
        final result = tFacilityServicesModel.toJson();
        // assert
        expect(result, tFacilityServicesJson);
      });

      test('should return a JSON map with null values for optional fields', () {
        // act
        final result = tFacilityServicesModelNoInpatient.toJson();
        // assert
        expect(result, tFacilityServicesJsonNoInpatient);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // arrange
        final entity = FacilityServices(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 100,
          icuBeds: 20,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );
        // act
        final result = FacilityServicesModel.fromEntity(entity);
        // assert
        expect(result, tFacilityServicesModel);
        expect(result.hasOutpatientServices, entity.hasOutpatientServices);
        expect(result.hasInpatientServices, entity.hasInpatientServices);
        expect(result.totalInpatientBeds, entity.totalInpatientBeds);
        expect(result.icuBeds, entity.icuBeds);
        expect(result.hasEmergencyUnit, entity.hasEmergencyUnit);
        expect(result.hasIcuOrHighDependencyUnit, entity.hasIcuOrHighDependencyUnit);
      });
    });

    group('validation', () {
      test('isIcuBedsCountValid should return true when ICU beds <= total beds', () {
        // arrange
        final validServices = FacilityServicesModel(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 100,
          icuBeds: 20, // 20 <= 100, valid
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );
        // assert
        expect(validServices.isIcuBedsCountValid, true);
      });
      
      test('isIcuBedsCountValid should return true when ICU beds = total beds', () {
        // arrange
        final validServices = FacilityServicesModel(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 20,
          icuBeds: 20, // 20 = 20, edge case but valid
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );
        // assert
        expect(validServices.isIcuBedsCountValid, true);
      });

      test('isIcuBedsCountValid should return false when ICU beds > total beds', () {
        // arrange
        final invalidServices = FacilityServicesModel(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 10,
          icuBeds: 20, // 20 > 10, invalid
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );
        // assert
        expect(invalidServices.isIcuBedsCountValid, false);
      });

      test('isIcuBedsCountValid should return true when either bed count is null', () {
        // arrange
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
        
        // assert
        expect(nullTotalServices.isIcuBedsCountValid, true);
        expect(nullIcuServices.isIcuBedsCountValid, true);
        expect(bothNullServices.isIcuBedsCountValid, true);
      });
    });
  });
}