import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';

void main() {
  final tFacilityIdModel = FacilityIdentificationModel(
    facilityCode: 'F12345',
    facilityName: 'City Hospital',
    managingAuthority: ManagingAuthorityType.government,
    directorName: 'Dr. Jane Smith',
    directorPhone: '5551234567',
    directorEmail: 'jsmith@cityhospital.org',
    respondentName: 'John Doe',
    respondentPosition: 'Facility Manager',
    structureType: FacilityStructureType.permanent,
    facilityType: FacilityType.screeningAndTemporaryIsolation,
    existingFacilityType: ExistingFacilityType.firstReferralHospital,
  );

  final tFacilityIdJson = {
    'facility_code': 'F12345',
    'facility_name': 'City Hospital',
    'managing_authority': 0, // government = 0
    'other_managing_authority': null,
    'director_name': 'Dr. Jane Smith',
    'director_phone': '5551234567',
    'director_email': 'jsmith@cityhospital.org',
    'respondent_name': 'John Doe',
    'respondent_position': 'Facility Manager',
    'structure_type': 0, // permanent = 0
    'facility_type': 0, // screeningAndTemporaryIsolation = 0
    'existing_facility_type': 0, // firstReferralHospital = 0
    'other_existing_facility_type': null,
  };

  final tFacilityIdModelWithOptionalFields = FacilityIdentificationModel(
    facilityCode: 'F12345',
    facilityName: 'City Hospital',
    managingAuthority: ManagingAuthorityType.other,
    otherManagingAuthority: 'Community Cooperative',
    directorName: 'Dr. Jane Smith',
    directorPhone: '5551234567',
    directorEmail: 'jsmith@cityhospital.org',
    respondentName: 'John Doe',
    respondentPosition: 'Facility Manager',
    structureType: FacilityStructureType.temporaryShortTerm,
    facilityType: FacilityType.standaloneTreatmentCenter,
    // No existing facility type for standalone centers
  );

  final tFacilityIdJsonWithOptionalFields = {
    'facility_code': 'F12345',
    'facility_name': 'City Hospital',
    'managing_authority': 5, // other = 5
    'other_managing_authority': 'Community Cooperative',
    'director_name': 'Dr. Jane Smith',
    'director_phone': '5551234567',
    'director_email': 'jsmith@cityhospital.org',
    'respondent_name': 'John Doe',
    'respondent_position': 'Facility Manager',
    'structure_type': 2, // temporaryShortTerm = 2
    'facility_type': 1, // standaloneTreatmentCenter = 1
    'existing_facility_type': null,
    'other_existing_facility_type': null,
  };

  group('FacilityIdentificationModel', () {
    test('should be a subclass of FacilityIdentification entity', () {
      // Arrange
      // Act
      // Assert
      expect(tFacilityIdModel, isA<FacilityIdentificationEntity>());
    });

    group('fromJson', () {
      test(
        'should return a valid model when the JSON is valid with required fields only',
        () {
          // Arrange
          final Map<String, dynamic> jsonMap = tFacilityIdJson;
          // Act
          final result = FacilityIdentificationModel.fromJson(jsonMap);
          // Assert
          expect(result.facilityCode, tFacilityIdModel.facilityCode);
          expect(result.facilityName, tFacilityIdModel.facilityName);
          expect(result.managingAuthority, tFacilityIdModel.managingAuthority);
          expect(result.directorName, tFacilityIdModel.directorName);
          expect(result.directorPhone, tFacilityIdModel.directorPhone);
          expect(result.directorEmail, tFacilityIdModel.directorEmail);
          expect(result.respondentName, tFacilityIdModel.respondentName);
          expect(
            result.respondentPosition,
            tFacilityIdModel.respondentPosition,
          );
          expect(result.structureType, tFacilityIdModel.structureType);
          expect(result.facilityType, tFacilityIdModel.facilityType);
          expect(
            result.existingFacilityType,
            tFacilityIdModel.existingFacilityType,
          );
        },
      );

      test(
        'should return a valid model when the JSON includes optional fields',
        () {
          // Arrange
          final Map<String, dynamic> jsonMap =
              tFacilityIdJsonWithOptionalFields;
          // Act
          final result = FacilityIdentificationModel.fromJson(jsonMap);
          // Assert
          expect(result.otherManagingAuthority, 'Community Cooperative');
          expect(result.managingAuthority, ManagingAuthorityType.other);
          expect(
            result.structureType,
            FacilityStructureType.temporaryShortTerm,
          );
          expect(result.facilityType, FacilityType.standaloneTreatmentCenter);
          expect(result.existingFacilityType, null);
        },
      );

      test('should correctly parse all enum types from JSON', () {
        for (int i = 0; i < ManagingAuthorityType.values.length; i++) {
          // Arrange
          final jsonWithAuth = Map<String, dynamic>.from(tFacilityIdJson);
          jsonWithAuth['managing_authority'] = i;

          // Act
          final result = FacilityIdentificationModel.fromJson(jsonWithAuth);
          // Assert
          expect(result.managingAuthority, ManagingAuthorityType.values[i]);
        }

        for (int i = 0; i < FacilityStructureType.values.length; i++) {
          // Arrange
          final jsonWithStructure = Map<String, dynamic>.from(tFacilityIdJson);
          jsonWithStructure['structure_type'] = i;

          // Act
          final result = FacilityIdentificationModel.fromJson(
            jsonWithStructure,
          );
          // Assert
          expect(result.structureType, FacilityStructureType.values[i]);
        }

        for (int i = 0; i < FacilityType.values.length; i++) {
          // Arrange
          final jsonWithFacilityType = Map<String, dynamic>.from(
            tFacilityIdJson,
          );
          jsonWithFacilityType['facility_type'] = i;
          // Act
          final result = FacilityIdentificationModel.fromJson(
            jsonWithFacilityType,
          );
          // Assert
          expect(result.facilityType, FacilityType.values[i]);
        }

        for (int i = 0; i < ExistingFacilityType.values.length; i++) {
          // Arrange
          final jsonWithExistingType = Map<String, dynamic>.from(
            tFacilityIdJson,
          );
          jsonWithExistingType['existing_facility_type'] = i;
          // Act
          final result = FacilityIdentificationModel.fromJson(
            jsonWithExistingType,
          );
          // Assert
          expect(result.existingFacilityType, ExistingFacilityType.values[i]);
        }
      });
    });

    group('toJson', () {
      test(
        'should return a JSON map containing the proper data with required fields',
        () {
          // Arrange
          // act
          final result = tFacilityIdModel.toJson();
          // Assert
          expect(result, tFacilityIdJson);
        },
      );

      test(
        'should return a JSON map containing the proper data with optional fields',
        () {
          // Arrange
          // Act
          final result = tFacilityIdModelWithOptionalFields.toJson();
          // Assert
          expect(result, tFacilityIdJsonWithOptionalFields);
        },
      );

      test('should correctly convert enum types to integers', () {
        // Arrange
        // Act
        final result = tFacilityIdModel.toJson();
        // Assert
        expect(result['managing_authority'], 0); // government = 0
        expect(result['structure_type'], 0); // permanent = 0
        expect(
          result['facility_type'],
          0,
        ); // screeningAndTemporaryIsolation = 0
        expect(
          result['existing_facility_type'],
          0,
        ); // firstReferralHospital = 0

        // Check other model with different enum values
        final otherResult = tFacilityIdModelWithOptionalFields.toJson();
        expect(otherResult['managing_authority'], 5); // other = 5
        expect(otherResult['structure_type'], 2); // temporaryShortTerm = 2
        expect(
          otherResult['facility_type'],
          1,
        ); // standaloneTreatmentCenter = 1
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // Arrange
        final entity = FacilityIdentificationEntity(
          facilityCode: 'F12345',
          facilityName: 'City Hospital',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Dr. Jane Smith',
          directorPhone: '5551234567',
          directorEmail: 'jsmith@cityhospital.org',
          respondentName: 'John Doe',
          respondentPosition: 'Facility Manager',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
          existingFacilityType: ExistingFacilityType.firstReferralHospital,
        );
        // Act
        final result = FacilityIdentificationModel.fromEntity(entity);
        // Assert
        expect(result, tFacilityIdModel);
      });
    });
  });
}
