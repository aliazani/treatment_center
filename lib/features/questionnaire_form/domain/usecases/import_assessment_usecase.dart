import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/providers/file_provider.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/services/import_service.dart';

import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_item_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_section_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/repositories/assessment_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

abstract class ImportServiceFactoryProtocol {
  ImportService create(String format);
  bool isSupported(String format);
  List<String> getSupportedFormats();
  List<String> getMimeTypesForFormat(String format);
}

class ImportServiceFactoryAdapter implements ImportServiceFactoryProtocol {
  @override
  ImportService create(String format) =>
      ImportServiceFactory.createImportService(format);

  @override
  bool isSupported(String format) =>
      ImportServiceFactory.isFormatSupported(format);

  @override
  List<String> getSupportedFormats() =>
      ImportServiceFactory.getSupportedFormats();

  @override
  List<String> getMimeTypesForFormat(String format) =>
      ImportServiceFactory.getMimeTypesForFormat(format);
}

class GetImportStatistics
    implements UseCase<Map<String, dynamic>, GetImportStatisticsParams> {
  final ImportServiceFactoryProtocol factory;
  final FileProvider fileProvider;

  GetImportStatistics({
    ImportServiceFactoryProtocol? factory,
    FileProvider? fileProvider,
  }) : factory = factory ?? ImportServiceFactoryAdapter(),
       fileProvider = fileProvider ?? FileProviderImpl();

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetImportStatisticsParams params,
  ) async {
    try {
      if (params.importResult != null) {
        final importService = factory.create(params.format);
        return Right(importService.getImportStatistics(params.importResult!));
      }

      if (params.filePath != null) {
        factory.create(params.format);
        return Right(
          await _analyzeFileForImport(params.filePath!, params.format),
        );
      }

      return Right(_getFormatStatistics(params.format));
    } on ImportException catch (e) {
      return Left(ImportFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: 'Failed to get stats: $e'));
    }
  }

  Future<Map<String, dynamic>> _analyzeFileForImport(
    String filePath,
    String format,
  ) async {
    final bool sizeOk = await ImportValidator.isValidFileSize(
      filePath,
      fileProvider: fileProvider,
    );
    // On web we don’t have a usable path; just return “unknown” stats
    if (kIsWeb) {
      return {
        'formatName': format,
        'filePath': '<web-picked-file>',
        'fileExists': true,
        'fileSizeMB': 'unknown',
        'isValidFormat': ImportValidator.isValidFileFormat(filePath, [format]),
        'isValidSize': true,
        'canImport': true,
        'analyzedAt': DateTime.now().toIso8601String(),
      };
    }

    // ── Desktop / mobile branch ───────────────────────────────────────
    final file = await fileProvider.getFile(filePath);
    final exists = await file.exists();
    final size = exists ? await file.length() : 0;

    return {
      'formatName': format,
      'filePath': filePath,
      'fileExists': exists,
      'fileSizeBytes': size,
      'fileSizeMB': size / (1024 * 1024),
      'isValidFormat': ImportValidator.isValidFileFormat(filePath, [format]),
      'isValidSize': sizeOk,
      'canImport':
          exists &&
          ImportValidator.isValidFileFormat(filePath, [format]) &&
          sizeOk,
      'analyzedAt': DateTime.now().toIso8601String(),
    };
  }

  Map<String, dynamic> _getFormatStatistics(String format) => {
    'formatName': format,
    'isSupported': factory.isSupported(format),
    'supportedFormats': factory.getSupportedFormats(),
    'mimeTypes': factory.getMimeTypesForFormat(format),
    'maxFileSize': '100MB',
    'features': _getFormatFeatures(format),
  };

  Map<String, dynamic> _getFormatFeatures(String format) {
    switch (format.toLowerCase()) {
      case 'xlsx':
        return {
          'multipleSheets': true,
          'formattedData': true,
          'cellComments': true,
          'formulas': false,
          'charts': false,
          'sectionDetails': true,
          'analysisData': true,
          'colorCoding': true,
          'ratingMapping': true,
        };
      default:
        return {};
    }
  }
}

