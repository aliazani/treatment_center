import 'package:drift/drift.dart';

// coverage:ignore-file
// Main Assessment Form table
@DataClassName('AssessmentFormData')
class AssessmentForms extends Table {
  TextColumn get id => text()();
  TextColumn get assessorInfoId => text().references(AssessorInfos, #id)();
  TextColumn get geoLocationId => text().references(GeoLocations, #id)();
  TextColumn get facilityIdentificationId =>
      text().references(FacilityIdentifications, #id)();
  TextColumn get facilityServicesId =>
      text().references(FacilityServices, #id)();
  TextColumn get notes => text().nullable()();
  BoolColumn get isSubmitted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get submissionDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Assessor Information table
@DataClassName('AssessorInfoData')
class AssessorInfos extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get phoneNumber => text()();
  DateTimeColumn get assessmentDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Geo Location table
@DataClassName('GeoLocationData')
class GeoLocations extends Table {
  TextColumn get id => text()();
  TextColumn get country => text()();
  TextColumn get regionProvince => text()();
  TextColumn get district => text()();
  TextColumn get cityVillage => text()();
  TextColumn get addressOrCoordinates => text()();
  TextColumn get locationType => text()(); // Store enum as string
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();

  @override
  Set<Column> get primaryKey => {id};
}

// Facility Identification table
@DataClassName('FacilityIdentificationData')
class FacilityIdentifications extends Table {
  TextColumn get id => text()();
  TextColumn get facilityCode => text()();
  TextColumn get facilityName => text()();
  TextColumn get managingAuthority => text()(); // Store enum as string
  TextColumn get directorName => text()();
  TextColumn get directorPhone => text()();
  TextColumn get directorEmail => text()();
  TextColumn get respondentName => text()();
  TextColumn get respondentPosition => text()();
  TextColumn get structureType => text()(); // Store enum as string
  TextColumn get facilityType => text()(); // Store enum as string
  TextColumn get existingFacilityType => text()(); // Store enum as string
  TextColumn get otherExistingFacitlityType => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Facility Services table
@DataClassName('FacilityServicesData')
class FacilityServices extends Table {
  TextColumn get id => text()();
  BoolColumn get hasOutpatientServices => boolean()();
  BoolColumn get hasInpatientServices => boolean()();
  IntColumn get totalInpatientBeds => integer()();
  IntColumn get icuBeds => integer()();
  BoolColumn get hasEmergencyUnit => boolean()();
  BoolColumn get hasIcuOrHighDependencyUnit => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

// Assessment Section table
@DataClassName('AssessmentSectionData')
class AssessmentSections extends Table {
  TextColumn get id => text()();
  TextColumn get assessmentFormId =>
      text().references(AssessmentForms, #id, onDelete: KeyAction.cascade)();
  TextColumn get sectionNumber => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();

  @override
  Set<Column> get primaryKey => {id};
  @override
  List<String> get customConstraints => [
    'UNIQUE(assessment_form_id, section_number)'
  ];
}

// Assessment Item table
@DataClassName('AssessmentItemData')
class AssessmentItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemNumber => text()();
  TextColumn get sectionId =>
      text().references(AssessmentSections, #id, onDelete: KeyAction.cascade)();
  TextColumn get sectionNumber => text()();
  TextColumn get area => text()();
  TextColumn get meetsTargetDescription => text()();
  TextColumn get partiallyMeetsDescription => text()();
  TextColumn get doesNotMeetDescription => text()();
  TextColumn get selectedRatingId =>
      text().nullable().references(AssessmentRatings, #id)();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'UNIQUE(section_id, item_number)'
  ];
}

// Assessment Rating table
@DataClassName('AssessmentRatingData')
class AssessmentRatings extends Table {
  TextColumn get id => text()();
  IntColumn get value => integer()();
  TextColumn get label => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get assessmentFormId =>
      text().references(AssessmentForms, #id, onDelete: KeyAction.cascade)();
  TextColumn get fileName => text()();
  TextColumn get filePath => text()();
  TextColumn get source => text()(); // 'camera' or 'gallery'
  IntColumn get fileSizeBytes => integer()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}
