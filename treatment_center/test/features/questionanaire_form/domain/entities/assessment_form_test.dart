import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services.dart';

void main() {
  // Sample data for testing
  final testDate = DateTime(2023, 5, 15);
  
  // Sample assessment items and sections
  final item1 = AssessmentItem(
    id: 'item1',
    sectionNumber: '2.1.1',
    area: 'Health care facility entrances',
    meetsTargetDescription: 'Description 1',
    partiallyMeetsDescription: 'Description 2',
    doesNotMeetDescription: 'Description 3',
  );
  
  final item2 = AssessmentItem(
    id: 'item2',
    sectionNumber: '2.1.2',
    area: 'Area distribution',
    meetsTargetDescription: 'Description 1',
    partiallyMeetsDescription: 'Description 2',
    doesNotMeetDescription: 'Description 3',
    selectedRating: AssessmentRating.meetsTarget(),
  );
  
  final section1 = AssessmentSection(
    id: 'section1',
    sectionNumber: '2.1',
    title: 'Facility accesses and flows',
    items: [item1, item2],
  );
  
  // Sample form data
  final testAssessorInfo = AssessorInfo(
    name: 'John Doe',
    email: 'john.doe@example.com',
    phoneNumber: '+1234567890',
    assessmentDate: testDate,
  );
  
  final testGeoLocation = GeoLocation(
    country: 'Uganda',
    regionProvince: 'Western Region',
    district: 'Kasese',
    cityVillage: 'Bwera',
    addressOrCoordinates: '0.14825, 29.71769',
    locationType: FacilityLocationType.rural,
  );
  
  final testFacilityId = FacilityIdentification(
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
  
  final testFacilityServices = FacilityServices(
    hasOutpatientServices: true,
    hasInpatientServices: true,
    totalInpatientBeds: 100,
    icuBeds: 10,
    hasEmergencyUnit: true,
    hasIcuOrHighDependencyUnit: true,
  );
  
  group('AssessmentForm', () {
    test('should create a valid AssessmentForm', () {
      // Arrange & Act
      final form = AssessmentForm(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
      );
      
      // Assert
      expect(form.id, 'form1');
      expect(form.assessorInfo, testAssessorInfo);
      expect(form.geoLocation, testGeoLocation);
      expect(form.facilityIdentification, testFacilityId);
      expect(form.facilityServices, testFacilityServices);
      expect(form.sections, [section1]);
      expect(form.isSubmitted, false);
      expect(form.submissionDate, isNull);
    });
    
    test('should correctly calculate completion statistics', () {
      // Arrange
      final form = AssessmentForm(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
      );
      
      // Act & Assert
      // Section has 2 items, but only 1 is rated
      expect(form.completionPercentage, 50.0);
      expect(form.isComplete, false);
      
      // Complete all items and check again
      final completedItem1 = item1.copyWith(
        selectedRating: AssessmentRating.doesNotMeetTarget(),
      );
      
      final completedSection1 = section1.copyWith(
        items: [completedItem1, item2],
      );
      
      final completedForm = form.copyWith(
        sections: [completedSection1],
      );
      
      // Assert after completing all items
      expect(completedForm.completionPercentage, 100.0);
      expect(completedForm.isComplete, true);
    });
    
    test('should mark form as submitted', () {
      // Arrange
      final form = AssessmentForm(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
      );
      
      // Act
      final submittedForm = form.markAsSubmitted();
      
      // Assert
      expect(submittedForm.isSubmitted, true);
      expect(submittedForm.submissionDate, isNotNull);
    });
    
    test('copyWith should create a new instance with updated fields', () {
      // Arrange
      final form = AssessmentForm(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [section1],
      );
      
      final newAssessorInfo = AssessorInfo(
        name: 'Jane Smith',
        email: 'jane.smith@example.com',
        phoneNumber: '+0987654321',
        assessmentDate: DateTime(2023, 5, 20),
      );
      
      // Act
      final updatedForm = form.copyWith(
        assessorInfo: newAssessorInfo,
        notes: 'Important observations',
      );
      
      // Assert
      expect(updatedForm.id, form.id);
      expect(updatedForm.assessorInfo, newAssessorInfo);
      expect(updatedForm.geoLocation, form.geoLocation);
      expect(updatedForm.facilityIdentification, form.facilityIdentification);
      expect(updatedForm.facilityServices, form.facilityServices);
      expect(updatedForm.sections, form.sections);
      expect(updatedForm.notes, 'Important observations');
    });
    
    test('should handle forms with no sections', () {
      // Arrange & Act
      final form = AssessmentForm(
        id: 'form1',
        assessorInfo: testAssessorInfo,
        geoLocation: testGeoLocation,
        facilityIdentification: testFacilityId,
        facilityServices: testFacilityServices,
        sections: [],
      );
      
      // Assert
      expect(form.completionPercentage, 0.0);
      expect(form.isComplete, true); // Empty list means no items to complete
    });
  });
}