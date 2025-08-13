import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:treatment_center/core/database/app_database.dart';
import 'package:treatment_center/core/network/network_info.dart';
import 'package:treatment_center/core/providers/file_provider.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/providers/save_path_resolver.dart';
import 'package:treatment_center/core/services/email_sender_service.dart';
import 'package:treatment_center/core/services/email_sender_service_impl.dart';
import 'package:treatment_center/core/services/excel_export_service.dart';
import 'package:treatment_center/core/services/pdf_export_service.dart';
import 'package:treatment_center/core/services/doc_export_service.dart';
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
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_local_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource.dart';
import 'package:treatment_center/features/questionnaire_form/data/datasources/assessment_remote_datasource_impl.dart';
import 'package:treatment_center/features/questionnaire_form/data/repositories/assessment_repository_impl.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/create_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/get_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/save_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/update_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/delete_all_assessments_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/export_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/import_assessment_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/submit_assessment_via_firebase_email_usecase.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/compare_assessments/compare_assessments_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_form/assessment_form_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/import_assessment/import_assessment_bloc.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/bloc/assessment_list/assessment_list_bloc.dart';

import 'package:treatment_center/injection_container.dart' as di;

// Mock classes for Firebase services
class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseFunctions extends Mock implements FirebaseFunctions {}