class ImportAssessmentUsecase
    implements UseCase<AssessmentFormEntity, ImportAssessmentParams> {
  final AssessmentRepository repository;
  final ImportServiceFactoryProtocol factory;

  ImportAssessmentUsecase(
    this.repository, {
    ImportServiceFactoryProtocol? factory,
  }) : factory = factory ?? ImportServiceFactoryAdapter();

  @override
  Future<Either<Failure, AssessmentFormEntity>> call(
    ImportAssessmentParams params,
  ) async {
    try {
      _validate(params);
      final service = factory.create(params.format);
      final result = await service.importAssessment(
        params.filePath,
        options: params.options,
      );
      final entity = result.assessment;

      if (params.saveAfterImport) {
        final saved = await repository.saveAssessment(entity);
        return saved.fold(
          (f) => Left(f),
          (ok) =>
              ok
                  ? Right(entity)
                  : Left(
                    UnexpectedFailure(message: 'Failed to save assessment'),
                  ),
        );
      }
      return Right(entity);
    } on ImportException catch (e) {
      return Left(ImportFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  void _validate(ImportAssessmentParams p) {
    if (p.filePath.isEmpty) {
      throw ValidationException(message: 'File path cannot be empty');
    }
    if (p.format.isEmpty) {
      throw ValidationException(message: 'Import format must be specified');
    }
    if (!factory.isSupported(p.format)) {
      throw ValidationException(
        message:
            'Unsupported format: ${p.format}. '
            'Supported: ${factory.getSupportedFormats().join(', ')}',
      );
    }
  }
}

class ImportAssessmentFromExcel
    implements UseCase<AssessmentFormEntity, ImportAssessmentFromExcelParams> {
  final AssessmentRepository repository;
  final ImportServiceFactoryProtocol factory;
  final FileProvider fileProvider;

  ImportAssessmentFromExcel(
    this.repository, {
    ImportServiceFactoryProtocol? factory,
    FileProvider? fileProvider,
  }) : factory = factory ?? ImportServiceFactoryAdapter(),
       fileProvider = fileProvider ?? FileProviderImpl();

  @override
  Future<Either<Failure, AssessmentFormEntity>> call(
    ImportAssessmentFromExcelParams params,
  ) async {
    try {
      await _validateForExcel(params);

      final service = factory.create('xlsx');
      final result = await service.importAssessment(
        params.filePath,
        options: ImportOptions(
          importSectionDetails: params.importSectionDetails,
          validateAfterImport: params.validateAfterImport,
          preserveExistingData: params.preserveExistingData,
        ),
      );

      AssessmentFormEntity entity = result.assessment;

      if (params.existingAssessmentId != null && params.mergeWithExisting) {
        entity = await _merge(entity, params.existingAssessmentId!);
      }

      if (params.saveAfterImport) {
        final saved = await repository.saveAssessment(entity);
        return saved.fold(
          (f) => Left(f),
          (ok) =>
              ok
                  ? Right(entity)
                  : Left(
                    UnexpectedFailure(message: 'Failed to save assessment'),
                  ),
        );
      }
      return Right(entity);
    } on ExcelImportException catch (e) {
      return Left(ImportFailure(message: e.message));
    } on ImportException catch (e) {
      return Left(ImportFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on FileException catch (e) {
      return Left(FileOperationFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  Future<void> _validateForExcel(ImportAssessmentFromExcelParams p) async {
    final lower = p.filePath.toLowerCase();
    if (!lower.endsWith('.xlsx')) {
      throw ValidationException(message: 'File must be .xlsx');
    }

    final f = await fileProvider.getFile(p.filePath);
    final bool exists = await f.exists(); // async – works on web

    if (exists) {
      final sizeMB = await f.length() / (1024 * 1024);
      if (sizeMB > 50) {
        throw ValidationException(
          message: 'Excel file too large (${sizeMB.toStringAsFixed(1)} MB)',
        );
      }
    }
  }

  Future<AssessmentFormEntity> _merge(
    AssessmentFormEntity imported,
    String existingId,
  ) async {
    final either = await repository.getAssessment(existingId);
    return either.fold(
      (_) => imported, // If existing not found, return imported as-is
      (existing) => existing.copyWith(
        assessorInfo: imported.assessorInfo,
        geoLocation: imported.geoLocation,
        facilityIdentification: imported.facilityIdentification,
        facilityServices: imported.facilityServices,
        sections: _mergeSections(existing.sections, imported.sections),
      ),
    );
  }

  List<AssessmentSectionEntity> _mergeSections(
    List<AssessmentSectionEntity> existing,
    List<AssessmentSectionEntity> imported,
  ) {
    final map = {for (var e in existing) e.sectionNumber: e};
    for (var imp in imported) {
      final orig = map[imp.sectionNumber];
      if (orig != null) {
        map[imp.sectionNumber] = orig.copyWith(
          title: imp.title.isNotEmpty ? imp.title : orig.title,
          description:
              (imp.description?.isNotEmpty ?? false)
                  ? imp.description
                  : orig.description,
          items: _mergeItems(orig.items, imp.items),
        );
      } else {
        map[imp.sectionNumber] = imp;
      }
    }
    return map.values.toList()
      ..sort((a, b) => a.sectionNumber.compareTo(b.sectionNumber));
  }

  List<AssessmentItemEntity> _mergeItems(
    List<AssessmentItemEntity> existing,
    List<AssessmentItemEntity> imported,
  ) {
    final map = {for (var i in existing) i.itemNumber: i};
    for (var imp in imported) {
      final orig = map[imp.itemNumber];
      if (orig != null) {
        map[imp.itemNumber] = orig.copyWith(
          area: imp.area.isNotEmpty ? imp.area : orig.area,
          meetsTargetDescription:
              imp.meetsTargetDescription.isNotEmpty
                  ? imp.meetsTargetDescription
                  : orig.meetsTargetDescription,
          partiallyMeetsDescription:
              imp.partiallyMeetsDescription.isNotEmpty
                  ? imp.partiallyMeetsDescription
                  : orig.partiallyMeetsDescription,
          doesNotMeetDescription:
              imp.doesNotMeetDescription.isNotEmpty
                  ? imp.doesNotMeetDescription
                  : orig.doesNotMeetDescription,
          selectedRating: imp.selectedRating ?? orig.selectedRating,
          comment:
              (imp.comment?.isNotEmpty ?? false) ? imp.comment : orig.comment,
        );
      } else {
        map[imp.itemNumber] = imp;
      }
    }
    return map.values.toList()
      ..sort((a, b) => a.itemNumber.compareTo(b.itemNumber));
  }
}

class GetImportStatisticsParams extends Equatable {
  final String format;
  final String? filePath;
  final ImportedAssessmentForm? importResult;

  const GetImportStatisticsParams({
    required this.format,
    this.filePath,
    this.importResult,
  });

  factory GetImportStatisticsParams.fromFile({
    required String format,
    required String filePath,
  }) => GetImportStatisticsParams(format: format, filePath: filePath);

  factory GetImportStatisticsParams.fromResult(
    ImportedAssessmentForm importResult,
  ) => GetImportStatisticsParams(
    format: importResult.format,
    importResult: importResult,
  );

  @override
  List<Object?> get props => [format, filePath, importResult];
}

class ImportAssessmentParams extends Equatable {
  final String filePath;
  final String format;
  final ImportOptions? options;
  final bool saveAfterImport;

  const ImportAssessmentParams({
    required this.filePath,
    required this.format,
    this.options,
    this.saveAfterImport = false,
  });

  factory ImportAssessmentParams.excel({
    required String filePath,
    bool importSectionDetails = true,
    bool saveAfterImport = false,
  }) => ImportAssessmentParams(
    filePath: filePath,
    format: 'xlsx',
    options: ImportOptions(importSectionDetails: importSectionDetails),
    saveAfterImport: saveAfterImport,
  );

  @override
  List<Object?> get props => [filePath, format, options, saveAfterImport];
}

class ImportAssessmentFromExcelParams extends Equatable {
  final String filePath;
  final bool importSectionDetails;
  final bool validateAfterImport;
  final bool preserveExistingData;
  final bool saveAfterImport;
  final String? existingAssessmentId;
  final bool mergeWithExisting;

  const ImportAssessmentFromExcelParams({
    required this.filePath,
    this.importSectionDetails = true,
    this.validateAfterImport = true,
    this.preserveExistingData = false,
    this.saveAfterImport = false,
    this.existingAssessmentId,
    this.mergeWithExisting = false,
  });

  @override
  List<Object?> get props => [
    filePath,
    importSectionDetails,
    validateAfterImport,
    preserveExistingData,
    saveAfterImport,
    existingAssessmentId,
    mergeWithExisting,
  ];
}
