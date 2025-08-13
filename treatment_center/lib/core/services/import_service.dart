import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/file_provider_interface.dart';
import 'package:treatment_center/core/services/excel_import_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';
import 'package:treatment_center/injection_container.dart';

/// Result of an import operation
class ImportedAssessmentForm extends Equatable {
  final AssessmentFormModel assessment;
  final String filePath;
  final String format;
  final DateTime importedAt;
  final Map<String, dynamic>? metadata;

  const ImportedAssessmentForm({
    required this.assessment,
    required this.filePath,
    required this.format,
    required this.importedAt,
    this.metadata,
  });

  @override
  List<Object?> get props => [
    assessment,
    filePath,
    format,
    importedAt,
    metadata,
  ];
}

/// Options for import operations
class ImportOptions extends Equatable {
  final bool importSectionDetails;
  final bool validateAfterImport;
  final bool preserveExistingData;
  final Map<String, dynamic>? customMappings;

  const ImportOptions({
    this.importSectionDetails = true,
    this.validateAfterImport = true,
    this.preserveExistingData = false,
    this.customMappings,
  });

  @override
  List<Object?> get props => [
    importSectionDetails,
    validateAfterImport,
    preserveExistingData,
    customMappings,
  ];
}

abstract class ImportService {
  String get supportedExtension;

  String get formatName;

  List<String> get supportedMimeTypes;

  Future<ImportedAssessmentForm> importFromBytes(
    Uint8List bytes, {
    String? originalName,
    ImportOptions? options,
  });

  Future<ImportedAssessmentForm> importAssessment(
    String filePath, {
    ImportOptions? options,
  });

  /// Validates that the file can be imported in this format
  /// Throws [ValidationException] if validation fails
  Future<void> validateFileForImport(String filePath);

  /// Gets import statistics for the result
  Map<String, dynamic> getImportStatistics(ImportedAssessmentForm result);
}

abstract class BaseImportService implements ImportService {
  final FileProvider fileProvider;
  BaseImportService({required this.fileProvider});

  @override
  Future<void> validateFileForImport(String filePath) async {
    final file = await fileProvider.getFile(filePath);
    if (!await file.exists()) {
      throw FileException(message: 'Import file does not exist: $filePath');
    }

    final size = await file.length();
    if (size > 50 * 1024 * 1024) {
      throw ValidationException(
        message:
            'Excel file too large (${(size / 1024 / 1024).toStringAsFixed(1)} MB). Maximum: 50 MB',
      );
    }

    if (size == 0) {
      throw ValidationException(message: 'Import file is empty');
    }

    // Check file extension
    final extension = filePath.split('.').last.toLowerCase();
    if (extension != supportedExtension.toLowerCase()) {
      throw ValidationException(
        message:
            'Unsupported file format. Expected: $supportedExtension, Got: $extension',
      );
    }

    // Call format-specific validation
    validateFormatSpecific(filePath);
  }

  /// Format-specific validation (override in implementations)
  void validateFormatSpecific(String filePath) {
    // Default implementation - override in subclasses
  }

  /// Common method to validate imported assessment
  Future<void> validateImportedAssessment(
    AssessmentFormModel assessment,
  ) async {
    // Call format-specific validation
    validateImportedAssessmentSpecific(assessment);
  }

  /// Format-specific assessment validation (override in implementations)
  void validateImportedAssessmentSpecific(AssessmentFormModel assessment) {
    // Default implementation - override in subclasses
  }

  /// Get default import statistics
  @override
  Map<String, dynamic> getImportStatistics(ImportedAssessmentForm result) {
    final assessment = result.assessment;
    final totalItems = assessment.totalItems;

    final completedItems = assessment.completedItems;

    return {
      'formatName': formatName,
      'importedAt': result.importedAt.toIso8601String(),
      'filePath': result.filePath,
      'totalSections': assessment.sections.length,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'completionRate':
          totalItems > 0 ? (completedItems / totalItems) * 100 : 0.0,
      'isValid': _isValidAssessment(assessment),
      'metadata': result.metadata,
    };
  }

  /// Check if assessment is valid
  bool _isValidAssessment(AssessmentFormModel assessment) {
    return assessment.facilityIdentification.facilityName.isNotEmpty &&
        assessment.facilityIdentification.facilityCode.isNotEmpty &&
        assessment.assessorInfo.name.isNotEmpty &&
        assessment.sections.isNotEmpty;
  }
}

/// Factory for creating import services
class ImportServiceFactory {
  static const List<String> _supportedFormats = ['xlsx'];

  /// Create import service for specified format
  static ImportService createImportService(String format) {
    final normalizedFormat = format.toLowerCase().replaceAll('.', '');

    switch (normalizedFormat) {
      case 'xlsx':
        return ExcelImportService(fileProvider: sl<FileProvider>());
      default:
        throw ValidationException(
          message:
              'Unsupported import format: $format. '
              'Supported formats: ${_supportedFormats.join(', ')}',
        );
    }
  }

  /// Get list of supported import formats
  static List<String> getSupportedFormats() =>
      List.unmodifiable(_supportedFormats);

  /// Check if format is supported
  static bool isFormatSupported(String format) {
    final normalizedFormat = format.toLowerCase().replaceAll('.', '');
    return _supportedFormats.contains(normalizedFormat);
  }

  /// Get MIME types for format
  static List<String> getMimeTypesForFormat(String format) {
    final normalizedFormat = format.toLowerCase().replaceAll('.', '');

    switch (normalizedFormat) {
      // case 'excel':
      case 'xlsx':
        return [
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'application/vnd.ms-excel',
        ];
      default:
        return [];
    }
  }
}

/// Import validation helper
class ImportValidator {
  /// Validate file format by extension
  static bool isValidFileFormat(
    String filePath,
    List<String> supportedExtensions,
  ) {
    final extension = filePath.split('.').last.toLowerCase();
    return supportedExtensions.any((ext) => ext.toLowerCase() == extension);
  }

  static Future<bool> isValidFileSize(
    String filePath, {
    int maxSizeBytes = 50 * 1024 * 1024,
    required FileProvider fileProvider,
  }) async {
    try {
      final f = await fileProvider.getFile(filePath);
      if (!await f.exists()) return false;

      final size = await f.length();
      return size <= maxSizeBytes && size > 0;
    } catch (_) {
      return false;
    }
  }

  /// Validate MIME type
  static bool isValidMimeType(String mimeType, List<String> supportedTypes) {
    return supportedTypes.any(
      (type) => type.toLowerCase() == mimeType.toLowerCase(),
    );
  }

  /// Get file extension
  static String getFileExtension(String filePath) {
    return filePath.split('.').last.toLowerCase();
  }
}
