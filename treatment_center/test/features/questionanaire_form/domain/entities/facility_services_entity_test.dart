import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';

void main() {
  group('FacilityServices', () {
    test(
      'should create a valid FacilityServices instance with inpatient services',
      () {
        // Arrange & Act
        final facilityServices = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 100,
          icuBeds: 10,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );

        // Assert
        expect(facilityServices.hasOutpatientServices, true);
        expect(facilityServices.hasInpatientServices, true);
        expect(facilityServices.totalInpatientBeds, 100);
        expect(facilityServices.icuBeds, 10);
        expect(facilityServices.hasEmergencyUnit, true);
        expect(facilityServices.hasIcuOrHighDependencyUnit, true);
        expect(facilityServices.isIcuBedsCountValid, true);
      },
    );

    test(
      'should create a valid FacilityServices instance without inpatient services',
      () {
        // Arrange & Act
        final facilityServices = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false,
        );

        // Assert
        expect(facilityServices.hasOutpatientServices, true);
        expect(facilityServices.hasInpatientServices, false);
        expect(facilityServices.totalInpatientBeds, isNull);
        expect(facilityServices.icuBeds, isNull);
        expect(facilityServices.hasEmergencyUnit, false);
        expect(facilityServices.hasIcuOrHighDependencyUnit, false);
        expect(facilityServices.isIcuBedsCountValid, true);
      },
    );

    test('should validate that ICU beds count is less than total beds', () {
      // Arrange & Act
      final validServices = FacilityServicesEntity(
        hasOutpatientServices: true,
        hasInpatientServices: true,
        totalInpatientBeds: 100,
        icuBeds: 10,
      );

      final invalidServices = FacilityServicesEntity(
        hasOutpatientServices: true,
        hasInpatientServices: true,
        totalInpatientBeds: 10,
        icuBeds: 20,
      );

      // Assert
      expect(validServices.isIcuBedsCountValid, true);
      expect(invalidServices.isIcuBedsCountValid, false);
    });

    test('two instances with the same values should be equal', () {
      // Arrange
      final facilityServices1 = FacilityServicesEntity(
        hasOutpatientServices: true,
        hasInpatientServices: true,
        totalInpatientBeds: 100,
        icuBeds: 10,
        hasEmergencyUnit: true,
        hasIcuOrHighDependencyUnit: true,
      );

      final facilityServices2 = FacilityServicesEntity(
        hasOutpatientServices: true,
        hasInpatientServices: true,
        totalInpatientBeds: 100,
        icuBeds: 10,
        hasEmergencyUnit: true,
        hasIcuOrHighDependencyUnit: true,
      );

      // Act & Assert
      expect(facilityServices1, equals(facilityServices2));
    });
  });
}
