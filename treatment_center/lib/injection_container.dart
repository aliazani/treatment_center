import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import 'package:treatment_center/core/database/app_database.dart';
import 'package:treatment_center/core/database/daos/assessment_dao.dart';
import 'package:treatment_center/core/network/network_info.dart';
import 'package:treatment_center/core/providers/file_provider.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/save_path_resolver.dart';
import 'package:treatment_center/core/services/doc_export_service.dart';
import 'package:treatment_center/core/services/email_sender_service.dart';
import 'package:treatment_center/core/services/email_sender_service_impl.dart';
import 'package:treatment_center/core/services/excel_export_service.dart';
import 'package:treatment_center/core/services/excel_import_service.dart';
import 'package:treatment_center/core/services/pdf_export_service.dart';
import 'package:treatment_center/features/geolocation/data/datasources/geographic_local_data_source.dart';
import 'package:treatment_center/features/geolocation/data/datasources/geographic_local_data_source_impl.dart';
import 'package:treatment_center/features/geolocation/data/repositories/geographic_repository_impl.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_cities_by_region.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_countries.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_country_codes.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_phone_code_by_country.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_regions_by_country.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_bloc.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_bloc.dart';

// Data Sources
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource_drift_impl.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource_impl.dart';

// Repositories
import 'package:treatment_center/features/questionnaire_form/data/repositories/assessment_repository_impl.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';

// Use Cases
import 'package:treatment_center/features/questionnaire_form/domain/usecases/create_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/export_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/import_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/save_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/submit_assessment_via_firebase_email_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/update_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/validate_section_usecase.dart';

// Presentation / BLoC
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_bloc.dart';

/// Global service locator instance
final sl = GetIt.instance;

/// Initializes all dependencies
Future<void> init() async {
  await _registerExternal();
  await _registerFirebase();
  _registerCore();
  _registerDataLayer();
  _registerDomainLayer();
  _registerPresentationLayer();
}

// ==================== External Dependencies ====================

/// Registers third-party dependencies
Future<void> _registerExternal() async {
  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // HTTP Client
  sl.registerLazySingleton(() => http.Client());

  // Internet Connection Checker
  sl.registerLazySingleton(() => InternetConnectionChecker.createInstance());
}

/// Registers Firebase services
Future<void> _registerFirebase() async {
  await Firebase.initializeApp();

  if (!sl.isRegistered<FirebaseStorage>()) {
    sl.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);
  }

  if (!sl.isRegistered<FirebaseFunctions>()) {
    sl.registerLazySingleton<FirebaseFunctions>(
      () => FirebaseFunctions.instance,
    );
  }
}

// ==================== Core Layer ====================

/// Registers core services and utilities
void _registerCore() {
  // Database
  sl.registerLazySingleton(() => AppDatabase());

  // Network
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(connectionChecker: sl()),
  );

  // File Management
  sl.registerLazySingleton<FileProvider>(() => FileProviderImpl());
  sl.registerLazySingleton<GetSavePath>(() => defaultSavePath);

  // Email Service
  sl.registerLazySingleton<EmailSenderService>(() => EmailSenderServiceImpl());

  // Excel Import Service (for bytes import in the BLoC)
  sl.registerLazySingleton<ExcelImportService>(
    () => ExcelImportService(fileProvider: sl<FileProvider>()),
  );
}

// ==================== Data Layer ====================

/// Registers data sources, repositories, and services
void _registerDataLayer() {
  _registerDataSources();
  _registerExportServices();
  _registerRepositories();
}

/// Registers local and remote data sources
void _registerDataSources() {
  // DAOs
  sl.registerLazySingleton(() => AssessmentDao(sl()));

  // Local Data Source
  sl.registerLazySingleton<AssessmentLocalDataSource>(
    () => AssessmentLocalDataSourceDriftImpl(assessmentDao: sl()),
  );

  // Remote Data Source
  sl.registerLazySingleton<AssessmentRemoteDataSource>(
    () => AssessmentRemoteDataSourceImpl(
      storage: sl(),
      functions: sl(),
      fileProvider: sl<FileProvider>(),
      excelService: sl(),
      pdfService: sl(),
      docService: sl(),
    ),
  );

  //
  //
  sl.registerLazySingleton<GeographicLocalDataSource>(
    () => GeographicLocalDataSourceImpl(),
  );
}

/// Registers export services
void _registerExportServices() {
  sl.registerLazySingleton(
    () => ExcelExportService(fileProvider: sl(), getSavePath: defaultSavePath),
  );

  sl.registerLazySingleton(
    () => PdfExportService(fileProvider: sl(), getSavePath: defaultSavePath),
  );

  sl.registerLazySingleton(
    () => DocExportService(fileProvider: sl(), getSavePath: defaultSavePath),
  );
}

