import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';

void main() {
  group('FacilityIdentification', () {
    test('should create a valid FacilityIdentification instance', () {
      // Arrange & Act
      final facilityIdentification = FacilityIdentificationEntity(
        facilityCode: 'F12345',
        facilityName: 'Bwera Hospital',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dr. Jane Smith',
        directorPhone: '+256789123456',
        directorEmail: 'jane.smith@bwera.org',
        respondentName: 'John Doe',
        respondentPosition: 'IPC Focal Person',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.firstReferralHospital,
      );

      // Assert
      expect(facilityIdentification.facilityCode, 'F12345');
      expect(facilityIdentification.facilityName, 'Bwera Hospital');
      expect(
        facilityIdentification.managingAuthority,
        ManagingAuthorityType.government,
      );
      expect(facilityIdentification.otherManagingAuthority, isNull);
      expect(facilityIdentification.directorName, 'Dr. Jane Smith');
      expect(facilityIdentification.directorPhone, '+256789123456');
      expect(facilityIdentification.directorEmail, 'jane.smith@bwera.org');
      expect(facilityIdentification.respondentName, 'John Doe');
      expect(facilityIdentification.respondentPosition, 'IPC Focal Person');
      expect(
        facilityIdentification.structureType,
        FacilityStructureType.permanent,
      );
      expect(
        facilityIdentification.facilityType,
        FacilityType.screeningAndTemporaryIsolation,
      );
      expect(
        facilityIdentification.existingFacilityType,
        ExistingFacilityType.firstReferralHospital,
      );
      expect(facilityIdentification.otherExistingFacilityType, isNull);
    });

    test('should create an instance with "other" managing authority', () {
      // Arrange & Act
      final facilityIdentification = FacilityIdentificationEntity(
        facilityCode: 'F67890',
        facilityName: 'Community Treatment Center',
        managingAuthority: ManagingAuthorityType.other,
        otherManagingAuthority: 'International NGO Consortium',
        directorName: 'Dr. John Smith',
        directorPhone: '+256712345678',
        directorEmail: 'john.smith@ngo.org',
        respondentName: 'Jane Doe',
        respondentPosition: 'Center Coordinator',
        structureType: FacilityStructureType.temporaryMediumTerm,
        facilityType: FacilityType.standaloneTreatmentCenter,
      );

      // Assert
      expect(
        facilityIdentification.managingAuthority,
        ManagingAuthorityType.other,
      );
      expect(
        facilityIdentification.otherManagingAuthority,
        'International NGO Consortium',
      );
      expect(facilityIdentification.existingFacilityType, isNull);
    });

    test('should create an instance with "other" existing facility type', () {
      // Arrange & Act
      final facilityIdentification = FacilityIdentificationEntity(
        facilityCode: 'F67890',
        facilityName: 'Specialized Treatment Center',
        managingAuthority: ManagingAuthorityType.university,
        directorName: 'Dr. John Smith',
        directorPhone: '+256712345678',
        directorEmail: 'john.smith@university.edu',
        respondentName: 'Jane Doe',
        respondentPosition: 'Center Manager',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.other,
        otherExistingFacilityType: 'Research and Training Hospital',
      );

      // Assert
      expect(
        facilityIdentification.existingFacilityType,
        ExistingFacilityType.other,
      );
      expect(
        facilityIdentification.otherExistingFacilityType,
        'Research and Training Hospital',
      );
    });

    test('two instances with the same values should be equal', () {
      // Arrange
      final facilityIdentification1 = FacilityIdentificationEntity(
        facilityCode: 'F12345',
        facilityName: 'Bwera Hospital',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dr. Jane Smith',
        directorPhone: '+256789123456',
        directorEmail: 'jane.smith@bwera.org',
        respondentName: 'John Doe',
        respondentPosition: 'IPC Focal Person',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.firstReferralHospital,
      );

      final facilityIdentification2 = FacilityIdentificationEntity(
        facilityCode: 'F12345',
        facilityName: 'Bwera Hospital',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dr. Jane Smith',
        directorPhone: '+256789123456',
        directorEmail: 'jane.smith@bwera.org',
        respondentName: 'John Doe',
        respondentPosition: 'IPC Focal Person',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.firstReferralHospital,
      );

      // Act & Assert
      expect(facilityIdentification1, equals(facilityIdentification2));
    });
  });
}
