import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_rating_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/validate_section_usecase.dart';

void main() {
  group('ValidationResultEntity.userMessage', () {
    test('valid → empty string', () {
      const r = ValidationResultEntity.valid();
      expect(r.userMessage, '');
    });

    test('invalid with subsection → includes message + Location', () {
      const r = ValidationResultEntity.invalid(
        fieldName: 'X',
        message: 'Please fill X',
        subsection: 'Section 1.1',
      );
      expect(r.userMessage, contains('Please fill X'));
      expect(r.userMessage, contains('Location: Section 1.1'));
    });

    test('invalid without subsection → falls back to message', () {
      const r = ValidationResultEntity.invalid(
        fieldName: 'X',
        message: 'Please fill X',
      );
      expect(r.userMessage, 'Please fill X');
    });
  });

  group('ValidateSectionUsecase', () {
    late ValidateSectionUsecase usecase;

    // ---------- Helpers (no copyWith on inner entities!) ----------
    AssessmentRatingEntity rate(int v) => AssessmentRatingEntity(
      id: '$v',
      value: v,
      label: '$v',
      description: 'Rating $v',
    );

    AssessorInfoEntity assessor({
      String? name,
      String? email,
      String? phone,
      DateTime? date,
    }) => AssessorInfoEntity(
      name: name ?? 'Assessor',
      email: email ?? 'assessor@example.com',
      phoneNumber: phone ?? '123',
      assessmentDate: date ?? DateTime(2025, 1, 1),
    );

    GeoLocationEntity geo({
      String? country,
      String? region,
      String? district,
      String? city,
      String? address,
      FacilityLocationType? type,
    }) => GeoLocationEntity(
      country: country ?? 'Country',
      regionProvince: region ?? 'Region',
      district: district ?? 'District',
      cityVillage: city ?? 'City',
      addressOrCoordinates: address ?? 'Addr',
      latitude: 0,
      longitude: 0,
      locationType: type ?? FacilityLocationType.urban,
    );

    FacilityIdentificationEntity fid({
      String? code,
      String? name,
      ManagingAuthorityType? authority,
      String? directorName,
      String? directorPhone,
      String? directorEmail,
      String? respondentName,
      String? respondentPosition,
      FacilityStructureType? structure,
      FacilityType? type,
      ExistingFacilityType?
      existingType, // domain may use a different enum; adapt if needed
    }) => FacilityIdentificationEntity(
      facilityCode: code ?? 'CODE',
      facilityName: name ?? 'Name',
      managingAuthority: authority ?? ManagingAuthorityType.government,
      directorName: directorName ?? 'Dir',
      directorPhone: directorPhone ?? '555',
      directorEmail: directorEmail ?? 'dir@example.com',
      respondentName: respondentName ?? 'Resp',
      respondentPosition: respondentPosition ?? 'Pos',
      structureType: structure ?? FacilityStructureType.permanent,
      facilityType: type ?? FacilityType.screeningAndTemporaryIsolation,
      existingFacilityType:
          existingType ?? ExistingFacilityType.firstReferralHospital,
    );

    FacilityServicesEntity services({
      bool? out,
      bool? inpt,
      int? totalBeds,
      int? icu,
      bool? emergency,
      bool? icuOrHDU,
    }) => FacilityServicesEntity(
      hasOutpatientServices: out ?? true,
      hasInpatientServices: inpt ?? true,
      totalInpatientBeds: totalBeds ?? 10,
      icuBeds: icu ?? 2,
      hasEmergencyUnit: emergency ?? true,
      hasIcuOrHighDependencyUnit: icuOrHDU ?? true,
    );

    AssessmentItemEntity ratedItem({
      required String section,
      required String number,
      int rating = 1,
    }) => AssessmentItemEntity(
      id: number.hashCode,
      sectionNumber: section,
      itemNumber: number,
      area: 'A',
      meetsTargetDescription: '',
      partiallyMeetsDescription: '',
      doesNotMeetDescription: '',
      selectedRating: rate(rating),
    );

    AssessmentItemEntity unratedItem({
      required String section,
      required String number,
    }) => AssessmentItemEntity(
      id: number.hashCode,
      sectionNumber: section,
      itemNumber: number,
      area: 'A',
      meetsTargetDescription: '',
      partiallyMeetsDescription: '',
      doesNotMeetDescription: '',
      selectedRating: null,
    );

    AssessmentSectionEntity section({
      required String no,
      required String title,
      required List<AssessmentItemEntity> items,
    }) => AssessmentSectionEntity(
      id: 's$no',
      sectionNumber: no,
      title: title,
      description: null,
      items: items,
    );

    AssessmentFormEntity buildForm({
      AssessorInfoEntity? assessorInfo,
      GeoLocationEntity? geoLocation,
      FacilityIdentificationEntity? facilityId,
      FacilityServicesEntity? facilityServices,
      List<AssessmentSectionEntity>? sections,
    }) {
      return AssessmentFormEntity(
        id: 'id',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        isSubmitted: false,
        photos: const [],
        assessorInfo: assessorInfo ?? assessor(),
        geoLocation: geoLocation ?? geo(),
        facilityIdentification: facilityId ?? fid(),
        facilityServices: facilityServices ?? services(),
        sections:
            sections ??
            <AssessmentSectionEntity>[
              // Section 2 fully rated
              section(
                no: '2',
                title: 'S2',
                items: [
                  ratedItem(section: '2', number: '2.1', rating: 1),
                  ratedItem(section: '2', number: '2.2', rating: 2),
                ],
              ),
              // Section 3 fully rated
              section(
                no: '3',
                title: 'S3',
                items: [ratedItem(section: '3', number: '3.1', rating: 3)],
              ),
              // Section 4 fully rated
              section(
                no: '4',
                title: 'S4',
                items: [ratedItem(section: '4', number: '4.1', rating: 1)],
              ),
            ],
      );
    }

    late AssessmentFormEntity base;

    setUp(() {
      usecase = ValidateSectionUsecase();
      base = buildForm();
    });

    // ─────────────────────────────── Routing ────────────────────────────────
    test('sections 5 & 6 → always valid', () async {
      final s5 = await usecase(
        ValidateSectionParams(assessmentForm: base, sectionNumber: 5),
      );
      final s6 = await usecase(
        ValidateSectionParams(assessmentForm: base, sectionNumber: 6),
      );
      expect(s5.isRight(), true);
      expect(s6.isRight(), true);
      expect(
        s5.getRight().getOrElse(() => throw ''),
        const ValidationResultEntity.valid(),
      );
      expect(
        s6.getRight().getOrElse(() => throw ''),
        const ValidationResultEntity.valid(),
      );
    });

    test('invalid section number', () async {
      final res = await usecase(
        ValidateSectionParams(assessmentForm: base, sectionNumber: 99),
      );
      final r = res.getRight().getOrElse(() => throw '');
      expect(r.isValid, false);
      expect(r.incompleteFieldName, 'Section Number');
    });

    // ───────────────────────────── Section 1 valid ───────────────────────────
    test('section 1 valid with complete data', () async {
      final form = buildForm(); // all defaults valid
      final res = await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      );
      expect(
        res.getRight().getOrElse(() => throw ''),
        const ValidationResultEntity.valid(),
      );
    });

    // ─────────────────────── Assessor validation ─────────────────────────────
    test('assessor: missing date', () async {
      final form = buildForm(
        assessorInfo: AssessorInfoEntity(
          name: 'Assessor',
          email: 'assessor@example.com',
          phoneNumber: '123',
          assessmentDate: null,
        ),
      );

      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');

      expect(r.incompleteFieldName, 'Assessment Date');
    });

    test('assessor: empty name', () async {
      final form = buildForm(assessorInfo: assessor(name: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Assessor Name');
    });

    test('assessor: empty email', () async {
      final form = buildForm(assessorInfo: assessor(email: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Assessor Email');
      expect(r.incompleteFieldMessage, 'Assessor email address is required');
    });

    test('assessor: invalid email format', () async {
      final form = buildForm(assessorInfo: assessor(email: 'bad@'));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Assessor Email');
      expect(r.incompleteFieldMessage, 'Assessor email format is invalid');
    });

    test('assessor: empty phone', () async {
      final form = buildForm(assessorInfo: assessor(phone: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Assessor Phone Number');
    });

    // ─────────────────────── Geolocation validation ──────────────────────────
    test('geo: empty country', () async {
      final form = buildForm(geoLocation: geo(country: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Country');
    });

    test('geo: empty region', () async {
      final form = buildForm(geoLocation: geo(region: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Region/Province');
    });

    test('geo: empty district', () async {
      final form = buildForm(geoLocation: geo(district: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'District');
    });

    test('geo: empty city', () async {
      final form = buildForm(geoLocation: geo(city: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'City/Village');
    });

    test('geo: empty address', () async {
      final form = buildForm(geoLocation: geo(address: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Address/Coordinates');
    });

    test('geo: null location type', () async {
      // assessor must be valid so we actually reach the geolocation checks
      final assessor = AssessorInfoEntity(
        name: 'Assessor',
        email: 'assessor@example.com',
        phoneNumber: '123',
        assessmentDate: DateTime(2025, 1, 1),
      );

      // all geo fields valid EXCEPT locationType which we explicitly set to null
      final geo = GeoLocationEntity(
        country: 'X',
        regionProvince: 'Y',
        district: 'Z',
        cityVillage: 'City',
        addressOrCoordinates: 'Addr',
        latitude: 0.0,
        longitude: 0.0,
        locationType: null,
      );

      final form = buildForm(
        assessorInfo: assessor,
        geoLocation: geo,
        // other sections can be whatever your buildForm defaults to;
        // they won't be validated if geo fails.
      );

      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');

      expect(r.isValid, isFalse);
      expect(r.incompleteFieldName, 'Location Type');
      expect(r.subsectionName, 'Section 1.2 - Geographic Location');
    });

    // ─────────────── Facility Identification validation ──────────────────────
    test('facilityId: missing code', () async {
      final form = buildForm(facilityId: fid(code: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Facility Code');
    });

    test('facilityId: missing name', () async {
      final form = buildForm(facilityId: fid(name: ''));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'Facility Name');
    });

    test('facilityId: missing managing authority', () async {
      final form = buildForm(
        facilityId: FacilityIdentificationEntity(
          facilityCode: 'FC',
          facilityName: 'Name',
          managingAuthority: null, // <-- stays null
          directorName: 'Dir',
          directorPhone: '111',
          directorEmail: 'dir@example.com',
          respondentName: 'Resp',
          respondentPosition: 'Pos',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
          existingFacilityType:
              ExistingFacilityType.other, // to bypass screening rule
          otherExistingFacilityType: 'Clinic',
        ),
      );

      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');

      expect(r.isValid, isFalse, reason: r.userMessage);
      expect(r.incompleteFieldName, 'Managing Authority');
      expect(r.subsectionName, 'Section 1.3 - Facility Identification');
    });

    test(
      'facilityId: director/respondent/structure/type/email validations',
      () async {
        // 1) Director name empty
        var form = buildForm(facilityId: fid(directorName: ''));
        var r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(r.incompleteFieldName, 'Director Name', reason: r.userMessage);

        // 2) Director phone empty
        form = buildForm(facilityId: fid(directorPhone: ''));
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(r.incompleteFieldName, 'Director Phone', reason: r.userMessage);

        // 3) Director email empty
        form = buildForm(facilityId: fid(directorEmail: ''));
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(r.incompleteFieldName, 'Director Email', reason: r.userMessage);
        expect(r.incompleteFieldMessage, 'Director email address is required');

        // 4) Director email invalid
        form = buildForm(facilityId: fid(directorEmail: 'x@'));
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(r.incompleteFieldName, 'Director Email', reason: r.userMessage);
        expect(r.incompleteFieldMessage, 'Director email format is invalid');

        // 5) Respondent name empty
        form = buildForm(facilityId: fid(respondentName: ''));
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(r.incompleteFieldName, 'Respondent Name', reason: r.userMessage);

        // 6) Respondent position empty
        form = buildForm(facilityId: fid(respondentPosition: ''));
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(
          r.incompleteFieldName,
          'Respondent Position',
          reason: r.userMessage,
        );

        // 7) structureType null — build inline so fid() doesn't overwrite null
        form = buildForm(
          facilityId: FacilityIdentificationEntity(
            facilityCode: 'CODE',
            facilityName: 'Name',
            managingAuthority: ManagingAuthorityType.government,
            directorName: 'Dir',
            directorPhone: '555',
            directorEmail: 'dir@example.com',
            respondentName: 'Resp',
            respondentPosition: 'Pos',
            structureType: null,
            facilityType: FacilityType.screeningAndTemporaryIsolation,
            existingFacilityType:
                ExistingFacilityType.other, // bypass screening rule
            otherExistingFacilityType: 'Clinic',
          ),
        );
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(r.incompleteFieldName, 'Structure Type', reason: r.userMessage);

        // 8) facilityType null — build inline so fid() doesn't overwrite null
        form = buildForm(
          facilityId: FacilityIdentificationEntity(
            facilityCode: 'CODE',
            facilityName: 'Name',
            managingAuthority: ManagingAuthorityType.government,
            directorName: 'Dir',
            directorPhone: '555',
            directorEmail: 'dir@example.com',
            respondentName: 'Resp',
            respondentPosition: 'Pos',
            structureType: FacilityStructureType.permanent,
            facilityType: null,
            existingFacilityType: null,
            otherExistingFacilityType: null,
          ),
        );
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(r.incompleteFieldName, 'Facility Type', reason: r.userMessage);
      },
    );

    test(
      'facilityId: screening center requires existingFacilityType',
      () async {
        final usecase = ValidateSectionUsecase();

        // Valid assessor (Section 1.1)
        final assessor = AssessorInfoEntity(
          name: 'Assessor',
          email: 'assessor@example.com',
          phoneNumber: '123',
          assessmentDate: DateTime(2025, 1, 1),
        );

        // Valid geo (Section 1.2)
        final geo = GeoLocationEntity(
          country: 'X',
          regionProvince: 'Y',
          district: 'Z',
          cityVillage: 'City',
          addressOrCoordinates: 'Addr',
          latitude: 0.0,
          longitude: 0.0,
          locationType: FacilityLocationType.urban,
        );

        // Facility ID: screening + missing existingFacilityType (Section 1.3)
        final fid = FacilityIdentificationEntity(
          facilityCode: 'FC',
          facilityName: 'Name',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Dir',
          directorPhone: '111',
          directorEmail: 'dir@example.com',
          respondentName: 'Resp',
          respondentPosition: 'Pos',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
          existingFacilityType: null,
          otherExistingFacilityType: null,
        );

        // Section 1.4 – make it valid so we don't fail there first
        final services = FacilityServicesEntity(
          hasOutpatientServices: false,
          hasInpatientServices: false,
          totalInpatientBeds: 0,
          icuBeds: 0,
          hasEmergencyUnit: false,
          hasIcuOrHighDependencyUnit: false,
        );

        // Build a minimal AssessmentFormEntity that passes S1.1 & S1.2,
        // then fails at S1.3 on existingFacilityType
        final form = AssessmentFormEntity(
          id: 't1',
          assessorInfo: assessor,
          geoLocation: geo,
          facilityIdentification: fid,
          facilityServices: services,
          sections: const [],
          photos: const [],
          isSubmitted: false,
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 1),
        );

        final result = await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        );

        final r = result.getRight().getOrElse(() => throw 'no result');
        expect(r.isValid, isFalse, reason: r.userMessage);
        expect(
          r.incompleteFieldName,
          'Existing Facility Type',
          reason: r.userMessage,
        );
        expect(
          r.incompleteFieldMessage,
          'Existing facility type is required for screening centers',
          reason: r.userMessage,
        );
        expect(r.subsectionName, 'Section 1.3 - Facility Identification');
      },
    );

    // ─────────────────────── Facility Services validation ─────────────────────
    test('services: missing outpatient', () async {
      // Valid assessor (Section 1.1)
      final assessor = AssessorInfoEntity(
        name: 'Assessor',
        email: 'assessor@example.com',
        phoneNumber: '123',
        assessmentDate: DateTime(2025, 1, 1),
      );

      // Valid geo (Section 1.2)
      final geo = GeoLocationEntity(
        country: 'X',
        regionProvince: 'Y',
        district: 'Z',
        cityVillage: 'City',
        addressOrCoordinates: 'Addr',
        latitude: 0.0,
        longitude: 0.0,
        locationType: FacilityLocationType.urban,
      );

      // Valid facility id (Section 1.3)
      // NOTE: since facilityType is screeningAndTemporaryIsolation, you must provide existingFacilityType
      final fid = FacilityIdentificationEntity(
        facilityCode: 'FC',
        facilityName: 'Name',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dir',
        directorPhone: '111',
        directorEmail: 'dir@example.com',
        respondentName: 'Resp',
        respondentPosition: 'Pos',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType:
            ExistingFacilityType.other, // <-- required for screening type
        otherExistingFacilityType: 'Clinic',
      );

      // Section 1.4: Outpatient is null (this is what we test)
      // Make inpatient non-null so we don't fail there first.
      final services = FacilityServicesEntity(
        hasOutpatientServices: null,
        hasInpatientServices: false,
        totalInpatientBeds: 0,
        icuBeds: 0,
        hasEmergencyUnit: false,
        hasIcuOrHighDependencyUnit: false,
      );

      final form = buildForm(
        assessorInfo: assessor,
        geoLocation: geo,
        facilityId: fid,
        facilityServices: services,
      );

      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw 'no result');

      expect(r.isValid, isFalse, reason: r.userMessage);
      expect(
        r.incompleteFieldName,
        'Outpatient Services',
        reason: r.userMessage,
      );
      expect(r.subsectionName, 'Section 1.4 - Facility Services');
    });

    test('services: missing inpatient', () async {
      // Valid assessor
      final assessor = AssessorInfoEntity(
        name: 'Assessor',
        email: 'assessor@example.com',
        phoneNumber: '123',
        assessmentDate: DateTime(2025, 1, 1),
      );

      // Valid geo
      final geo = GeoLocationEntity(
        country: 'X',
        regionProvince: 'Y',
        district: 'Z',
        cityVillage: 'City',
        addressOrCoordinates: 'Addr',
        latitude: 0.0,
        longitude: 0.0,
        locationType: FacilityLocationType.urban,
      );

      // Valid facility id — NOTE: provide existingFacilityType to get past 1.3
      final fid = FacilityIdentificationEntity(
        facilityCode: 'FC',
        facilityName: 'Name',
        managingAuthority: ManagingAuthorityType.government,
        directorName: 'Dir',
        directorPhone: '111',
        directorEmail: 'dir@example.com',
        respondentName: 'Resp',
        respondentPosition: 'Pos',
        structureType: FacilityStructureType.permanent,
        facilityType: FacilityType.screeningAndTemporaryIsolation,
        existingFacilityType: ExistingFacilityType.other,
        otherExistingFacilityType: 'Clinic', // if your model supports it
      );

      // Services with inpatient = null (this is what we want to test)
      final services = FacilityServicesEntity(
        hasOutpatientServices: true, // set so Outpatient check passes
        hasInpatientServices: null,
        totalInpatientBeds: 0,
        icuBeds: 0,
        hasEmergencyUnit: false,
        hasIcuOrHighDependencyUnit: false,
      );

      final form = buildForm(
        assessorInfo: assessor,
        geoLocation: geo,
        facilityId: fid,
        facilityServices: services,
      );

      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw 'no result');

      expect(r.isValid, isFalse, reason: r.userMessage);
      expect(
        r.incompleteFieldName,
        'Inpatient Services',
        reason: r.userMessage,
      );
      expect(r.subsectionName, 'Section 1.4 - Facility Services');
    });

    test(
      'services: inpatient true → requires beds, ICU, emergency, ICU/HDU',
      () async {
        // Valid assessor (so we reach services)
        final assessor = AssessorInfoEntity(
          name: 'Assessor',
          email: 'assessor@example.com',
          phoneNumber: '123',
          assessmentDate: DateTime(2025, 1, 1),
        );
        // Valid geo
        final geo = GeoLocationEntity(
          country: 'X',
          regionProvince: 'Y',
          district: 'Z',
          cityVillage: 'City',
          addressOrCoordinates: 'Addr',
          latitude: 0.0,
          longitude: 0.0,
          locationType: FacilityLocationType.urban,
        );
        // Valid facility id
        final fid = FacilityIdentificationEntity(
          facilityCode: 'FC',
          facilityName: 'Name',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Dir',
          directorPhone: '111',
          directorEmail: 'dir@example.com',
          respondentName: 'Resp',
          respondentPosition: 'Pos',
          structureType: FacilityStructureType.permanent,
          existingFacilityType: ExistingFacilityType.other,
          otherExistingFacilityType: 'Clinic',
          facilityType: FacilityType.screeningAndTemporaryIsolation,
        );

        // 1) total beds missing
        var services = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: null,
          icuBeds: 0,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );
        var form = buildForm(
          assessorInfo: assessor,
          geoLocation: geo,
          facilityId: fid,
          facilityServices: services,
        );
        var r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse);
        expect(r.incompleteFieldName, 'Total Inpatient Beds');
        expect(r.subsectionName, 'Section 1.4 - Facility Services');

        // 2) ICU beds missing
        services = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 10,
          icuBeds: null,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: true,
        );
        form = buildForm(
          assessorInfo: assessor,
          geoLocation: geo,
          facilityId: fid,
          facilityServices: services,
        );
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.incompleteFieldName, 'ICU Beds');

        // 3) Emergency unit missing
        services = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 10,
          icuBeds: 2,
          hasEmergencyUnit: null,
          hasIcuOrHighDependencyUnit: true,
        );
        form = buildForm(
          assessorInfo: assessor,
          geoLocation: geo,
          facilityId: fid,
          facilityServices: services,
        );
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.incompleteFieldName, 'Emergency Unit');

        // 4) ICU/HDU missing
        services = FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 10,
          icuBeds: 2,
          hasEmergencyUnit: true,
          hasIcuOrHighDependencyUnit: null,
        );
        form = buildForm(
          assessorInfo: assessor,
          geoLocation: geo,
          facilityId: fid,
          facilityServices: services,
        );
        r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        )).getRight().getOrElse(() => throw '');
        expect(r.incompleteFieldName, 'ICU/High Dependency Unit');
      },
    );

    test('services: ICU beds cannot exceed total beds', () async {
      final form = buildForm(facilityServices: services(totalBeds: 5, icu: 6));
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
      )).getRight().getOrElse(() => throw '');
      expect(r.incompleteFieldName, 'ICU Beds');
      expect(
        r.incompleteFieldMessage,
        contains('ICU beds (6) cannot exceed total beds (5)'),
      );
    });

    // ───────────────────────── Sections 2–4 logic ────────────────────────────
    test('section 2: empty items → invalid', () async {
      final emptyS2 = section(no: '2', title: 'S2-Empty', items: const []);
      final form = buildForm(
        sections: [
          emptyS2,
          section(
            no: '3',
            title: 'S3',
            items: [ratedItem(section: '3', number: '3.1')],
          ),
          section(
            no: '4',
            title: 'S4',
            items: [ratedItem(section: '4', number: '4.1')],
          ),
        ],
      );
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 2),
      )).getRight().getOrElse(() => throw '');
      expect(r.isValid, false);
      expect(r.incompleteFieldName, 'Section 2');
      expect(
        r.incompleteFieldMessage,
        'This section must have assessment items',
      );
    });

    test(
      'section 3: some rated but not all → first unrated requested',
      () async {
        final s3 = section(
          no: '3',
          title: 'S3',
          items: [
            ratedItem(section: '3', number: '3.1'),
            unratedItem(section: '3', number: '3.2'),
            ratedItem(section: '3', number: '3.3', rating: 2),
          ],
        );
        final form = buildForm(
          sections: [
            section(
              no: '2',
              title: 'S2',
              items: [ratedItem(section: '2', number: '2.1')],
            ),
            s3,
            section(
              no: '4',
              title: 'S4',
              items: [ratedItem(section: '4', number: '4.1')],
            ),
          ],
        );
        final r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 3),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, false);
        expect(r.incompleteFieldName, '3.2');
        expect(r.incompleteFieldMessage, 'Please rate this item');
        expect(r.subsectionName, contains('Section 3 - S3 - 3.2'));
      },
    );

    test('section 4: none rated → require all ratings', () async {
      final s4 = section(
        no: '4',
        title: 'S4',
        items: [
          unratedItem(section: '4', number: '4.1'),
          unratedItem(section: '4', number: '4.2'),
        ],
      );
      final form = buildForm(
        sections: [
          section(
            no: '2',
            title: 'S2',
            items: [ratedItem(section: '2', number: '2.1')],
          ),
          section(
            no: '3',
            title: 'S3',
            items: [ratedItem(section: '3', number: '3.1')],
          ),
          s4,
        ],
      );
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: form, sectionNumber: 4),
      )).getRight().getOrElse(() => throw '');
      expect(r.isValid, false);
      expect(r.incompleteFieldName, 'Section 4');
      expect(
        r.incompleteFieldMessage,
        'Please complete all ratings in this section',
      );
    });

    test('section 2: all rated → valid', () async {
      final r = (await usecase(
        ValidateSectionParams(assessmentForm: base, sectionNumber: 2),
      )).getRight().getOrElse(() => throw '');
      expect(r, const ValidationResultEntity.valid());
    });

    test(
      'section missing → returns invalid via catch in _validateAssessmentSection',
      () async {
        final form = buildForm(
          sections: [
            // remove section '2' entirely
            section(
              no: '3',
              title: 'S3',
              items: [ratedItem(section: '3', number: '3.1')],
            ),
            section(
              no: '4',
              title: 'S4',
              items: [ratedItem(section: '4', number: '4.1')],
            ),
          ],
        );
        final r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 2),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, false);
        expect(r.incompleteFieldName, 'Section 2');
        expect(
          r.incompleteFieldMessage,
          'Section not found or improperly configured',
        );
      },
    );

    test(
      'userMessage falls back to "Please complete the required field: ..." when message and subsection are null',
      () {
        const r = ValidationResultEntity(
          isValid: false,
          incompleteFieldName: 'Some Field',
          incompleteFieldMessage: null, // force fallback path
          subsectionName: null,
        );
        expect(r.userMessage, 'Please complete the required field: Some Field');
      },
    );

    test('ValidationResultEntity Equatable props: equality on all fields', () {
      const a = ValidationResultEntity(
        isValid: false,
        incompleteFieldName: 'X',
        incompleteFieldMessage: 'Y',
        subsectionName: 'Z',
      );
      const b = ValidationResultEntity(
        isValid: false,
        incompleteFieldName: 'X',
        incompleteFieldMessage: 'Y',
        subsectionName: 'Z',
      );
      const c = ValidationResultEntity(
        isValid: false,
        incompleteFieldName: 'X',
        incompleteFieldMessage: 'Different',
        subsectionName: 'Z',
      );

      expect(a, equals(b)); // props equal
      expect(a, isNot(equals(c))); // message differs
    });

    test(
      'returns invalid at first unrated item (loop early return path)',
      () async {
        final usecase = ValidateSectionUsecase();
        // Build section 3 with second item unrated to force the early return body
        final s3 = AssessmentSectionEntity(
          id: 's3',
          sectionNumber: '3',
          title: 'S3',
          description: null,
          items: [
            AssessmentItemEntity(
              id: 1,
              sectionNumber: '3',
              itemNumber: '3.1',
              area: 'A',
              meetsTargetDescription: '',
              partiallyMeetsDescription: '',
              doesNotMeetDescription: '',
              selectedRating: AssessmentRatingEntity(
                id: '1',
                value: 1,
                label: '1',
                description: '1',
              ),
            ),
            AssessmentItemEntity(
              id: 2,
              sectionNumber: '3',
              itemNumber: '3.2',
              area: 'A',
              meetsTargetDescription: '',
              partiallyMeetsDescription: '',
              doesNotMeetDescription: '',
              selectedRating: null, // <- trigger
            ),
            AssessmentItemEntity(
              id: 3,
              sectionNumber: '3',
              itemNumber: '3.3',
              area: 'A',
              meetsTargetDescription: '',
              partiallyMeetsDescription: '',
              doesNotMeetDescription: '',
              selectedRating: AssessmentRatingEntity(
                id: '2',
                value: 2,
                label: '2',
                description: '2',
              ),
            ),
          ],
        );

        final form = AssessmentFormEntity(
          id: 'id',
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
          isSubmitted: false,
          photos: const [],
          assessorInfo: AssessorInfoEntity(
            name: 'Assessor',
            email: 'assessor@example.com',
            phoneNumber: '123',
            assessmentDate: DateTime(2025, 1, 1),
          ),
          geoLocation: GeoLocationEntity(
            country: 'C',
            regionProvince: 'R',
            district: 'D',
            cityVillage: 'V',
            addressOrCoordinates: 'A',
            latitude: 0,
            longitude: 0,
            locationType: FacilityLocationType.urban,
          ),
          facilityIdentification: FacilityIdentificationEntity(
            facilityCode: 'FC',
            facilityName: 'FN',
            managingAuthority: ManagingAuthorityType.government,
            directorName: 'Dir',
            directorPhone: '111',
            directorEmail: 'dir@example.com',
            respondentName: 'Resp',
            respondentPosition: 'Pos',
            structureType: FacilityStructureType.permanent,
            facilityType: FacilityType.screeningAndTemporaryIsolation,
            existingFacilityType: ExistingFacilityType.other,
            otherExistingFacilityType: 'Clinic',
          ),
          facilityServices: const FacilityServicesEntity(
            hasOutpatientServices: true,
            hasInpatientServices: true,
            totalInpatientBeds: 10,
            icuBeds: 2,
            hasEmergencyUnit: true,
            hasIcuOrHighDependencyUnit: true,
          ),
          sections: [
            AssessmentSectionEntity(
              id: 's2',
              sectionNumber: '2',
              title: 'S2',
              description: null,
              items: [
                AssessmentItemEntity(
                  id: 11,
                  sectionNumber: '2',
                  itemNumber: '2.1',
                  area: 'A',
                  meetsTargetDescription: '',
                  partiallyMeetsDescription: '',
                  doesNotMeetDescription: '',
                  selectedRating: AssessmentRatingEntity(
                    id: '1',
                    value: 1,
                    label: '1',
                    description: '1',
                  ),
                ),
              ],
            ),
            s3,
          ],
        );

        final r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 3),
        )).getRight().getOrElse(() => throw '');
        expect(r.isValid, isFalse);
        expect(r.incompleteFieldName, '3.2');
        expect(r.incompleteFieldMessage, 'Please rate this item');
        expect(r.subsectionName, contains('Section 3 - S3 - 3.2'));
      },
    );

    test('ValidateSectionParams Equatable props', () {
      final form = AssessmentFormEntity(
        id: 'id',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
        isSubmitted: false,
        photos: const [],
        assessorInfo: AssessorInfoEntity(
          name: 'Assessor',
          email: 'assessor@example.com',
          phoneNumber: '123',
          assessmentDate: DateTime(2025, 1, 1),
        ),
        geoLocation: GeoLocationEntity(
          country: 'C',
          regionProvince: 'R',
          district: 'D',
          cityVillage: 'V',
          addressOrCoordinates: 'A',
          latitude: 0,
          longitude: 0,
          locationType: FacilityLocationType.urban,
        ),
        facilityIdentification: FacilityIdentificationEntity(
          facilityCode: 'FC',
          facilityName: 'FN',
          managingAuthority: ManagingAuthorityType.government,
          directorName: 'Dir',
          directorPhone: '111',
          directorEmail: 'dir@example.com',
          respondentName: 'Resp',
          respondentPosition: 'Pos',
          structureType: FacilityStructureType.permanent,
          facilityType: FacilityType.screeningAndTemporaryIsolation,
          existingFacilityType: ExistingFacilityType.other,
          otherExistingFacilityType: 'Clinic',
        ),
        facilityServices: const FacilityServicesEntity(
          hasOutpatientServices: true,
          hasInpatientServices: false,
          totalInpatientBeds: 0,
          icuBeds: 0,
          hasEmergencyUnit: false,
          hasIcuOrHighDependencyUnit: false,
        ),
        sections: const [],
      );

      final a = ValidateSectionParams(assessmentForm: form, sectionNumber: 1);
      final b = ValidateSectionParams(assessmentForm: form, sectionNumber: 1);
      final c = ValidateSectionParams(assessmentForm: form, sectionNumber: 2);

      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test(
      'section 3: last item unrated → returns invalid with item number and subsection',
      () async {
        final s3 = section(
          no: '3',
          title: 'S3',
          items: [
            ratedItem(section: '3', number: '3.1', rating: 1),
            ratedItem(section: '3', number: '3.2', rating: 2),
            unratedItem(section: '3', number: '3.3'),
          ],
        );

        final form = buildForm(
          sections: [
            section(
              no: '2',
              title: 'S2',
              items: [ratedItem(section: '2', number: '2.1')],
            ),
            s3,
            section(
              no: '4',
              title: 'S4',
              items: [ratedItem(section: '4', number: '4.1')],
            ),
          ],
        );

        final r = (await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 3),
        )).getRight().getOrElse(() => throw 'no result');

        expect(r.isValid, isFalse);
        expect(r.incompleteFieldName, '3.3');
        expect(r.incompleteFieldMessage, 'Please rate this item');
        expect(r.subsectionName, contains('Section 3 - S3 - 3.3'));
      },
    );

    test(
      'call() catches exceptions and returns Left(ValidationFailure)',
      () async {
        final form = buildForm(assessorInfo: ThrowingAssessor());

        final res = await usecase(
          ValidateSectionParams(assessmentForm: form, sectionNumber: 1),
        );

        expect(res.isLeft(), isTrue);
        final failure = res.getLeft().getOrElse(() => throw 'no failure');
        expect(failure, isA<ValidationFailure>());
        expect(
          (failure as ValidationFailure).message,
          contains('Failed to validate section'),
        );
        expect(failure.message, contains('boom'));
      },
    );
  });
}

// Put this ABOVE `main()` or at the top of your test file
class ThrowingAssessor extends AssessorInfoEntity {
  ThrowingAssessor()
    : super(
        name: 'A',
        email: 'a@a.com',
        phoneNumber: '1',
        assessmentDate: DateTime(2025, 1, 1),
      );

  @override
  DateTime? get assessmentDate => throw Exception('boom');
}
