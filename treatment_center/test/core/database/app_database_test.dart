@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:treatment_center/core/database/app_database.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('in-memory database', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('schemaVersion == 1', () {
      expect(db.schemaVersion, 1);
    });

    test('foreign_keys pragma is ON', () async {
      final on = await db
          .customSelect('PRAGMA foreign_keys;')
          .getSingle()
          .then((row) => row.data.values.single);
      expect(on, 1);
    });

    test('basic SELECT works', () async {
      final row = await db.customSelect('SELECT 1 AS test').getSingleOrNull();
      expect(row?.data['test'], 1);
    });

    test('insert ↔ fetch round-trip + cascade delete', () async {
      final ids = await _seedMinimal(db);

      final forms = await db.select(db.assessmentForms).get();
      expect(forms, hasLength(1));
      expect(forms.single.id, ids.form);

      await db.delete(db.assessmentForms).delete(forms.single);

      final remaining = await db.select(db.assessmentForms).get();
      expect(remaining, isEmpty);
    });
  });

  group('default constructor (file-backed)', () {
    late AppDatabase integrationDb;

    setUpAll(() {
      PathProviderPlatform.instance = _FakePathProvider();
    });

    setUp(() {
      integrationDb = AppDatabase(); // uses connection_native.dart
    });

    tearDown(() => integrationDb.close());

    test('schemaVersion == 1', () {
      expect(integrationDb.schemaVersion, 1);
    });

    test('foreign_keys pragma is ON', () async {
      final on = await integrationDb
          .customSelect('PRAGMA foreign_keys;')
          .getSingle()
          .then((row) => row.data.values.single);
      expect(on, 1);
    });

    test('basic SELECT works', () async {
      final row =
          await integrationDb
              .customSelect('SELECT 1 AS test')
              .getSingleOrNull();
      expect(row?.data['test'], 1);
    });

    test('insert ↔ delete cascade on assessmentForms', () async {
      final ids = await _seedMinimal(integrationDb);

      final forms =
          await integrationDb.select(integrationDb.assessmentForms).get();
      expect(forms, hasLength(1));
      expect(forms.single.id, ids.form);

      await integrationDb
          .delete(integrationDb.assessmentForms)
          .delete(forms.single);

      final remaining =
          await integrationDb.select(integrationDb.assessmentForms).get();
      expect(remaining, isEmpty);
    });
  });
}

/// Temporary directory provider used by the file-backed tests.
class _FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = await Directory.systemTemp.createTemp('tc_db_');
    return dir.path;
  }
}

/// IDs returned by [_seedMinimal].
class _Ids {
  const _Ids(this.form, this.assessor, this.geo, this.fac, this.svc);
  final String form, assessor, geo, fac, svc;
}

/// Inserts the minimum set of rows required for cascade-delete checks.
Future<_Ids> _seedMinimal(AppDatabase db) async {
  final uuid = const Uuid();
  final now = DateTime.now();

  // assessor
  final assessorId = uuid.v4();
  await db
      .into(db.assessorInfos)
      .insert(
        AssessorInfosCompanion.insert(
          id: assessorId,
          name: 'A',
          email: 'a@a',
          phoneNumber: '0',
          assessmentDate: now,
        ),
      );

  // geo
  final geoId = uuid.v4();
  await db
      .into(db.geoLocations)
      .insert(
        GeoLocationsCompanion.insert(
          id: geoId,
          country: 'X',
          regionProvince: 'R',
          district: 'D',
          cityVillage: 'C',
          addressOrCoordinates: '0,0',
          locationType: 'urban',
          latitude: 0,
          longitude: 0,
        ),
      );

  // facility
  final facId = uuid.v4();
  await db
      .into(db.facilityIdentifications)
      .insert(
        FacilityIdentificationsCompanion.insert(
          id: facId,
          facilityCode: 'F',
          facilityName: 'F',
          managingAuthority: 'MA',
          directorName: 'DN',
          directorPhone: '0',
          directorEmail: 'd@d',
          respondentName: 'RN',
          respondentPosition: 'RP',
          structureType: 'Permanent',
          facilityType: 'Hospital',
          existingFacilityType: 'Public',
        ),
      );

  // services
  final svcId = uuid.v4();
  await db
      .into(db.facilityServices)
      .insert(
        FacilityServicesCompanion.insert(
          id: svcId,
          hasOutpatientServices: true,
          hasInpatientServices: true,
          totalInpatientBeds: 1,
          icuBeds: 0,
          hasEmergencyUnit: false,
          hasIcuOrHighDependencyUnit: false,
        ),
      );

  // form
  final formId = uuid.v4();
  await db
      .into(db.assessmentForms)
      .insert(
        AssessmentFormsCompanion.insert(
          id: formId,
          assessorInfoId: assessorId,
          geoLocationId: geoId,
          facilityIdentificationId: facId,
          facilityServicesId: svcId,
          createdAt: now,
          updatedAt: now,
        ),
      );

  return _Ids(formId, assessorId, geoId, facId, svcId);
}
