abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

class CacheException extends AppException {
  const CacheException({required super.message, super.code, required s});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.code});
}

class ValidationException extends AppException {
  const ValidationException({required super.message, super.code});
}

class FileException extends AppException {
  const FileException({super.message = 'File operation failed', super.code});
}

class ExportException extends AppException {
  final String exportFormat;

  const ExportException({
    required super.message,
    required this.exportFormat,
    super.code,
  });

  @override
  String toString() => 'Export Error ($exportFormat): $message';
}

class ExcelExportException extends ExportException {
  const ExcelExportException({required super.message, super.code})
    : super(exportFormat: 'Excel');
}

class PdfExportException extends ExportException {
  const PdfExportException({required super.message, super.code})
    : super(exportFormat: 'PDF');
}

class EmailException extends AppException {
  const EmailException({super.message = 'Email operation failed', super.code});
}

class PermissionException extends AppException {
  final String permissionType;

  const PermissionException({
    required super.message,
    required this.permissionType,
    super.code,
  });

  @override
  String toString() => 'Permission Error ($permissionType): $message';
}

class StoragePermissionException extends PermissionException {
  const StoragePermissionException({
    super.message = 'Storage permission denied',
    super.code,
  }) : super(permissionType: 'Storage');
}

class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred',
    super.code,
  });
}

class ConnectionException extends AppException {
  const ConnectionException({super.message = 'Connection failed', super.code});
}

class AssessmentException extends AppException {
  const AssessmentException({required super.message, super.code});
}

class AssessmentValidationException extends AssessmentException {
  final Map<String, String>? fieldErrors;

  const AssessmentValidationException({
    required super.message,
    this.fieldErrors,
    super.code,
  });
}

class AssessmentExportValidationException extends AssessmentException {
  final String exportFormat;
  final int? itemCount;
  final double? completionRate;

  const AssessmentExportValidationException({
    required super.message,
    required this.exportFormat,
    this.itemCount,
    this.completionRate,
    super.code,
  });

  @override
  String toString() {
    return 'Assessment Export Validation Error ($exportFormat): $message'
        '${itemCount != null ? ' (Items: $itemCount)' : ''}'
        '${completionRate != null ? ' (Completion: ${completionRate!.toStringAsFixed(1)}%)' : ''}';
  }
}

class FileSizeException extends FileException {
  final int actualSize;
  final int expectedMinSize;
  final String fileFormat;

  const FileSizeException({
    required super.message,
    required this.actualSize,
    required this.expectedMinSize,
    required this.fileFormat,
    super.code,
  });

  @override
  String toString() {
    return 'File Size Error ($fileFormat): $message '
        '(Expected: ≥${(expectedMinSize / 1024).toStringAsFixed(1)}KB, '
        'Actual: ${(actualSize / 1024).toStringAsFixed(1)}KB)';
  }
}

class ImportException extends AppException {
  final String? importFormat;

  const ImportException({
    required super.message,
    this.importFormat,
    super.code,
  });

  @override
  String toString() =>
      importFormat != null
          ? 'Import Error ($importFormat): $message'
          : 'Import Error: $message';
}

class ExcelImportException extends ImportException {
  const ExcelImportException({required super.message, super.code})
    : super(importFormat: 'Excel');
}

class DatabaseException implements Exception {
  final String message;
  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

class UnsupportedTableException implements Exception {
  final String message;
  const UnsupportedTableException(this.message);

  @override
  String toString() => 'UnsupportedTableException: $message';
}