/// Tests for the dependency injection container.
///
/// Note: Services that depend on Firebase (Storage/Functions) cannot be instantiated
/// in tests because they require a configured Firebase project with a storage bucket.
/// For these services, we test that they are properly registered but don't instantiate them.
///
/// Services that don't depend on Firebase can be fully tested including instantiation
/// and singleton/factory behavior verification.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  group('Injection Container - Initialization', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});

      // register Firebase mocks before init()
      di.sl.registerLazySingleton<FirebaseStorage>(() => MockFirebaseStorage());
      di.sl.registerLazySingleton<FirebaseFunctions>(
        () => MockFirebaseFunctions(),
      );
    });

    tearDown(() async {
      await di.reset();
    });

    test('should initialize all dependencies without errors', () async {
      // expect(() async => await di.init(), returnsNormally);
      // 1) actually initialize the service locator
      await di.init();

      expect(di.isRegistered<AssessmentRemoteDataSource>(), isTrue);
      final remoteDs = di.get<AssessmentRemoteDataSource>();
      expect(remoteDs, isA<AssessmentRemoteDataSourceImpl>());

      final excelSvc = di.get<ExcelExportService>();
      expect(excelSvc, isA<ExcelExportService>());
      final pdfSvc = di.get<PdfExportService>();
      expect(pdfSvc, isA<PdfExportService>());
      final docSvc = di.get<DocExportService>();
      expect(docSvc, isA<DocExportService>());

      final repo = di.get<AssessmentRepository>();
      expect(repo, isA<AssessmentRepositoryImpl>());

      final exportUC = di.get<ExportAssessmentUsecase>();
      final getExpSts = di.get<GetExportStatistics>();
      final valExp = di.get<ValidateAssessmentForExport>();
      expect(exportUC, isA<ExportAssessmentUsecase>());
      expect(getExpSts, isA<GetExportStatistics>());
      expect(valExp, isA<ValidateAssessmentForExport>());

      final impUC = di.get<ImportAssessmentUsecase>();
      final impExcelUC = di.get<ImportAssessmentFromExcel>();
      final getImpSts = di.get<GetImportStatistics>();
      expect(impUC, isA<ImportAssessmentUsecase>());
      expect(impExcelUC, isA<ImportAssessmentFromExcel>());
      expect(getImpSts, isA<GetImportStatistics>());

      final formBloc = di.get<AssessmentFormBloc>();
      final savedBloc = di.get<AssessmentListBloc>();
      final impBloc = di.get<ImportAssessmentBloc>();
      final cmpBloc = di.get<CompareAssessmentsBloc>();
      expect(formBloc, isA<AssessmentFormBloc>());
      expect(savedBloc, isA<AssessmentListBloc>());
      expect(impBloc, isA<ImportAssessmentBloc>());
      expect(cmpBloc, isA<CompareAssessmentsBloc>());
    });

    test('should maintain singleton instances for lazy singletons', () async {
      await di.init();

      final database1 = di.get<AppDatabase>();
      final database2 = di.get<AppDatabase>();

      expect(identical(database1, database2), isTrue);

      final networkInfo1 = di.get<NetworkInfo>();
      final networkInfo2 = di.get<NetworkInfo>();

      expect(identical(networkInfo1, networkInfo2), isTrue);
    });

    test('should create new instances for factories', () async {
      await di.init();

      // Note: BLoCs depend on Firebase services which can't be instantiated in tests
      // We'll test that they're registered as factories, not that we can create them
      expect(di.isRegistered<AssessmentFormBloc>(), isTrue);
      expect(di.isRegistered<AssessmentListBloc>(), isTrue);

      // For services that don't depend on Firebase, we can test factory behavior
      // by checking registration type
    });
  });

  group('Injection Container - External Dependencies', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({'test_key': 'test_value'});
    });

    tearDown(() async {
      await di.reset();
    });

    test(
      'should register and retrieve SharedPreferences with initial values',
      () async {
        await di.init();

        final prefs = di.get<SharedPreferences>();
        expect(prefs, isA<SharedPreferences>());
        expect(prefs.getString('test_key'), equals('test_value'));
      },
    );

    test('should register HTTP client', () async {
      await di.init();

      final client = di.get<http.Client>();
      expect(client, isA<http.Client>());
    });

    test('should register InternetConnectionChecker', () async {
      await di.init();

      final checker = di.get<InternetConnectionChecker>();
      expect(checker, isA<InternetConnectionChecker>());
    });
  });

  group('Injection Container - Firebase Services', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should register Firebase Storage and Functions', () async {
      await di.init();

      // Test that Firebase services are registered
      // Note: We can't instantiate them in tests due to missing Firebase configuration
      expect(di.isRegistered<FirebaseStorage>(), isTrue);
      expect(di.isRegistered<FirebaseFunctions>(), isTrue);

      // The actual instances would be created lazily when needed in the app
    });
  });

  group('Injection Container - Core Services', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should register database and ensure single instance', () async {
      await di.init();

      final db = di.get<AppDatabase>();
      expect(db, isA<AppDatabase>());

      // Verify singleton behavior
      final db2 = di.get<AppDatabase>();
      expect(identical(db, db2), isTrue);
    });

    test('should register NetworkInfo with required dependencies', () async {
      await di.init();

      final networkInfo = di.get<NetworkInfo>();
      expect(networkInfo, isA<NetworkInfoImpl>());
    });

    test('should register file management services', () async {
      await di.init();

      final fileProvider = di.get<FileProvider>();
      expect(fileProvider, isA<FileProviderImpl>());

      final savePath = di.get<GetSavePath>();
      expect(savePath, isA<GetSavePath>());
    });

    test('should register email service', () async {
      await di.init();

      final emailService = di.get<EmailSenderService>();
      expect(emailService, isA<EmailSenderServiceImpl>());
    });

    test('should ensure singleton behavior for lazy singletons', () async {
      await di.init();

      // Test multiple services maintain singleton pattern
      final fileProvider1 = di.get<FileProvider>();
      final fileProvider2 = di.get<FileProvider>();
      expect(identical(fileProvider1, fileProvider2), isTrue);

      final emailService1 = di.get<EmailSenderService>();
      final emailService2 = di.get<EmailSenderService>();
      expect(identical(emailService1, emailService2), isTrue);

      final networkInfo1 = di.get<NetworkInfo>();
      final networkInfo2 = di.get<NetworkInfo>();
      expect(identical(networkInfo1, networkInfo2), isTrue);
    });
  });

  group('Injection Container - Export Services', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should register all export services', () async {
      await di.init();

      // Verify all export services are registered
      expect(di.isRegistered<ExcelExportService>(), isTrue);
      expect(di.isRegistered<PdfExportService>(), isTrue);
      expect(di.isRegistered<DocExportService>(), isTrue);
    });

    test('should register export factory and validator', () async {
      await di.init();

      // These don't depend on Firebase, so we can instantiate them
      final factory = di.get<ExportServiceFactoryBase>();
      final validator = di.get<AssessmentValidator>();

      expect(factory, isA<ExportServiceFactoryAdapter>());
      expect(validator, isA<DefaultAssessmentValidator>());
    });
  });

  group('Injection Container - Repository and Data Sources', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should register repository and data sources', () async {
      await di.init();

      // Test registration only, not instantiation
      // Repository and RemoteDataSource depend on Firebase which isn't available in tests
      expect(di.isRegistered<AssessmentRepository>(), isTrue);
      expect(di.isRegistered<AssessmentLocalDataSource>(), isTrue);
      expect(di.isRegistered<AssessmentRemoteDataSource>(), isTrue);

      // Local data source doesn't depend on Firebase, so we can instantiate it
      final localDataSource = di.get<AssessmentLocalDataSource>();
      expect(localDataSource, isNotNull);
    });
  });

  group('Injection Container - Use Cases', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should register all CRUD use cases', () async {
      await di.init();

      // Verify all CRUD use cases are registered
      // Note: Can't instantiate them as they depend on repository which depends on Firebase
      expect(di.isRegistered<CreateAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<GetAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<GetAllAssessmentsUsecase>(), isTrue);
      expect(di.isRegistered<SaveAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<UpdateAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<DeleteAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<DeleteAllAssessmentsUsecase>(), isTrue);
    });

    test('should register export use cases with dependencies', () async {
      await di.init();

      expect(di.isRegistered<ExportAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<GetExportStatistics>(), isTrue);
      expect(di.isRegistered<ValidateAssessmentForExport>(), isTrue);
    });

    test('should register import use cases with dependencies', () async {
      await di.init();

      expect(di.isRegistered<ImportAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<ImportAssessmentFromExcel>(), isTrue);
      expect(di.isRegistered<GetImportStatistics>(), isTrue);
    });

    test('should register Firebase-specific use cases', () async {
      await di.init();

      expect(
        di.isRegistered<SubmitAssessmentViaFirebaseEmailUsecase>(),
        isTrue,
      );
      expect(di.isRegistered<UploadAssessmentToFirebase>(), isTrue);
    });
  });

  group('Injection Container - BLoCs', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should register all BLoCs as factories', () async {
      await di.init();

      // Verify BLoCs are registered
      // Note: Can't instantiate them as they depend on use cases that depend on Firebase
      expect(di.isRegistered<AssessmentFormBloc>(), isTrue);
      expect(di.isRegistered<AssessmentListBloc>(), isTrue);
      expect(di.isRegistered<ImportAssessmentBloc>(), isTrue);
      expect(di.isRegistered<CompareAssessmentsBloc>(), isTrue);

      // In a real app, these would be created as new instances each time (factory pattern)
    });

    test('should register BLoCs with correct dependencies', () async {
      await di.init();

      // Verify that all required dependencies for BLoCs are registered
      // This ensures the dependency chain is complete
      expect(di.isRegistered<GetAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<SaveAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<ExportAssessmentUsecase>(), isTrue);
      expect(
        di.isRegistered<SubmitAssessmentViaFirebaseEmailUsecase>(),
        isTrue,
      );
      expect(di.isRegistered<GetExportStatistics>(), isTrue);
      expect(di.isRegistered<ValidateAssessmentForExport>(), isTrue);
      expect(di.isRegistered<GetAllAssessmentsUsecase>(), isTrue);
      expect(di.isRegistered<DeleteAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<ImportAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<ImportAssessmentFromExcel>(), isTrue);
      expect(di.isRegistered<GetImportStatistics>(), isTrue);
      expect(di.isRegistered<AssessmentRepository>(), isTrue);
    });
  });

  group('Injection Container - Utility Functions', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    test('should correctly check registration status', () async {
      expect(di.isRegistered<AppDatabase>(), isFalse);

      await di.init();

      expect(di.isRegistered<AppDatabase>(), isTrue);
      expect(di.isRegistered<NetworkInfo>(), isTrue);
      expect(di.isRegistered<String>(), isFalse); // Type not registered
    });

    test('should reset all registrations', () async {
      await di.init();

      expect(di.isRegistered<AppDatabase>(), isTrue);
      expect(di.isRegistered<NetworkInfo>(), isTrue);

      await di.reset();

      expect(di.isRegistered<AppDatabase>(), isFalse);
      expect(di.isRegistered<NetworkInfo>(), isFalse);
    });

    test('should throw when getting unregistered type', () async {
      await di.init();

      // This type is not registered
      expect(() => di.get<String>(), throwsA(isA<StateError>()));
    });
  });

  group('Injection Container - Dependency Chain', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should properly register complete dependency chain', () async {
      await di.init();

      // Verify the complete dependency chain is registered
      // Even though we can't instantiate Firebase-dependent services in tests,
      // we can verify all parts of the chain are registered

      // Data Layer
      expect(di.isRegistered<AssessmentLocalDataSource>(), isTrue);
      expect(di.isRegistered<AssessmentRemoteDataSource>(), isTrue);
      expect(di.isRegistered<AssessmentRepository>(), isTrue);

      // Domain Layer
      expect(di.isRegistered<CreateAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<GetAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<ExportAssessmentUsecase>(), isTrue);
      expect(di.isRegistered<ImportAssessmentUsecase>(), isTrue);

      // Presentation Layer
      expect(di.isRegistered<AssessmentFormBloc>(), isTrue);
      expect(di.isRegistered<ImportAssessmentBloc>(), isTrue);

      // Supporting Services
      expect(di.isRegistered<ExcelExportService>(), isTrue);
      expect(di.isRegistered<PdfExportService>(), isTrue);
      expect(di.isRegistered<DocExportService>(), isTrue);
    });

    test(
      'should register export services with file provider dependency',
      () async {
        await di.init();

        // Verify export services and their dependencies are registered
        expect(di.isRegistered<FileProvider>(), isTrue);
        expect(di.isRegistered<GetSavePath>(), isTrue);
        expect(di.isRegistered<ExcelExportService>(), isTrue);
        expect(di.isRegistered<PdfExportService>(), isTrue);
        expect(di.isRegistered<DocExportService>(), isTrue);

        // File provider doesn't depend on Firebase, so we can instantiate it
        final fileProvider = di.get<FileProvider>();
        expect(fileProvider, isA<FileProviderImpl>());
      },
    );
  });

  group('Injection Container - Factory Pattern Verification', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test('should verify factory vs singleton registration patterns', () async {
      await di.init();

      // Validators and factories should be singletons
      final validator1 = di.get<AssessmentValidator>();
      final validator2 = di.get<AssessmentValidator>();
      expect(
        identical(validator1, validator2),
        isTrue,
        reason: 'Validators should be singletons',
      );

      final factory1 = di.get<ExportServiceFactoryBase>();
      final factory2 = di.get<ExportServiceFactoryBase>();
      expect(
        identical(factory1, factory2),
        isTrue,
        reason: 'Factories should be singletons',
      );

      // File providers should be singletons
      final fileProvider1 = di.get<FileProvider>();
      final fileProvider2 = di.get<FileProvider>();
      expect(
        identical(fileProvider1, fileProvider2),
        isTrue,
        reason: 'FileProvider should be a singleton',
      );

      // Import factory should be singleton
      final importFactory1 = di.get<ImportServiceFactoryProtocol>();
      final importFactory2 = di.get<ImportServiceFactoryProtocol>();
      expect(
        identical(importFactory1, importFactory2),
        isTrue,
        reason: 'Import factory should be a singleton',
      );
    });
  });

  group('Injection Container - Error Handling', () {
    test('should handle multiple initialization attempts', () async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});

      await di.init();

      // Second init should throw because services are already registered
      expect(() async => await di.init(), throwsA(anything));
    });

    test('should provide meaningful error for missing dependencies', () async {
      await di.reset();

      // Try to get a service without initializing
      expect(() => di.get<AppDatabase>(), throwsA(isA<StateError>()));
    });

    test('should handle reset and re-initialization', () async {
      SharedPreferences.setMockInitialValues({});

      // First initialization
      await di.init();
      expect(di.isRegistered<AppDatabase>(), isTrue);

      // Reset
      await di.reset();
      expect(di.isRegistered<AppDatabase>(), isFalse);

      // Re-initialize
      await di.init();
      expect(di.isRegistered<AppDatabase>(), isTrue);
    });
  });

  group('Injection Container - Firebase conditional registration', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
      setupFirebaseCoreMocks(); // already at file top, but safe here too
    });

    tearDown(() async {
      await di.reset();
    });

    test('registers FirebaseFunctions when not pre-registered', () async {
      // Do NOT pre-register FirebaseFunctions or FirebaseStorage here
      await di.init();

      expect(di.isRegistered<FirebaseFunctions>(), isTrue);
      expect(di.isRegistered<FirebaseStorage>(), isTrue);
    });
  });

  group('Geolocation DI - datasource/repository', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test(
      'registers GeographicLocalDataSource and GeographicRepository',
      () async {
        await di.init();

        // registrations
        expect(di.isRegistered<GeographicLocalDataSource>(), isTrue);
        expect(di.isRegistered<GeographicRepository>(), isTrue);

        // instantiation + types
        final ds1 = di.get<GeographicLocalDataSource>();
        final ds2 = di.get<GeographicLocalDataSource>();
        expect(ds1, isA<GeographicLocalDataSourceImpl>());
        expect(identical(ds1, ds2), isTrue, reason: 'lazy singleton');

        final repo1 = di.get<GeographicRepository>();
        final repo2 = di.get<GeographicRepository>();
        expect(repo1, isA<GeographicRepositoryImpl>());
        expect(identical(repo1, repo2), isTrue, reason: 'lazy singleton');
      },
    );
  });

  group('Geolocation DI - use cases', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test(
      'registers geo use cases (regions, country codes, phone code)',
      () async {
        await di.init();

        expect(di.isRegistered<GetRegionsByCountry>(), isTrue);
        expect(di.isRegistered<GetCountryCodesUsecase>(), isTrue);
        expect(di.isRegistered<GetPhoneCodeByCountry>(), isTrue);

        final regions1 = di.get<GetRegionsByCountry>();
        final regions2 = di.get<GetRegionsByCountry>();
        expect(regions1, isA<GetRegionsByCountry>());
        expect(identical(regions1, regions2), isTrue);

        final codes1 = di.get<GetCountryCodesUsecase>();
        final codes2 = di.get<GetCountryCodesUsecase>();
        expect(codes1, isA<GetCountryCodesUsecase>());
        expect(identical(codes1, codes2), isTrue);

        final phoneCode1 = di.get<GetPhoneCodeByCountry>();
        final phoneCode2 = di.get<GetPhoneCodeByCountry>();
        expect(phoneCode1, isA<GetPhoneCodeByCountry>());
        expect(identical(phoneCode1, phoneCode2), isTrue);
      },
    );
  });

  group('Geolocation DI - BLoC factories', () {
    setUp(() async {
      await di.reset();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() async {
      await di.reset();
    });

    test(
      'registers PhoneInputBloc factory and creates new instances',
      () async {
        await di.init();

        expect(di.isRegistered<PhoneInputBloc>(), isTrue);

        final b1 = di.get<PhoneInputBloc>();
        final b2 = di.get<PhoneInputBloc>();
        expect(b1, isA<PhoneInputBloc>());
        expect(
          identical(b1, b2),
          isFalse,
          reason: 'factory must create new instances',
        );

        // sanity: its dependency is registered
        expect(di.isRegistered<GetCountryCodesUsecase>(), isTrue);
      },
    );

    test(
      'registers GeographicCascadeBloc factory and creates new instances',
      () async {
        await di.init();

        expect(di.isRegistered<GeographicCascadeBloc>(), isTrue);

        final g1 = di.get<GeographicCascadeBloc>();
        final g2 = di.get<GeographicCascadeBloc>();
        expect(g1, isA<GeographicCascadeBloc>());
        expect(
          identical(g1, g2),
          isFalse,
          reason: 'factory must create new instances',
        );

        // its use case deps should be registered
        expect(di.isRegistered<GetCountries>(), isTrue);
        expect(di.isRegistered<GetRegionsByCountry>(), isTrue);
        expect(di.isRegistered<GetCitiesByRegion>(), isTrue);
      },
    );
  });
}