/// Registers repository implementations
void _registerRepositories() {
  sl.registerLazySingleton<AssessmentRepository>(
    () => AssessmentRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  //
  //
  // ───────────── Geolocation Repository ─────────────
  sl.registerLazySingleton<GeographicRepository>(
    () => GeographicRepositoryImpl(localDataSource: sl()),
  );
}

// ==================== Domain Layer ====================

/// Registers use cases and domain services
void _registerDomainLayer() {
  _registerFactories();
  _registerCrudUseCases();
  _registerExportImportUseCases();
  _registerFirebaseUseCases();
}

/// Registers factory services and validators
void _registerFactories() {
  sl.registerLazySingleton<ExportServiceFactoryBase>(
    () => const ExportServiceFactoryAdapter(),
  );

  sl.registerLazySingleton<ImportServiceFactoryProtocol>(
    () => ImportServiceFactoryAdapter(),
  );

  sl.registerLazySingleton<AssessmentValidator>(
    () => const DefaultAssessmentValidator(),
  );
}

/// Registers CRUD use cases
void _registerCrudUseCases() {
  sl.registerLazySingleton(() => CreateAssessmentUsecase(sl()));
  sl.registerLazySingleton(() => GetAssessmentUsecase(sl()));
  sl.registerLazySingleton(() => GetAllAssessmentsUsecase(sl()));
  sl.registerLazySingleton(() => SaveAssessmentUsecase(sl()));
  sl.registerLazySingleton(() => UpdateAssessmentUsecase(sl()));
  sl.registerLazySingleton(() => DeleteAssessmentUsecase(sl()));
  sl.registerLazySingleton(() => DeleteAllAssessmentsUsecase(sl()));
  sl.registerLazySingleton(() => ValidateSectionUsecase());
}

/// Registers export and import use cases
void _registerExportImportUseCases() {
  // Export Use Cases
  sl.registerLazySingleton(
    () => ExportAssessmentUsecase(
      factory: sl<ExportServiceFactoryBase>(),
      validator: sl<AssessmentValidator>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetExportStatistics(
      factory: sl<ExportServiceFactoryBase>(),
      validator: sl<AssessmentValidator>(),
    ),
  );

  sl.registerLazySingleton(
    () => ValidateAssessmentForExport(
      factory: sl<ExportServiceFactoryBase>(),
      validator: sl<AssessmentValidator>(),
    ),
  );

  // Import Use Cases
  sl.registerLazySingleton(
    () => ImportAssessmentUsecase(
      sl<AssessmentRepository>(),
      factory: sl<ImportServiceFactoryProtocol>(),
    ),
  );

  sl.registerLazySingleton(
    () => ImportAssessmentFromExcel(
      sl<AssessmentRepository>(),
      factory: sl<ImportServiceFactoryProtocol>(),
      fileProvider: sl<FileProvider>(),
    ),
  );

  sl.registerLazySingleton(
    () => GetImportStatistics(
      factory: sl<ImportServiceFactoryProtocol>(),
      fileProvider: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => GetCountryCodesUsecase(sl<GeographicRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPhoneCodeByCountry(sl<GeographicRepository>()),
  );
}

/// Registers Firebase-specific use cases
void _registerFirebaseUseCases() {
  sl.registerLazySingleton(() => SubmitAssessmentViaFirebaseEmailUsecase(sl()));

  sl.registerLazySingleton(() => UploadAssessmentToFirebase(sl()));

  //
  // ───────────── Geolocation Use Cases ─────────────
  sl.registerLazySingleton(() => GetCountries(sl<GeographicRepository>()));
  sl.registerLazySingleton(
    () => GetRegionsByCountry(sl<GeographicRepository>()),
  );
  sl.registerLazySingleton(() => GetCitiesByRegion(sl<GeographicRepository>()));
}

// ==================== Presentation Layer ====================

/// Registers BLoCs for presentation layer
void _registerPresentationLayer() {
  // Assessment Form BLoC
  sl.registerFactory(
    () => AssessmentFormBloc(
      getAssessment: sl(),
      saveAssessment: sl(),
      exportAssessment: sl(),
      submitFirebaseEmail: sl(),
      getExportStatistics: sl(),
      validateAssessmentForExport: sl(),
      validateSection: sl(),
    ),
  );

  // Saved Assessments BLoC
  sl.registerFactory(
    () => AssessmentListBloc(getAllAssessments: sl(), deleteAssessment: sl()),
  );

  // Import BLoC
  sl.registerFactory(
    () => ImportAssessmentBloc(
      importAssessmentUsecase: sl(),
      importAssessmentFromExcel: sl(),
      getImportStatistics: sl(),
      assessmentRepository: sl(),
      excelImportService: sl(),
    ),
  );

  sl.registerFactory(
    () => GeographicCascadeBloc(
      sl<GetCountries>(),
      sl<GetRegionsByCountry>(),
      sl<GetCitiesByRegion>(),
    ),
  );

  // Comparison BLoC
  sl.registerFactory(
    () => CompareAssessmentsBloc(
      getAllAssessments: sl(),
      getAssessmentById: sl(),
    ),
  );

  sl.registerFactory(
    () => PhoneInputBloc(getCountryCodesUsecase: sl<GetCountryCodesUsecase>()),
  );
}

// ==================== Utility Functions ====================

/// Resets all registrations (useful for testing)
Future<void> reset() async => sl.reset();

/// Checks if type T is registered
bool isRegistered<T extends Object>() => sl.isRegistered<T>();

/// Gets an instance of type T from the service locator
T get<T extends Object>() => sl<T>();
