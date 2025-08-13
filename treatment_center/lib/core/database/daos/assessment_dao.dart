import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessor_info_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_identification_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/facility_services_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_section_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_item_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_rating_model.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/photo_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
import 'package:treatment_center/core/database/tables/assessment_tables.dart';
import 'package:treatment_center/core/database/app_database.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart'
    as domain;
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart'
    as domain_facility;
import 'package:flutter/foundation.dart';

part 'assessment_dao.g.dart';

@DriftAccessor(
  tables: [
    AssessmentForms,
    AssessorInfos,
    GeoLocations,
    FacilityIdentifications,
    FacilityServices,
    AssessmentSections,
    AssessmentItems,
    AssessmentRatings,
    Photos,
  ],
)
class AssessmentDao extends DatabaseAccessor<AppDatabase>
    with _$AssessmentDaoMixin {
  AssessmentDao(super.db);

  static const _uuid = Uuid();

  // =================== MAIN CRUD OPERATIONS ===================

  /// Get a single assessment by ID
  Future<AssessmentFormModel?> getAssessment(String id) async {
    try {
      final form =
          await (select(assessmentForms)
            ..where((form) => form.id.equals(id))).getSingleOrNull();

      return form != null ? await _buildAssessmentFormModel(form) : null;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all assessments
  Future<List<AssessmentFormModel>> getAllAssessments() async {
    try {
      final forms =
          await (select(assessmentForms)
            ..orderBy([(form) => OrderingTerm.desc(form.updatedAt)])).get();

      return _buildAssessmentModels(forms);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all unsubmitted assessments
  Future<List<AssessmentFormModel>> getUnsubmittedAssessments() async {
    try {
      final forms =
          await (select(assessmentForms)
                ..where((form) => form.isSubmitted.equals(false))
                ..orderBy([(form) => OrderingTerm.desc(form.updatedAt)]))
              .get();

      return _buildAssessmentModels(forms);
    } catch (e) {
      rethrow;
    }
  }

  /// Get all submitted assessments
  Future<List<AssessmentFormModel>> getSubmittedAssessments() async {
    try {
      final forms =
          await (select(assessmentForms)
                ..where((form) => form.isSubmitted.equals(true))
                ..orderBy([(form) => OrderingTerm.desc(form.submissionDate)]))
              .get();

      return _buildAssessmentModels(forms);
    } catch (e) {
      rethrow;
    }
  }

  /// Save a new assessment
  Future<bool> saveAssessment(AssessmentFormModel assessment) async {
    try {
      return await transaction(() async {
        await _saveAssessmentInternal(assessment);
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  /// Update an existing assessment
  Future<bool> updateAssessment(AssessmentFormModel assessment) async {
    try {
      return await transaction(() async {
        final existing =
            await (select(assessmentForms)..where(
              (form) => form.id.equals(assessment.id),
            )).getSingleOrNull();

        if (existing == null) return false;

        // Check if this is just a simple update (notes, submission status, etc.)
        // without changing complex nested structures
        final isSimpleUpdate = await _isSimpleUpdate(existing, assessment);

        if (isSimpleUpdate) {
          // Just update the main assessment form record
          await (update(assessmentForms)
            ..where((form) => form.id.equals(assessment.id))).write(
            AssessmentFormsCompanion(
              notes: Value(assessment.notes),
              isSubmitted: Value(assessment.isSubmitted),
              submissionDate: Value(assessment.submissionDate),
              updatedAt: Value(assessment.updatedAt),
            ),
          );

          // Update photos even in simple updates
          await _savePhotos(assessment.id, assessment.photoModels);

          return true;
        } else {
          // Complex update - need to delete and recreate
          await _deleteAssessmentRelatedData(assessment.id);
          await _saveAssessmentInternal(assessment);

          return true;
        }
      });
    } catch (e) {
      return false;
    }
  }

  /// Check if this is a simple update that doesn't require deleting/recreating nested data
  Future<bool> _isSimpleUpdate(
    AssessmentFormData existing,
    AssessmentFormModel updated,
  ) async {
    // Get the existing assessment model to compare
    final existingModel = await _buildAssessmentFormModel(existing);

    // Compare key fields that would require full recreation
    final sameAssessorInfo =
        existingModel.assessorInfo.name == updated.assessorInfo.name &&
        existingModel.assessorInfo.email == updated.assessorInfo.email;

    final sameGeoLocation =
        existingModel.geoLocation.country == updated.geoLocation.country &&
        existingModel.geoLocation.regionProvince ==
            updated.geoLocation.regionProvince;

    final sameFacilityInfo =
        existingModel.facilityIdentification.facilityCode ==
            updated.facilityIdentification.facilityCode &&
        existingModel.facilityIdentification.facilityName ==
            updated.facilityIdentification.facilityName;

    final sameSectionCount =
        existingModel.sections.length == updated.sections.length;

    // If core data is the same, this is likely just a status/notes update
    return sameAssessorInfo &&
        sameGeoLocation &&
        sameFacilityInfo &&
        sameSectionCount;
  }

  /// Delete an assessment
  Future<bool> deleteAssessment(String id) async {
    try {
      return await transaction(() async {
        // Check if assessment exists
        final existing =
            await (select(assessmentForms)
              ..where((form) => form.id.equals(id))).getSingleOrNull();

        if (existing == null) return false;

        // Delete all related data
        await _deleteAssessmentRelatedData(id);

        return true;
      });
    } catch (e) {
      return false;
    }
  }

  Future<int> deleteAllAssessments(List<String> assessmentIds) async {
    if (assessmentIds.isEmpty) return 0;

    // Use Drift's batch operations for better performance
    return await transaction(() async {
      int totalDeleted = 0;

      // Delete in batches to avoid potential SQL query size limits
      const batchSize = 100;
      for (int i = 0; i < assessmentIds.length; i += batchSize) {
        final batch = assessmentIds.skip(i).take(batchSize).toList();

        // Use Drift's delete with where clause for bulk deletion
        final deleted =
            await (delete(assessmentForms)
              ..where((tbl) => tbl.id.isIn(batch))).go();

        totalDeleted += deleted;
      }

      return totalDeleted;
    });
  }

  // =================== STREAM METHODS ===================

  /// Watch all assessments as a stream
  Stream<List<AssessmentFormModel>> watchAllAssessments() {
    return _watchAssessments(
      (query) => query..orderBy([(form) => OrderingTerm.desc(form.updatedAt)]),
    );
  }

  /// Watch unsubmitted assessments as a stream
  Stream<List<AssessmentFormModel>> watchUnsubmittedAssessments() {
    return _watchAssessments(
      (query) =>
          query
            ..where((form) => form.isSubmitted.equals(false))
            ..orderBy([(form) => OrderingTerm.desc(form.updatedAt)]),
    );
  }

  /// Watch submitted assessments as a stream
  Stream<List<AssessmentFormModel>> watchSubmittedAssessments() {
    return _watchAssessments(
      (query) =>
          query
            ..where((form) => form.isSubmitted.equals(true))
            ..orderBy([(form) => OrderingTerm.desc(form.submissionDate)]),
    );
  }

  // =================== SEARCH METHODS ===================

  /// Search assessments by facility name
  Future<List<AssessmentFormModel>> searchByFacilityName(
    String searchTerm,
  ) async {
    return _searchAssessments(
      facilityIdentifications,
      facilityIdentifications.facilityName.like('%$searchTerm%'),
    );
  }

  /// Search assessments by assessor name
  Future<List<AssessmentFormModel>> searchByAssessorName(
    String searchTerm,
  ) async {
    return _searchAssessments(
      assessorInfos,
      assessorInfos.name.like('%$searchTerm%'),
    );
  }

  /// Get assessments within a date range
  Future<List<AssessmentFormModel>> getAssessmentsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final forms =
          await (select(assessmentForms)
                ..where(
                  (form) => form.createdAt.isBetweenValues(startDate, endDate),
                )
                ..orderBy([(form) => OrderingTerm.desc(form.createdAt)]))
              .get();

      return _buildAssessmentModels(forms);
    } catch (e) {
      rethrow;
    }
  }

  // =================== BULK OPERATIONS ===================

  /// Clear all assessments
  Future<bool> clearAllAssessments() async {
    try {
      return await transaction(() async {
        // Delete in correct order to respect foreign key constraints

        // 1. Delete assessment ratings first (no foreign keys point to them)
        await delete(assessmentRatings).go();

        // 2. Delete assessment items (foreign keys from ratings, but ratings are gone)
        await delete(assessmentItems).go();

        // 3. Delete assessment sections (foreign keys from items, but items are gone)
        await delete(assessmentSections).go();

        // 4. Delete photos (foreign keys from assessment forms)
        await delete(photos).go();

        // 5. Delete assessment forms (this removes foreign key references to other entities)
        await delete(assessmentForms).go();

        // 6. delete the entities that were referenced by assessment forms
        await delete(facilityServices).go();

        await delete(facilityIdentifications).go();

        await delete(geoLocations).go();

        await delete(assessorInfos).go();

        return true;
      });
    } catch (e) {
      return false;
    }
  }

  // =================== PHOTO METHODS ===================

  /// Save photos for an assessment
  Future<void> _savePhotos(
    String assessmentId,
    List<PhotoModel> photoList,
  ) async {
    // Delete existing photos for this assessment
    await (delete(photos)
      ..where((p) => p.assessmentFormId.equals(assessmentId))).go();

    // Insert new photos
    for (final photo in photoList) {
      await into(photos).insert(
        PhotosCompanion.insert(
          id: photo.id,
          assessmentFormId: assessmentId,
          fileName: photo.fileName,
          filePath: photo.filePath,
          source: photo.source.toString().split('.').last,
          fileSizeBytes: photo.fileSizeBytes,
          capturedAt: photo.capturedAt ?? DateTime.now(),
          description: Value(photo.description),
        ),
      );
    }
  }

  /// Load photos for an assessment
  Future<List<PhotoModel>> _loadPhotos(String assessmentId) async {
    final photoRows =
        await (select(photos)
              ..where((p) => p.assessmentFormId.equals(assessmentId))
              ..orderBy([(p) => OrderingTerm.asc(p.capturedAt)]))
            .get();

    return photoRows
        .map(
          (row) => PhotoModel(
            id: row.id,
            fileName: row.fileName,
            filePath: row.filePath,
            source: PhotoSource.values.firstWhere(
              (s) => s.toString().split('.').last == row.source,
            ),
            fileSizeBytes: row.fileSizeBytes,
            capturedAt: row.capturedAt,
            description: row.description,
          ),
        )
        .toList();
  }

  /// Delete photos for an assessment
  Future<void> _deletePhotos(String assessmentId) async {
    await (delete(photos)
      ..where((p) => p.assessmentFormId.equals(assessmentId))).go();
  }

  // =================== INTERNAL HELPER METHODS ===================

  /// Build list of AssessmentFormModels from database rows
  Future<List<AssessmentFormModel>> _buildAssessmentModels(
    List<AssessmentFormData> forms,
  ) async {
    final models = <AssessmentFormModel>[];
    for (final form in forms) {
      models.add(await _buildAssessmentFormModel(form));
    }
    return models;
  }

  /// Build AssessmentFormModel from database row
  Future<AssessmentFormModel> _buildAssessmentFormModel(
    AssessmentFormData form,
  ) async {
    // Get related entities in parallel for better performance
    final futures = await Future.wait([
      _getAssessorInfo(form.assessorInfoId),
      _getGeoLocation(form.geoLocationId),
      _getFacilityIdentification(form.facilityIdentificationId),
      _getFacilityServices(form.facilityServicesId),
      _getAssessmentSections(form.id),
      _loadPhotos(form.id),
    ]);

    return AssessmentFormModel(
      id: form.id,
      assessorInfo: futures[0] as AssessorInfoModel,
      geoLocation: futures[1] as GeoLocationModel,
      facilityIdentification: futures[2] as FacilityIdentificationModel,
      facilityServices: futures[3] as FacilityServicesModel,
      sections: futures[4] as List<AssessmentSectionModel>,
      photos: futures[5] as List<PhotoModel>,
      notes: form.notes,
      isSubmitted: form.isSubmitted,
      submissionDate: form.submissionDate,
      createdAt: form.createdAt,
      updatedAt: form.updatedAt,
    );
  }

  Future<void> _saveAssessmentInternal(AssessmentFormModel assessment) async {
    // Check if this assessment already exists to reuse entity IDs
    final existingForm =
        await (select(assessmentForms)
          ..where((f) => f.id.equals(assessment.id))).getSingleOrNull();

    // Use existing IDs if updating, generate new ones if creating
    final assessorInfoId = existingForm?.assessorInfoId ?? _uuid.v4();
    final geoLocationId = existingForm?.geoLocationId ?? _uuid.v4();
    final facilityIdId = existingForm?.facilityIdentificationId ?? _uuid.v4();
    final facilityServicesId = existingForm?.facilityServicesId ?? _uuid.v4();

    // Convert domain entities to models if needed
    final assessorInfoModel = AssessorInfoModel.fromEntity(
      assessment.assessorInfo,
    );
    final geoLocationModel = GeoLocationModel.fromEntity(
      assessment.geoLocation,
    );
    final facilityIdModel = FacilityIdentificationModel.fromEntity(
      assessment.facilityIdentification,
    );
    final facilityServicesModel = FacilityServicesModel.fromEntity(
      assessment.facilityServices,
    );

    // Save related entities first (they will update if IDs already exist)
    await Future.wait([
      _saveAssessorInfo(assessorInfoModel, assessorInfoId),
      _saveGeoLocation(geoLocationModel, geoLocationId),
      _saveFacilityIdentification(facilityIdModel, facilityIdId),
      _saveFacilityServices(facilityServicesModel, facilityServicesId),
    ]);

    // Save main assessment form
    await into(assessmentForms).insertOnConflictUpdate(
      AssessmentFormsCompanion.insert(
        id: assessment.id,
        assessorInfoId: assessorInfoId,
        geoLocationId: geoLocationId,
        facilityIdentificationId: facilityIdId,
        facilityServicesId: facilityServicesId,
        notes: Value(assessment.notes),
        isSubmitted: Value(assessment.isSubmitted),
        submissionDate: Value(assessment.submissionDate),
        createdAt: assessment.createdAt,
        updatedAt: assessment.updatedAt,
      ),
    );

    // Save sections with proper handling
    final sectionModels =
        assessment.sections
            .map((section) => AssessmentSectionModel.fromEntity(section))
            .toList();

    await _saveAssessmentSections(assessment.id, sectionModels);

    // Save photos
    await _savePhotos(assessment.id, assessment.photoModels);
  }

  Future<void> _deleteAssessmentRelatedData(String assessmentId) async {
    final form =
        await (select(assessmentForms)
          ..where((f) => f.id.equals(assessmentId))).getSingleOrNull();

    if (form == null) return;

    // Store the foreign key IDs BEFORE deleting anything
    final assessorInfoId = form.assessorInfoId;
    final geoLocationId = form.geoLocationId;
    final facilityIdentificationId = form.facilityIdentificationId;
    final facilityServicesId = form.facilityServicesId;

    // 1. Delete assessment items and their ratings (using improved method)
    await _deleteAssessmentItemsAndRatings(assessmentId);

    // 2. Delete sections
    await (delete(assessmentSections)
      ..where((s) => s.assessmentFormId.equals(assessmentId))).go();

    // 3. Delete photos
    await _deletePhotos(assessmentId);

    // 4. Delete the assessment form
    await (delete(assessmentForms)
      ..where((f) => f.id.equals(assessmentId))).go();

    // 5. Check if the related entities are used by other assessments before deleting
    // Check AssessorInfo
    final assessmentsUsingAssessorInfo =
        await (select(assessmentForms)
          ..where((f) => f.assessorInfoId.equals(assessorInfoId))).get();
    if (assessmentsUsingAssessorInfo.isEmpty) {
      await (delete(assessorInfos)
        ..where((a) => a.id.equals(assessorInfoId))).go();
    }

    // Check GeoLocation
    final assessmentsUsingGeoLocation =
        await (select(assessmentForms)
          ..where((f) => f.geoLocationId.equals(geoLocationId))).get();
    if (assessmentsUsingGeoLocation.isEmpty) {
      await (delete(geoLocations)
        ..where((g) => g.id.equals(geoLocationId))).go();
    }

    // Check FacilityIdentification
    final assessmentsUsingFacilityId =
        await (select(assessmentForms)..where(
          (f) => f.facilityIdentificationId.equals(facilityIdentificationId),
        )).get();
    if (assessmentsUsingFacilityId.isEmpty) {
      await (delete(facilityIdentifications)
        ..where((f) => f.id.equals(facilityIdentificationId))).go();
    }

    // Check FacilityServices
    final assessmentsUsingFacilityServices =
        await (select(
          assessmentForms,
        )..where((f) => f.facilityServicesId.equals(facilityServicesId))).get();
    if (assessmentsUsingFacilityServices.isEmpty) {
      await (delete(facilityServices)
        ..where((f) => f.id.equals(facilityServicesId))).go();
    }
  }

  /// Delete assessment items and their ratings
  Future<void> _deleteAssessmentItemsAndRatings(String assessmentId) async {
    try {
      final sections =
          await (select(assessmentSections)
            ..where((s) => s.assessmentFormId.equals(assessmentId))).get();

      for (final section in sections) {
        await _deleteSectionAndItems(section.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  // =================== WATCH HELPER METHODS ===================

  /// Generic watch assessments method
  Stream<List<AssessmentFormModel>> _watchAssessments(
    void Function(
      SimpleSelectStatement<$AssessmentFormsTable, AssessmentFormData>,
    )
    configureQuery,
  ) {
    final query = select(assessmentForms);
    configureQuery(query);

    return query.watch().asyncMap((forms) async {
      return _buildAssessmentModels(forms);
    });
  }

  // =================== SEARCH HELPER METHODS ===================

  /// Generic search assessments method
  Future<List<AssessmentFormModel>> _searchAssessments<T extends Table>(
    T table,
    Expression<bool> whereClause,
  ) async {
    try {
      final query = select(
        assessmentForms,
      ).join([innerJoin(table, _getJoinCondition(table))])..where(whereClause);

      final results = await query.get();
      final models = <AssessmentFormModel>[];

      for (final result in results) {
        final form = result.readTable(assessmentForms);
        models.add(await _buildAssessmentFormModel(form));
      }

      return models;
    } catch (e) {
      rethrow;
    }
  }

  /// Get join condition for search queries
  Expression<bool> _getJoinCondition(Table table) {
    if (table == facilityIdentifications) {
      return facilityIdentifications.id.equalsExp(
        assessmentForms.facilityIdentificationId,
      );
    } else if (table == assessorInfos) {
      return assessorInfos.id.equalsExp(assessmentForms.assessorInfoId);
    }
    throw ArgumentError('Unsupported table for join condition');
  }

  // =================== ENTITY-SPECIFIC CRUD METHODS ===================

  /// Get AssessorInfo by ID
  Future<AssessorInfoModel> _getAssessorInfo(String id) async {
    final data =
        await (select(assessorInfos)
          ..where((a) => a.id.equals(id))).getSingle();

    return AssessorInfoModel(
      name: data.name,
      email: data.email,
      phoneNumber: data.phoneNumber,
      assessmentDate: data.assessmentDate,
    );
  }

  /// Save AssessorInfo with proper upsert
  Future<void> _saveAssessorInfo(
    AssessorInfoModel assessorInfo,
    String id,
  ) async {
    await into(assessorInfos).insertOnConflictUpdate(
      AssessorInfosCompanion(
        id: Value(id),
        name: Value(assessorInfo.name),
        email: Value(assessorInfo.email),
        phoneNumber: Value(assessorInfo.phoneNumber),
        assessmentDate: Value(assessorInfo.assessmentDate ?? DateTime.now()),
      ),
    );
  }

  /// Get GeoLocation by ID
  Future<GeoLocationModel> _getGeoLocation(String id) async {
    final data =
        await (select(geoLocations)..where((g) => g.id.equals(id))).getSingle();

    return GeoLocationModel(
      country: data.country,
      regionProvince: data.regionProvince,
      district: data.district,
      cityVillage: data.cityVillage,
      addressOrCoordinates: data.addressOrCoordinates,
      latitude: data.latitude,
      longitude: data.longitude,
      locationType: _parseLocationType(data.locationType),
    );
  }

  Future<void> _saveGeoLocation(GeoLocationModel geoLocation, String id) async {
    await into(geoLocations).insertOnConflictUpdate(
      GeoLocationsCompanion(
        id: Value(id),
        country: Value(geoLocation.country),
        regionProvince: Value(geoLocation.regionProvince),
        district: Value(geoLocation.district),
        cityVillage: Value(geoLocation.cityVillage),
        addressOrCoordinates: Value(geoLocation.addressOrCoordinates),
        locationType: Value(
          geoLocation.locationType.toString().split('.').last,
        ),
        latitude: Value(geoLocation.latitude ?? 0.0),
        longitude: Value(geoLocation.longitude ?? 0.0),
      ),
    );
  }

  /// Get FacilityIdentification by ID
  Future<FacilityIdentificationModel> _getFacilityIdentification(
    String id,
  ) async {
    final data =
        await (select(facilityIdentifications)
          ..where((f) => f.id.equals(id))).getSingle();

    return FacilityIdentificationModel(
      facilityCode: data.facilityCode,
      facilityName: data.facilityName,
      managingAuthority: _parseManagingAuthorityType(data.managingAuthority),
      directorName: data.directorName,
      directorPhone: data.directorPhone,
      directorEmail: data.directorEmail,
      respondentName: data.respondentName,
      respondentPosition: data.respondentPosition,
      structureType: _parseStructureType(data.structureType),
      facilityType: _parseFacilityType(data.facilityType),
      existingFacilityType: _parseExistingFacilityType(
        data.existingFacilityType,
      ),
    );
  }

  Future<void> _saveFacilityIdentification(
    FacilityIdentificationModel facilityId,
    String id,
  ) async {
    await into(facilityIdentifications).insertOnConflictUpdate(
      FacilityIdentificationsCompanion(
        id: Value(id),
        facilityCode: Value(facilityId.facilityCode),
        facilityName: Value(facilityId.facilityName),
        managingAuthority: Value(
          facilityId.managingAuthority.toString().split('.').last,
        ),
        directorName: Value(facilityId.directorName),
        directorPhone: Value(facilityId.directorPhone),
        directorEmail: Value(facilityId.directorEmail),
        respondentName: Value(facilityId.respondentName),
        respondentPosition: Value(facilityId.respondentPosition),
        structureType: Value(
          facilityId.structureType.toString().split('.').last,
        ),
        facilityType: Value(facilityId.facilityType.toString().split('.').last),
        existingFacilityType: Value(
          facilityId.existingFacilityType.toString().split('.').last,
        ),
      ),
    );
  }

  /// Get FacilityServices by ID
  Future<FacilityServicesModel> _getFacilityServices(String id) async {
    final data =
        await (select(facilityServices)
          ..where((f) => f.id.equals(id))).getSingle();

    return FacilityServicesModel(
      hasOutpatientServices: data.hasOutpatientServices,
      hasInpatientServices: data.hasInpatientServices,
      totalInpatientBeds: data.totalInpatientBeds,
      icuBeds: data.icuBeds,
      hasEmergencyUnit: data.hasEmergencyUnit,
      hasIcuOrHighDependencyUnit: data.hasIcuOrHighDependencyUnit,
    );
  }

  /// Save FacilityServices
  Future<void> _saveFacilityServices(
    FacilityServicesModel facilityServices,
    String id,
  ) async {
    await into(this.facilityServices).insertOnConflictUpdate(
      FacilityServicesCompanion(
        id: Value(id),
        hasOutpatientServices: Value(
          facilityServices.hasOutpatientServices ?? false,
        ),
        hasInpatientServices: Value(
          facilityServices.hasInpatientServices ?? false,
        ),
        totalInpatientBeds: Value(facilityServices.totalInpatientBeds ?? 0),
        icuBeds: Value(facilityServices.icuBeds ?? 0),
        hasEmergencyUnit: Value(facilityServices.hasEmergencyUnit ?? false),
        hasIcuOrHighDependencyUnit: Value(
          facilityServices.hasIcuOrHighDependencyUnit ?? false,
        ),
      ),
    );
  }

  /// Get AssessmentSections by form ID
  Future<List<AssessmentSectionModel>> _getAssessmentSections(
    String formId,
  ) async {
    final sectionsData =
        await (select(assessmentSections)
              ..where((s) => s.assessmentFormId.equals(formId))
              ..orderBy([(s) => OrderingTerm.asc(s.sectionNumber)]))
            .get();

    final sections = <AssessmentSectionModel>[];

    for (final sectionData in sectionsData) {
      final items = await _getAssessmentItems(sectionData.id);
      sections.add(
        AssessmentSectionModel(
          id: sectionData.id,
          sectionNumber: sectionData.sectionNumber,
          title: sectionData.title,
          description: sectionData.description,
          items: items,
        ),
      );
    }

    return sections;
  }

  /// Save AssessmentSections
  Future<void> _saveAssessmentSections(
    String formId,
    List<AssessmentSectionModel> sections,
  ) async {
    // First, get existing sections for this assessment
    final existingSections =
        await (select(assessmentSections)
          ..where((s) => s.assessmentFormId.equals(formId))).get();

    final existingSectionIds = existingSections.map((s) => s.id).toSet();
    final newSectionIds =
        sections.where((s) => s.id != null).map((s) => s.id!).toSet();

    // Delete sections that are no longer in the updated list
    final sectionsToDelete = existingSectionIds.difference(newSectionIds);
    for (final sectionId in sectionsToDelete) {
      await _deleteSectionAndItems(sectionId);
    }

    // Save or update sections
    for (final section in sections) {
      final sectionId =
          section.id?.isNotEmpty == true ? section.id! : _uuid.v4();

      await into(assessmentSections).insertOnConflictUpdate(
        AssessmentSectionsCompanion(
          id: Value(sectionId),
          assessmentFormId: Value(formId),
          sectionNumber: Value(section.sectionNumber),
          title: Value(section.title),
          description: Value(section.description ?? ''),
        ),
      );

      // Save items for this section
      await _saveAssessmentItems(
        sectionId,
        section.items
            .map((item) => AssessmentItemModel.fromEntity(item))
            .toList(),
      );
    }
  }

  /// Delete a section and all its items
  Future<void> _deleteSectionAndItems(String sectionId) async {
    // Get all items in this section
    final items =
        await (select(assessmentItems)
          ..where((i) => i.sectionId.equals(sectionId))).get();

    // Delete all items in this section
    await (delete(assessmentItems)
      ..where((i) => i.sectionId.equals(sectionId))).go();

    // Delete ratings for each item
    for (final item in items) {
      if (item.selectedRatingId != null) {
        await _deleteRatingIfNotUsed(item.selectedRatingId!);
      }
    }

    // Delete the section
    await (delete(assessmentSections)
      ..where((s) => s.id.equals(sectionId))).go();
  }

  /// Delete a rating only if it's not used by any other item
  Future<void> _deleteRatingIfNotUsed(String ratingId) async {
    // Check if any other item uses this rating
    final itemsUsingRating =
        await (select(assessmentItems)
          ..where((i) => i.selectedRatingId.equals(ratingId))).get();

    // If no items use this rating, delete it
    if (itemsUsingRating.isEmpty) {
      await (delete(assessmentRatings)
        ..where((r) => r.id.equals(ratingId))).go();
    }
  }

  /// Get AssessmentItems by section ID
  Future<List<AssessmentItemModel>> _getAssessmentItems(
    String sectionId,
  ) async {
    final itemsData =
        await (select(assessmentItems)
          ..where((i) => i.sectionId.equals(sectionId))).get();

    final items = <AssessmentItemModel>[];

    for (final itemData in itemsData) {
      AssessmentRatingModel? rating;

      if (itemData.selectedRatingId != null) {
        rating = await _getAssessmentRating(itemData.selectedRatingId!);
      }

      items.add(
        AssessmentItemModel(
          id: itemData.id,
          itemNumber: itemData.itemNumber,
          sectionNumber: itemData.sectionNumber,
          area: itemData.area,
          meetsTargetDescription: itemData.meetsTargetDescription,
          partiallyMeetsDescription: itemData.partiallyMeetsDescription,
          doesNotMeetDescription: itemData.doesNotMeetDescription,
          selectedRating: rating,
        ),
      );
    }

    return items;
  }

  /// Save AssessmentItems
  Future<void> _saveAssessmentItems(
    String sectionId,
    List<AssessmentItemModel> items,
  ) async {
    // Get existing items for this section
    final existingItems =
        await (select(assessmentItems)
          ..where((i) => i.sectionId.equals(sectionId))).get();

    // Create a map of item number to existing item data
    final existingItemsMap = <String, AssessmentItemData>{};
    for (final item in existingItems) {
      existingItemsMap[item.itemNumber] = item;
    }

    // Track which items we've processed
    final processedItemNumbers = <String>{};

    for (final item in items) {
      processedItemNumbers.add(item.itemNumber);

      // Check if this item already exists
      final existingItem = existingItemsMap[item.itemNumber];
      final itemId = existingItem?.id;

      // Handle rating
      String? ratingId;
      if (item.selectedRating != null) {
        // For ratings, we create a new one each time since they're specific to an item
        // This prevents sharing ratings between different assessments
        ratingId = _uuid.v4();
        await _saveAssessmentRating(
          AssessmentRatingModel.fromEntity(item.selectedRating!),
          ratingId,
        );

        // If there was an old rating, we'll clean it up later
      }

      // Build the companion based on whether item exists
      final companion =
          itemId != null
              ? AssessmentItemsCompanion(
                id: Value(itemId),
                itemNumber: Value(item.itemNumber),
                sectionId: Value(sectionId),
                sectionNumber: Value(item.sectionNumber),
                area: Value(item.area),
                meetsTargetDescription: Value(item.meetsTargetDescription),
                partiallyMeetsDescription: Value(
                  item.partiallyMeetsDescription,
                ),
                doesNotMeetDescription: Value(item.doesNotMeetDescription),
                selectedRatingId: Value(ratingId),
              )
              : AssessmentItemsCompanion.insert(
                itemNumber: item.itemNumber,
                sectionId: sectionId,
                sectionNumber: item.sectionNumber,
                area: item.area,
                meetsTargetDescription: item.meetsTargetDescription,
                partiallyMeetsDescription: item.partiallyMeetsDescription,
                doesNotMeetDescription: item.doesNotMeetDescription,
                selectedRatingId: Value(ratingId),
              );

      await into(assessmentItems).insertOnConflictUpdate(companion);
    }

    // Delete items that are no longer in the updated list
    final itemsToDelete = existingItemsMap.keys.toSet().difference(
      processedItemNumbers,
    );
    for (final itemNumber in itemsToDelete) {
      final item = existingItemsMap[itemNumber]!;
      // Delete the item's rating if it exists
      if (item.selectedRatingId != null) {
        await _deleteRatingIfNotUsed(item.selectedRatingId!);
      }
      // Delete the item
      await (delete(assessmentItems)..where((i) => i.id.equals(item.id))).go();
    }

    // Clean up orphaned ratings from updated items
    for (final item in existingItems) {
      if (processedItemNumbers.contains(item.itemNumber) &&
          item.selectedRatingId != null) {
        // This item was updated, so its old rating might be orphaned
        await _deleteRatingIfNotUsed(item.selectedRatingId!);
      }
    }
  }

  /// Get AssessmentRating by ID
  Future<AssessmentRatingModel> _getAssessmentRating(String id) async {
    final data =
        await (select(assessmentRatings)
          ..where((r) => r.id.equals(id))).getSingle();

    return AssessmentRatingModel(
      id: data.id,
      value: data.value,
      label: data.label,
      description: '',
    );
  }

  Future<void> _saveAssessmentRating(
    AssessmentRatingModel rating,
    String id,
  ) async {
    await into(assessmentRatings).insertOnConflictUpdate(
      AssessmentRatingsCompanion(
        id: Value(id),
        value: Value(rating.value),
        label: Value(rating.label),
      ),
    );
  }

  // =================== PARSING UTILITY METHODS ===================

  /// Parse location type from string
  domain.FacilityLocationType _parseLocationType(String value) {
    return domain.FacilityLocationType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => domain.FacilityLocationType.urban,
    );
  }

  /// Parse managing authority type from string
  domain_facility.ManagingAuthorityType _parseManagingAuthorityType(
    String value,
  ) {
    return domain_facility.ManagingAuthorityType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => domain_facility.ManagingAuthorityType.government,
    );
  }

  /// Parse structure type from string
  domain_facility.FacilityStructureType _parseStructureType(String value) {
    return domain_facility.FacilityStructureType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => domain_facility.FacilityStructureType.permanent,
    );
  }

  /// Parse facility type from string
  domain_facility.FacilityType _parseFacilityType(String value) {
    return domain_facility.FacilityType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => domain_facility.FacilityType.screeningAndTemporaryIsolation,
    );
  }

  /// Parse existing facility type from string
  domain_facility.ExistingFacilityType _parseExistingFacilityType(
    String value,
  ) {
    return domain_facility.ExistingFacilityType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => domain_facility.ExistingFacilityType.firstReferralHospital,
    );
  }

  /// Test helper method to test _getJoinCondition with unsupported tables
  /// This method is only intended for testing coverage of ArgumentError
  @visibleForTesting
  Expression<bool> testGetJoinCondition(Table table) {
    return _getJoinCondition(table);
  }
}
