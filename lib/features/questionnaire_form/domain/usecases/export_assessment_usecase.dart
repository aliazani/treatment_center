import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/core/services/export_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

/// Factory for obtaining an [ExportService] without using the static
/// `ExportServiceFactory.*` helpers directly.
abstract interface class ExportServiceFactoryBase {
  bool isFormatSupported(String format);
  List<String> getSupportedFormats();
  Map<String, String> getFormatInfo(String format);
  ExportService createExportService(String format);
}

/// Default implementation that simply forwards to the original
/// `ExportServiceFactory` static class.
class ExportServiceFactoryAdapter implements ExportServiceFactoryBase {
  const ExportServiceFactoryAdapter();

  @override
  bool isFormatSupported(String format) =>
      ExportServiceFactory.isFormatSupported(format);

  @override
  List<String> getSupportedFormats() =>
      ExportServiceFactory.getSupportedFormats();

  @override
  Map<String, String> getFormatInfo(String format) =>
      ExportServiceFactory.getFormatInfo(format);

  @override
  ExportService createExportService(String format) =>
      ExportServiceFactory.createExportService(format);
}

/// Extracted validation strategy.  Swap with a mock in tests.
abstract interface class AssessmentValidator {
  void validateCommon(AssessmentFormEntity form);
  void validateExcel(AssessmentFormEntity form);
  void validatePdf(AssessmentFormEntity form);
  void validateDoc(AssessmentFormEntity form);
}

/// Production validator reproducing the original rules.
class DefaultAssessmentValidator implements AssessmentValidator {
  const DefaultAssessmentValidator();

  @override
  void validateCommon(AssessmentFormEntity form) {
    if (form.facilityIdentification.facilityName.isEmpty) {
      throw const ValidationException(
        message: 'Assessment must have a facility name before export',
      );
    }
    if (form.facilityIdentification.facilityCode.isEmpty) {
      throw const ValidationException(
        message: 'Assessment must have a facility code before export',
      );
    }
    if (form.assessorInfo.name.isEmpty) {
      throw const ValidationException(
        message: 'Assessment must have an assessor name before export',
      );
    }
    if (form.sections.isEmpty) {
      throw const ValidationException(
        message: 'Assessment must have at least one section before export',
      );
    }
  }

  @override
  void validateExcel(AssessmentFormEntity form) {
    validateCommon(form);
    final totalItems = form.sections.fold<int>(
      0,
      (sum, s) => sum + s.items.length,
    );

    if (totalItems == 0) {
      throw const ValidationException(
        message: 'Cannot export to Excel: Assessment has no items',
      );
    }
  }

  @override
  void validatePdf(AssessmentFormEntity form) => validateCommon(form);

  @override
  void validateDoc(AssessmentFormEntity form) => validateCommon(form);
}

/// Deterministic time source (useful for testing `ExportResult.createdAt`).
typedef Clock = DateTime Function();

/// ------------------------------------------------------------------
/// 2. Private helper that maps the common try/catch boiler-plate
/// ------------------------------------------------------------------

Future<Either<Failure, R>> _protect<R>({
  required Future<R> Function() exec,
}) async {
  try {
    return Right(await exec());
  } on ExportException catch (e) {
    return Left(ExportFailure(message: e.message));
  } on ValidationException catch (e) {
    return Left(ValidationFailure(message: e.message));
  } on FileException catch (e) {
    return Left(FileOperationFailure(message: e.message));
  } catch (e) {
    return Left(UnexpectedFailure(message: 'An unexpected error occurred: $e'));
  }
}

/// ------------------------------------------------------------------
/// 3. Export-related use-cases
/// ------------------------------------------------------------------

class ExportAssessmentUsecase
    implements UseCase<ExportResult, ExportAssessmentParams> {
  final ExportServiceFactoryBase factory;
  final AssessmentValidator validator;
  final Clock clock;

  const ExportAssessmentUsecase({
    this.factory = const ExportServiceFactoryAdapter(),
    this.validator = const DefaultAssessmentValidator(),
    this.clock = DateTime.now,
  });

  @override
  Future<Either<Failure, ExportResult>> call(ExportAssessmentParams p) async {
    // 1) Supported format?
    if (!factory.isFormatSupported(p.format)) {
      return Left(
        ValidationFailure(
          message:
              'Unsupported export format: ${p.format}. Supported formats: '
              '${factory.getSupportedFormats().join(', ')}',
        ),
      );
    }

    // 2) Domain validation
    validator.validateCommon(p.assessment);

    // 3) Real work with shared exception mapping
    return _protect(
      exec: () async {
        final service = factory.createExportService(p.format);
        return service.exportAssessment(
          AssessmentFormModel.fromEntity(p.assessment),
          outputPath: p.outputPath,
          options: p.options,
        );
      },
    );
  }
}

