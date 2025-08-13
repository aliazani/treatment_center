import 'package:drift/drift.dart';
import 'tables/assessment_tables.dart';
import 'daos/assessment_dao.dart';
import 'connection_stub.dart'
    if (dart.library.ffi) 'connection_native.dart'
    if (dart.library.js_interop) 'connection_web.dart';

part 'app_database.g.dart';

@DriftDatabase(
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
  daos: [AssessmentDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    beforeOpen: (_) async => await customStatement('PRAGMA foreign_keys = ON'),
  );
}
