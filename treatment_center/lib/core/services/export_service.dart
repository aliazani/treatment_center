import 'dart:typed_data';

import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/providers/file_provider.dart';
import 'package:treatment_center/core/services/doc_export_service.dart';
import 'package:treatment_center/core/services/excel_export_service.dart';
import 'package:treatment_center/core/services/pdf_export_service.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/assessment_form_model.dart';

import '../providers/file_provider_interface.dart';

class ExportResult {
  final String filePath;
  final String fileName;
  final String format;
  final int fileSizeBytes;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  // new
  final Uint8List? bytes;

  const ExportResult({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.fileSizeBytes,
    required this.createdAt,
    this.metadata,
    // new
    this.bytes, // Add this
  });

  String get fileSizeFormatted {
    if (fileSizeBytes < 1024) {
      return '$fileSizeBytes B';
    } else if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // new
  bool get hasBytes => bytes != null;

  @override
  String toString() {
    return 'ExportResult(fileName: $fileName, format: $format, size: $fileSizeFormatted)';
  }

  // new
  // Copy method for updating
  ExportResult copyWith({
    String? filePath,
    String? fileName,
    String? format,
    int? fileSizeBytes,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    Uint8List? bytes,
  }) {
    return ExportResult(
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      format: format ?? this.format,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
      bytes: bytes ?? this.bytes,
    );
  }
}

class ExportOptions {
  final bool includeAnalysis;
  final bool includeSectionDetails;
  final bool includeSignaturePage;
  final String? customTemplate;
  final Map<String, dynamic>? additionalOptions;

  const ExportOptions({
    this.includeAnalysis = true,
    this.includeSectionDetails = true,
    this.includeSignaturePage = true,
    this.customTemplate,
    this.additionalOptions,
  });

  Map<String, dynamic> toMap() {
    return {
      'includeAnalysis': includeAnalysis,
      'includeSectionDetails': includeSectionDetails,
      'includeSignaturePage': includeSignaturePage,
      'customTemplate': customTemplate,
      'additionalOptions': additionalOptions,
    };
  }

  factory ExportOptions.fromMap(Map<String, dynamic> map) {
    return ExportOptions(
      includeAnalysis: map['includeAnalysis'] ?? true,
      includeSectionDetails: map['includeSectionDetails'] ?? true,
      includeSignaturePage: map['includeSignaturePage'] ?? true,
      customTemplate: map['customTemplate'],
      additionalOptions: map['additionalOptions'],
    );
  }

  ExportOptions copyWith({
    bool? includeAnalysis,
    bool? includeSectionDetails,
    bool? includeSignaturePage,
    String? customTemplate,
    Map<String, dynamic>? additionalOptions,
  }) {
    return ExportOptions(
      includeSectionDetails:
          includeSectionDetails ?? this.includeSectionDetails,
      includeAnalysis: includeAnalysis ?? this.includeAnalysis,
      customTemplate: customTemplate ?? this.customTemplate,
      includeSignaturePage: includeSignaturePage ?? this.includeSignaturePage,
      additionalOptions: additionalOptions ?? this.additionalOptions,
    );
  }
}

abstract class ExportService {
  String get fileExtension;

  String get formatName;

  String get mimeType;

  /// Exports the assessment to the specified format
  /// Returns [ExportResult] with file information
  /// Throws [ExportException] if export fails
  Future<ExportResult> exportAssessment(
    AssessmentFormModel assessment, {
    String? outputPath,
    ExportOptions? options,
  });

  /// Validates that the assessment can be exported in this format
  /// Throws [ValidationException] if validation fails
  void validateForExport(AssessmentFormModel assessment);

  /// Gets the default filename for this export format
  String getDefaultFileName(AssessmentFormModel assessment) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final facilityCode = assessment.facilityIdentification.facilityCode;
    return 'FVD_Assessment_${facilityCode}_$timestamp.$fileExtension';
  }

  /// Gets export statistics for the assessment
  Map<String, dynamic> getExportStatistics(AssessmentFormModel assessment) {
    final totalItems = assessment.totalItems;
    final completedItems = assessment.completedItems;

    return {
      'totalSections': assessment.sections.length,
      'totalItems': totalItems,
      'completedItems': completedItems,
      'completionRate': assessment.completionPercentage,
      'isSubmitted': assessment.isSubmitted,
      'canExport':
          totalItems > 0 &&
          assessment.facilityIdentification.facilityName.isNotEmpty,
      'formatName': formatName,
      'fileExtension': fileExtension,
    };
  }
}

abstract class BaseExportService extends ExportService {
  /// Common validation that applies to all export formats
  ///
  /// NEW
  final FileProvider fileProvider;

  BaseExportService({required this.fileProvider});
  // NEW
  @override
  void validateForExport(AssessmentFormModel assessment) {
    // Call format-specific validation
    validateFormatSpecific(assessment);
  }

  /// Format-specific validation (override in implementations)
  void validateFormatSpecific(AssessmentFormModel assessment) {
    // Default implementation - override in subclasses
  }

  /// Common method to validate exported file
  Future<void> validateExportedFile(
    String filePath, {
    int? minSizeBytes,
  }) async {
    final file = await fileProvider.getFile(filePath);

    if (!await file.exists()) {
      throw FileException(message: 'File was not created: $filePath');
    }

    final fileSize = await file.length();

    if (fileSize == 0) {
      throw FileException(message: 'File is empty: $filePath');
    }
  }

  /// Helper method to get rating text
  String getRatingText(dynamic rating) {
    if (rating == null) return 'Not Rated';
    if (rating.value == 3) return '+++ (3) Meets target';
    if (rating.value == 2) return '++ (2) Partially meets target';
    if (rating.value == 1) return '+ (1) Does not meet target';
    if (rating.value == 0) return 'DK - Don\'t Know';
    if (rating.value == -1) return 'NA - Not Applicable';
    return 'Unknown';
  }

  /// Helper method to get facility type text
  String getFacilityTypeText(dynamic facilityType) {
    if (facilityType == null) return 'Not specified';
    return facilityType
        .toString()
        .split('.')
        .last
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  /// Helper method to get managing authority text
  String getManagingAuthorityText(dynamic managingAuthority) {
    if (managingAuthority == null) return 'Not specified';
    return managingAuthority
        .toString()
        .split('.')
        .last
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  /// Helper method to get structure type text
  String getStructureTypeText(dynamic structureType) {
    if (structureType == null) return 'Not specified';
    return structureType
        .toString()
        .split('.')
        .last
        .replaceAll('_', ' ')
        .toUpperCase();
  }
}

class ExportServiceFactory {
  static ExportService createExportService(String format) {
    switch (format.toLowerCase()) {
      case 'pdf':
        return PdfExportService(fileProvider: FileProviderImpl());
      case 'xlsx':
      case 'excel':
        return ExcelExportService(fileProvider: FileProviderImpl());
      case 'docx':
      case 'doc':
        return DocExportService(fileProvider: FileProviderImpl());
      default:
        throw ValidationException(
          message:
              'Unsupported export format: $format. '
              'Supported formats: ${getSupportedFormats().join(', ')}',
        );
    }
  }

  static List<String> getSupportedFormats() {
    return ['pdf', 'xlsx', 'excel', 'doc', 'docx'];
  }

  static bool isFormatSupported(String format) {
    return getSupportedFormats().contains(format.toLowerCase());
  }

  static Map<String, String> getFormatInfo(String format) {
    final service = createExportService(format);
    return {
      'extension': service.fileExtension,
      'name': service.formatName,
      'mimeType': service.mimeType,
    };
  }
}