// ------------------------------------------------------------------
// Excel
// ------------------------------------------------------------------
class ExportAssessmentToExcel
    implements UseCase<ExportResult, ExportAssessmentToExcelParams> {
  final ExportServiceFactoryBase factory;
  final AssessmentValidator validator;

  const ExportAssessmentToExcel({
    this.factory = const ExportServiceFactoryAdapter(),
    this.validator = const DefaultAssessmentValidator(),
  });

  @override
  Future<Either<Failure, ExportResult>> call(
    ExportAssessmentToExcelParams p,
  ) async {
    validator.validateExcel(p.assessment);

    return _protect(
      exec: () async {
        final svc = factory.createExportService('excel');
        final result = await svc.exportAssessment(
          AssessmentFormModel.fromEntity(p.assessment),
          outputPath: p.outputPath,
          options: ExportOptions(
            includeAnalysis: p.includeAnalysis,
            includeSectionDetails: p.includeSectionDetails,
            includeSignaturePage: false,
          ),
        );
        return result;
      },
    );
  }
}

// ------------------------------------------------------------------
// PDF
// ------------------------------------------------------------------
class ExportAssessmentToPdf
    implements UseCase<ExportResult, ExportAssessmentToPdfParams> {
  final ExportServiceFactoryBase factory;
  final AssessmentValidator validator;

  const ExportAssessmentToPdf({
    this.factory = const ExportServiceFactoryAdapter(),
    this.validator = const DefaultAssessmentValidator(),
  });

  @override
  Future<Either<Failure, ExportResult>> call(
    ExportAssessmentToPdfParams p,
  ) async {
    validator.validatePdf(p.assessment);

    return _protect(
      exec: () async {
        final svc = factory.createExportService('pdf');
        return svc.exportAssessment(
          AssessmentFormModel.fromEntity(p.assessment),
          outputPath: p.outputPath,
          options: ExportOptions(
            includeAnalysis: p.includeAnalysis,
            includeSectionDetails: p.includeDetailedSections,
            includeSignaturePage: p.includeSignaturePage,
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------
// DOCX
// ------------------------------------------------------------------
class ExportAssessmentToDoc
    implements UseCase<ExportResult, ExportAssessmentToDocParams> {
  final ExportServiceFactoryBase factory;
  final AssessmentValidator validator;

  const ExportAssessmentToDoc({
    this.factory = const ExportServiceFactoryAdapter(),
    this.validator = const DefaultAssessmentValidator(),
  });

  @override
  Future<Either<Failure, ExportResult>> call(
    ExportAssessmentToDocParams p,
  ) async {
    validator.validateDoc(p.assessment);

    return _protect(
      exec: () async {
        final svc = factory.createExportService('docx');
        return svc.exportAssessment(
          AssessmentFormModel.fromEntity(p.assessment),
          outputPath: p.outputPath,
          options: ExportOptions(
            includeAnalysis: p.includeAnalysis,
            includeSectionDetails: p.includeSectionDetails,
            includeSignaturePage: p.includeSignaturePage,
            customTemplate: p.customTemplate,
          ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------
// Statistics
// ------------------------------------------------------------------
class GetExportStatistics
    implements UseCase<Map<String, dynamic>, GetExportStatisticsParams> {
  final ExportServiceFactoryBase factory;
  final AssessmentValidator validator;

  const GetExportStatistics({
    this.factory = const ExportServiceFactoryAdapter(),
    this.validator = const DefaultAssessmentValidator(),
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetExportStatisticsParams p,
  ) async {
    if (!factory.isFormatSupported(p.format)) {
      return Left(
        ValidationFailure(
          message:
              'Unsupported export format: ${p.format}. Supported formats: '
              '${factory.getSupportedFormats().join(', ')}',
        ),
      );
    }

    validator.validateCommon(p.assessment);

    return _protect(
      exec: () async {
        final svc = factory.createExportService(p.format);
        final stats = svc.getExportStatistics(
          AssessmentFormModel.fromEntity(p.assessment),
        );
        stats.addAll(factory.getFormatInfo(p.format));
        return stats;
      },
    );
  }
}

// ------------------------------------------------------------------
// Validate-only
// ------------------------------------------------------------------
class ValidateAssessmentForExport
    implements UseCase<bool, ValidateAssessmentForExportParams> {
  final ExportServiceFactoryBase factory;
  final AssessmentValidator validator;

  const ValidateAssessmentForExport({
    this.factory = const ExportServiceFactoryAdapter(),
    this.validator = const DefaultAssessmentValidator(),
  });

  @override
  Future<Either<Failure, bool>> call(
    ValidateAssessmentForExportParams p,
  ) async {
    if (!factory.isFormatSupported(p.format)) {
      return Left(
        ValidationFailure(message: 'Unsupported export format: ${p.format}'),
      );
    }

    validator.validateCommon(p.assessment);

    return _protect(
      exec: () async {
        final svc = factory.createExportService(p.format);
        svc.validateForExport(AssessmentFormModel.fromEntity(p.assessment));
        return true;
      },
    );
  }
}

/// ------------------------------------------------------------------
/// 4. Parameter value objects  (mostly unchanged)
/// ------------------------------------------------------------------

class ExportAssessmentParams extends Equatable {
  final AssessmentFormEntity assessment;
  final String format;
  final String? outputPath;
  final ExportOptions? options;

  const ExportAssessmentParams({
    required this.assessment,
    required this.format,
    this.outputPath,
    this.options,
  });

  @override
  List<Object?> get props => [assessment, format, outputPath, options];

  // convenience helpers
  factory ExportAssessmentParams.withDefaults({
    required AssessmentFormEntity assessment,
    required String format,
    String? outputPath,
    bool includeAnalysis = true,
    bool includeSectionDetails = true,
    bool includeSignaturePage = true,
    String? customTemplate,
    Map<String, dynamic>? additionalOptions,
  }) => ExportAssessmentParams(
    assessment: assessment,
    format: format,
    outputPath: outputPath,
    options: ExportOptions(
      includeAnalysis: includeAnalysis,
      includeSectionDetails: includeSectionDetails,
      includeSignaturePage: includeSignaturePage,
      customTemplate: customTemplate,
      additionalOptions: additionalOptions,
    ),
  );

  factory ExportAssessmentParams.pdf({
    required AssessmentFormEntity assessment,
    String? outputPath,
    bool includeAnalysis = true,
    bool includeSectionDetails = true,
    bool includeSignaturePage = true,
  }) => ExportAssessmentParams.withDefaults(
    assessment: assessment,
    format: 'pdf',
    outputPath: outputPath,
    includeAnalysis: includeAnalysis,
    includeSectionDetails: includeSectionDetails,
    includeSignaturePage: includeSignaturePage,
  );

  factory ExportAssessmentParams.excel({
    required AssessmentFormEntity assessment,
    String? outputPath,
    bool includeAnalysis = true,
    bool includeSectionDetails = true,
  }) => ExportAssessmentParams.withDefaults(
    assessment: assessment,
    format: 'xlsx',
    outputPath: outputPath,
    includeAnalysis: includeAnalysis,
    includeSectionDetails: includeSectionDetails,
    includeSignaturePage: false,
  );

  factory ExportAssessmentParams.doc({
    required AssessmentFormEntity assessment,
    String? outputPath,
    bool includeAnalysis = true,
    bool includeSectionDetails = true,
    bool includeSignaturePage = true,
  }) => ExportAssessmentParams.withDefaults(
    assessment: assessment,
    format: 'docx',
    outputPath: outputPath,
    includeAnalysis: includeAnalysis,
    includeSectionDetails: includeSectionDetails,
    includeSignaturePage: includeSignaturePage,
  );
}

class ExportAssessmentToExcelParams extends Equatable {
  final AssessmentFormEntity assessment;
  final String? outputPath;
  final bool includeAnalysis;
  final bool includeSectionDetails;

  const ExportAssessmentToExcelParams({
    required this.assessment,
    this.outputPath,
    this.includeAnalysis = true,
    this.includeSectionDetails = true,
  });

  @override
  List<Object?> get props => [
    assessment,
    outputPath,
    includeAnalysis,
    includeSectionDetails,
  ];
}

class ExportAssessmentToPdfParams extends Equatable {
  final AssessmentFormEntity assessment;
  final String? outputPath;
  final bool includeAnalysis;
  final bool includeDetailedSections;
  final bool includeSignaturePage;

  const ExportAssessmentToPdfParams({
    required this.assessment,
    this.outputPath,
    this.includeAnalysis = true,
    this.includeDetailedSections = true,
    this.includeSignaturePage = true,
  });

  @override
  List<Object?> get props => [
    assessment,
    outputPath,
    includeAnalysis,
    includeDetailedSections,
    includeSignaturePage,
  ];
}

class ExportAssessmentToDocParams extends Equatable {
  final AssessmentFormEntity assessment;
  final String? outputPath;
  final bool includeAnalysis;
  final bool includeSectionDetails;
  final bool includeSignaturePage;
  final String? customTemplate;

  const ExportAssessmentToDocParams({
    required this.assessment,
    this.outputPath,
    this.includeAnalysis = true,
    this.includeSectionDetails = true,
    this.includeSignaturePage = true,
    this.customTemplate,
  });

  @override
  List<Object?> get props => [
    assessment,
    outputPath,
    includeAnalysis,
    includeSectionDetails,
    includeSignaturePage,
    customTemplate,
  ];
}

class GetExportStatisticsParams extends Equatable {
  final AssessmentFormEntity assessment;
  final String format;

  const GetExportStatisticsParams({
    required this.assessment,
    required this.format,
  });

  @override
  List<Object?> get props => [assessment, format];
}

class ValidateAssessmentForExportParams extends Equatable {
  final AssessmentFormEntity assessment;
  final String format;

  const ValidateAssessmentForExportParams({
    required this.assessment,
    required this.format,
  });

  @override
  List<Object?> get props => [assessment, format];
}
