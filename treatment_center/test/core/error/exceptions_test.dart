import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/core/error/exceptions.dart';

void main() {
  group('AppException Tests', () {
    test('should create AppException with required message', () {
      // Arrange
      const message = 'Test error message';

      // Act
      const exception = _TestAppException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
      expect(exception.toString(), equals(message));
    });

    test('should create AppException with message and code', () {
      // Arrange
      const message = 'Test error message';
      const code = 'TEST_001';

      // Act
      const exception = _TestAppException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
      expect(exception.toString(), equals(message));
    });
  });

  group('ServerException Tests', () {
    test('should create ServerException with required message', () {
      // Arrange
      const message = 'Server error occurred';

      // Act
      const exception = ServerException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
      expect(exception.toString(), equals(message));
      expect(exception, isA<AppException>());
    });

    test('should create ServerException with message and code', () {
      // Arrange
      const message = 'Internal server error';
      const code = 'SRV_500';

      // Act
      const exception = ServerException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
      expect(exception.toString(), equals(message));
    });
  });

  group('CacheException Tests', () {
    test('should create CacheException with required parameters', () {
      // Arrange
      const message = 'Cache operation failed';
      const s = 'Some stack trace';

      // Act
      const exception = CacheException(message: message, s: s);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
      expect(exception.toString(), equals(message));
      expect(exception, isA<AppException>());
    });

    test('should create CacheException with all parameters', () {
      // Arrange
      const message = 'Cache write failed';
      const code = 'CACHE_001';
      const s = 'Stack trace info';

      // Act
      const exception = CacheException(message: message, code: code, s: s);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('NetworkException Tests', () {
    test('should create NetworkException with required message', () {
      // Arrange
      const message = 'Network unavailable';

      // Act
      const exception = NetworkException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
      expect(exception.toString(), equals(message));
      expect(exception, isA<AppException>());
    });

    test('should create NetworkException with message and code', () {
      // Arrange
      const message = 'Connection timeout';
      const code = 'NET_TIMEOUT';

      // Act
      const exception = NetworkException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('ValidationException Tests', () {
    test('should create ValidationException with required message', () {
      // Arrange
      const message = 'Invalid input data';

      // Act
      const exception = ValidationException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
      expect(exception.toString(), equals(message));
      expect(exception, isA<AppException>());
    });

    test('should create ValidationException with message and code', () {
      // Arrange
      const message = 'Email format invalid';
      const code = 'VAL_EMAIL';

      // Act
      const exception = ValidationException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('FileException Tests', () {
    test('should create FileException with default message', () {
      // Arrange & Act
      const exception = FileException();

      // Assert
      expect(exception.message, equals('File operation failed'));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('File operation failed'));
      expect(exception, isA<AppException>());
    });

    test('should create FileException with custom message', () {
      // Arrange
      const message = 'File not found';

      // Act
      const exception = FileException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
    });

    test('should create FileException with message and code', () {
      // Arrange
      const message = 'Permission denied';
      const code = 'FILE_PERM';

      // Act
      const exception = FileException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('ExportException Tests', () {
    test('should create ExportException with required parameters', () {
      // Arrange
      const message = 'Export failed';
      const exportFormat = 'CSV';

      // Act
      const exception = ExportException(
        message: message,
        exportFormat: exportFormat,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.exportFormat, equals(exportFormat));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('Export Error (CSV): Export failed'));
      expect(exception, isA<AppException>());
    });

    test('should create ExportException with all parameters', () {
      // Arrange
      const message = 'Invalid data format';
      const exportFormat = 'JSON';
      const code = 'EXP_001';

      // Act
      const exception = ExportException(
        message: message,
        exportFormat: exportFormat,
        code: code,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.exportFormat, equals(exportFormat));
      expect(exception.code, equals(code));
      expect(
        exception.toString(),
        equals('Export Error (JSON): Invalid data format'),
      );
    });
  });

  group('ExcelExportException Constructor Coverage', () {
    test('should execute constructor initializer - basic case', () {
      // Arrange
      const message = 'Excel generation failed';

      // Act - Forces execution of: : super(exportFormat: 'Excel');
      const exception = ExcelExportException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.exportFormat, equals('Excel'));
      expect(exception.code, isNull);
      expect(
        exception.toString(),
        equals('Export Error (Excel): Excel generation failed'),
      );
      expect(exception, isA<ExportException>());
      expect(exception, isA<AppException>());
    });

    test('should execute constructor initializer - with code', () {
      // Arrange
      const message = 'Worksheet limit exceeded';
      const code = 'EXCEL_001';

      // Act - Forces execution of: : super(exportFormat: 'Excel');
      const exception = ExcelExportException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.exportFormat, equals('Excel'));
      expect(exception.code, equals(code));
    });

    test('should execute constructor initializer - multiple instances', () {
      // Arrange & Act - Multiple calls to cover the line
      final exceptions = [
        ExcelExportException(message: 'Test 1'),
        ExcelExportException(message: 'Test 2', code: 'CODE_2'),
        ExcelExportException(message: 'Test 3'),
        ExcelExportException(message: 'Test 4', code: null),
      ];

      // Assert - All should have Excel format from initializer
      for (final exception in exceptions) {
        expect(exception.exportFormat, equals('Excel'));
      }
    });

    test('should execute constructor initializer - direct property access', () {
      // Act & Assert - Direct access to force line execution
      expect(
        ExcelExportException(message: 'test').exportFormat,
        equals('Excel'),
      );
      expect(
        ExcelExportException(message: 'test', code: 'code').exportFormat,
        equals('Excel'),
      );
    });

    test('should execute constructor initializer - variable assignment', () {
      // Arrange & Act
      ExcelExportException exception;

      exception = ExcelExportException(message: 'assignment test 1');
      expect(exception.exportFormat, equals('Excel'));

      exception = ExcelExportException(
        message: 'assignment test 2',
        code: 'ASSIGN_2',
      );
      expect(exception.exportFormat, equals('Excel'));
    });
  });

  group('PdfExportException Constructor Coverage', () {
    test('should execute constructor initializer - basic case', () {
      // Arrange
      const message = 'PDF generation failed';

      // Act - Forces execution of: : super(exportFormat: 'PDF');
      const exception = PdfExportException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.exportFormat, equals('PDF'));
      expect(exception.code, isNull);
      expect(
        exception.toString(),
        equals('Export Error (PDF): PDF generation failed'),
      );
      expect(exception, isA<ExportException>());
      expect(exception, isA<AppException>());
    });

    test('should execute constructor initializer - with code', () {
      // Arrange
      const message = 'Font not supported';
      const code = 'PDF_FONT';

      // Act - Forces execution of: : super(exportFormat: 'PDF');
      const exception = PdfExportException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.exportFormat, equals('PDF'));
      expect(exception.code, equals(code));
    });

    test('should execute constructor initializer - multiple instances', () {
      // Arrange & Act - Multiple calls to cover the line
      final exceptions = [
        PdfExportException(message: 'Test 1'),
        PdfExportException(message: 'Test 2', code: 'CODE_2'),
        PdfExportException(message: 'Test 3'),
        PdfExportException(message: 'Test 4', code: null),
      ];

      // Assert - All should have PDF format from initializer
      for (final exception in exceptions) {
        expect(exception.exportFormat, equals('PDF'));
      }
    });

    test('should execute constructor initializer - direct property access', () {
      // Act & Assert - Direct access to force line execution
      expect(PdfExportException(message: 'test').exportFormat, equals('PDF'));
      expect(
        PdfExportException(message: 'test', code: 'code').exportFormat,
        equals('PDF'),
      );
    });

    test('should execute constructor initializer - variable assignment', () {
      // Arrange & Act
      PdfExportException exception;

      exception = PdfExportException(message: 'assignment test 1');
      expect(exception.exportFormat, equals('PDF'));

      exception = PdfExportException(
        message: 'assignment test 2',
        code: 'ASSIGN_2',
      );
      expect(exception.exportFormat, equals('PDF'));
    });
  });

  group('EmailException Tests', () {
    test('should create EmailException with default message', () {
      // Arrange & Act
      const exception = EmailException();

      // Assert
      expect(exception.message, equals('Email operation failed'));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('Email operation failed'));
      expect(exception, isA<AppException>());
    });

    test('should create EmailException with custom message', () {
      // Arrange
      const message = 'SMTP server unavailable';

      // Act
      const exception = EmailException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
    });

    test('should create EmailException with message and code', () {
      // Arrange
      const message = 'Invalid recipient';
      const code = 'EMAIL_INVALID';

      // Act
      const exception = EmailException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('PermissionException Tests', () {
    test('should create PermissionException with required parameters', () {
      // Arrange
      const message = 'Permission denied';
      const permissionType = 'Camera';

      // Act
      const exception = PermissionException(
        message: message,
        permissionType: permissionType,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.permissionType, equals(permissionType));
      expect(exception.code, isNull);
      expect(
        exception.toString(),
        equals('Permission Error (Camera): Permission denied'),
      );
      expect(exception, isA<AppException>());
    });

    test('should create PermissionException with all parameters', () {
      // Arrange
      const message = 'Location access denied';
      const permissionType = 'Location';
      const code = 'PERM_LOC';

      // Act
      const exception = PermissionException(
        message: message,
        permissionType: permissionType,
        code: code,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.permissionType, equals(permissionType));
      expect(exception.code, equals(code));
      expect(
        exception.toString(),
        equals('Permission Error (Location): Location access denied'),
      );
    });
  });

  group('StoragePermissionException Constructor Coverage', () {
    test('should execute constructor initializer - default case', () {
      // Arrange & Act - Forces execution of: }) : super(permissionType: 'Storage');
      const exception = StoragePermissionException();

      // Assert
      expect(exception.message, equals('Storage permission denied'));
      expect(exception.permissionType, equals('Storage'));
      expect(exception.code, isNull);
      expect(
        exception.toString(),
        equals('Permission Error (Storage): Storage permission denied'),
      );
      expect(exception, isA<PermissionException>());
      expect(exception, isA<AppException>());
    });

    test('should execute constructor initializer - custom message', () {
      // Arrange
      const message = 'External storage access denied';

      // Act - Forces execution of: }) : super(permissionType: 'Storage');
      const exception = StoragePermissionException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.permissionType, equals('Storage'));
      expect(exception.code, isNull);
    });

    test('should execute constructor initializer - with code', () {
      // Arrange
      const message = 'Write permission required';
      const code = 'STORAGE_WRITE';

      // Act - Forces execution of: }) : super(permissionType: 'Storage');
      const exception = StoragePermissionException(
        message: message,
        code: code,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.permissionType, equals('Storage'));
      expect(exception.code, equals(code));
    });

    test('should execute constructor initializer - multiple instances', () {
      // Arrange & Act - Multiple calls to cover the line
      final exceptions = [
        StoragePermissionException(),
        StoragePermissionException(message: 'Test 2'),
        StoragePermissionException(code: 'CODE_3'),
        StoragePermissionException(message: 'Test 4', code: 'CODE_4'),
        StoragePermissionException(message: 'Test 5', code: null),
      ];

      // Assert - All should have Storage type from initializer
      for (final exception in exceptions) {
        expect(exception.permissionType, equals('Storage'));
      }
    });

    test('should execute constructor initializer - direct property access', () {
      // Act & Assert - Direct access to force line execution
      expect(StoragePermissionException().permissionType, equals('Storage'));
      expect(
        StoragePermissionException(message: 'test').permissionType,
        equals('Storage'),
      );
      expect(
        StoragePermissionException(code: 'code').permissionType,
        equals('Storage'),
      );
      expect(
        StoragePermissionException(
          message: 'test',
          code: 'code',
        ).permissionType,
        equals('Storage'),
      );
    });

    test('should execute constructor initializer - variable assignment', () {
      // Arrange & Act
      StoragePermissionException exception;

      exception = StoragePermissionException();
      expect(exception.permissionType, equals('Storage'));

      exception = StoragePermissionException(message: 'assignment test');
      expect(exception.permissionType, equals('Storage'));

      exception = StoragePermissionException(code: 'assignment code');
      expect(exception.permissionType, equals('Storage'));

      exception = StoragePermissionException(
        message: 'assignment test',
        code: 'assignment code',
      );
      expect(exception.permissionType, equals('Storage'));
    });
  });

  group('UnexpectedException Tests', () {
    test('should create UnexpectedException with default message', () {
      // Arrange & Act
      const exception = UnexpectedException();

      // Assert
      expect(exception.message, equals('An unexpected error occurred'));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('An unexpected error occurred'));
      expect(exception, isA<AppException>());
    });

    test('should create UnexpectedException with custom message', () {
      // Arrange
      const message = 'Unknown system error';

      // Act
      const exception = UnexpectedException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
    });

    test('should create UnexpectedException with message and code', () {
      // Arrange
      const message = 'Fatal system error';
      const code = 'FATAL_001';

      // Act
      const exception = UnexpectedException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('ConnectionException Tests', () {
    test('should create ConnectionException with default message', () {
      // Arrange & Act
      const exception = ConnectionException();

      // Assert
      expect(exception.message, equals('Connection failed'));
      expect(exception.code, isNull);
      expect(exception.toString(), equals('Connection failed'));
      expect(exception, isA<AppException>());
    });

    test('should create ConnectionException with custom message', () {
      // Arrange
      const message = 'Database connection lost';

      // Act
      const exception = ConnectionException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
    });

    test('should create ConnectionException with message and code', () {
      // Arrange
      const message = 'API connection timeout';
      const code = 'CONN_TIMEOUT';

      // Act
      const exception = ConnectionException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('AssessmentException Tests', () {
    test('should create AssessmentException with required message', () {
      // Arrange
      const message = 'Assessment processing failed';

      // Act
      const exception = AssessmentException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, isNull);
      expect(exception.toString(), equals(message));
      expect(exception, isA<AppException>());
    });

    test('should create AssessmentException with message and code', () {
      // Arrange
      const message = 'Invalid assessment data';
      const code = 'ASSESS_001';

      // Act
      const exception = AssessmentException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.code, equals(code));
    });
  });

  group('AssessmentValidationException Tests', () {
    test(
      'should create AssessmentValidationException with required message',
      () {
        // Arrange
        const message = 'Assessment validation failed';

        // Act
        const exception = AssessmentValidationException(message: message);

        // Assert
        expect(exception.message, equals(message));
        expect(exception.fieldErrors, isNull);
        expect(exception.code, isNull);
        expect(exception.toString(), equals(message));
        expect(exception, isA<AssessmentException>());
        expect(exception, isA<AppException>());
      },
    );

    test('should create AssessmentValidationException with field errors', () {
      // Arrange
      const message = 'Multiple validation errors';
      const fieldErrors = {
        'email': 'Invalid format',
        'age': 'Must be positive',
      };

      // Act
      const exception = AssessmentValidationException(
        message: message,
        fieldErrors: fieldErrors,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.fieldErrors, equals(fieldErrors));
      expect(exception.code, isNull);
    });

    test('should create AssessmentValidationException with all parameters', () {
      // Arrange
      const message = 'Validation error';
      const fieldErrors = {'name': 'Required field'};
      const code = 'VAL_ASSESS';

      // Act
      const exception = AssessmentValidationException(
        message: message,
        fieldErrors: fieldErrors,
        code: code,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.fieldErrors, equals(fieldErrors));
      expect(exception.code, equals(code));
    });
  });

  group('AssessmentExportValidationException Tests', () {
    test(
      'should create AssessmentExportValidationException with required parameters',
      () {
        // Arrange
        const message = 'Export validation failed';
        const exportFormat = 'PDF';

        // Act
        const exception = AssessmentExportValidationException(
          message: message,
          exportFormat: exportFormat,
        );

        // Assert
        expect(exception.message, equals(message));
        expect(exception.exportFormat, equals(exportFormat));
        expect(exception.itemCount, isNull);
        expect(exception.completionRate, isNull);
        expect(exception.code, isNull);
        expect(
          exception.toString(),
          equals(
            'Assessment Export Validation Error (PDF): Export validation failed',
          ),
        );
        expect(exception, isA<AssessmentException>());
        expect(exception, isA<AppException>());
      },
    );

    test('should create AssessmentExportValidationException with item count', () {
      // Arrange
      const message = 'Insufficient items for export';
      const exportFormat = 'Excel';
      const itemCount = 5;

      // Act
      const exception = AssessmentExportValidationException(
        message: message,
        exportFormat: exportFormat,
        itemCount: itemCount,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.exportFormat, equals(exportFormat));
      expect(exception.itemCount, equals(itemCount));
      expect(exception.completionRate, isNull);
      expect(
        exception.toString(),
        equals(
          'Assessment Export Validation Error (Excel): Insufficient items for export (Items: 5)',
        ),
      );
    });

    test(
      'should create AssessmentExportValidationException with completion rate',
      () {
        // Arrange
        const message = 'Low completion rate';
        const exportFormat = 'CSV';
        const completionRate = 45.67;

        // Act
        const exception = AssessmentExportValidationException(
          message: message,
          exportFormat: exportFormat,
          completionRate: completionRate,
        );

        // Assert
        expect(exception.message, equals(message));
        expect(exception.exportFormat, equals(exportFormat));
        expect(exception.itemCount, isNull);
        expect(exception.completionRate, equals(completionRate));
        expect(
          exception.toString(),
          equals(
            'Assessment Export Validation Error (CSV): Low completion rate (Completion: 45.7%)',
          ),
        );
      },
    );

    test(
      'should create AssessmentExportValidationException with all parameters',
      () {
        // Arrange
        const message = 'Export requirements not met';
        const exportFormat = 'JSON';
        const itemCount = 10;
        const completionRate = 78.9;
        const code = 'ASSESS_EXP_001';

        // Act
        const exception = AssessmentExportValidationException(
          message: message,
          exportFormat: exportFormat,
          itemCount: itemCount,
          completionRate: completionRate,
          code: code,
        );

        // Assert
        expect(exception.message, equals(message));
        expect(exception.exportFormat, equals(exportFormat));
        expect(exception.itemCount, equals(itemCount));
        expect(exception.completionRate, equals(completionRate));
        expect(exception.code, equals(code));
        expect(
          exception.toString(),
          equals(
            'Assessment Export Validation Error (JSON): Export requirements not met (Items: 10) (Completion: 78.9%)',
          ),
        );
      },
    );
  });

  group('FileSizeException Tests', () {
    test('should create FileSizeException with required parameters', () {
      // Arrange
      const message = 'File too small';
      const actualSize = 1024; // 1KB
      const expectedMinSize = 2048; // 2KB
      const fileFormat = 'PDF';

      // Act
      const exception = FileSizeException(
        message: message,
        actualSize: actualSize,
        expectedMinSize: expectedMinSize,
        fileFormat: fileFormat,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.actualSize, equals(actualSize));
      expect(exception.expectedMinSize, equals(expectedMinSize));
      expect(exception.fileFormat, equals(fileFormat));
      expect(exception.code, isNull);
      expect(
        exception.toString(),
        equals(
          'File Size Error (PDF): File too small (Expected: ≥2.0KB, Actual: 1.0KB)',
        ),
      );
      expect(exception, isA<FileException>());
      expect(exception, isA<AppException>());
    });

    test('should create FileSizeException with all parameters', () {
      // Arrange
      const message = 'Invalid file size';
      const actualSize = 512; // 0.5KB
      const expectedMinSize = 1024; // 1KB
      const fileFormat = 'Excel';
      const code = 'FILE_SIZE_001';

      // Act
      const exception = FileSizeException(
        message: message,
        actualSize: actualSize,
        expectedMinSize: expectedMinSize,
        fileFormat: fileFormat,
        code: code,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.actualSize, equals(actualSize));
      expect(exception.expectedMinSize, equals(expectedMinSize));
      expect(exception.fileFormat, equals(fileFormat));
      expect(exception.code, equals(code));
      expect(
        exception.toString(),
        equals(
          'File Size Error (Excel): Invalid file size (Expected: ≥1.0KB, Actual: 0.5KB)',
        ),
      );
    });

    test('should format file sizes correctly in toString', () {
      // Arrange
      const message = 'Size validation failed';
      const actualSize = 1536; // 1.5KB
      const expectedMinSize = 3072; // 3KB
      const fileFormat = 'Image';

      // Act
      const exception = FileSizeException(
        message: message,
        actualSize: actualSize,
        expectedMinSize: expectedMinSize,
        fileFormat: fileFormat,
      );

      // Assert
      expect(
        exception.toString(),
        equals(
          'File Size Error (Image): Size validation failed (Expected: ≥3.0KB, Actual: 1.5KB)',
        ),
      );
    });
  });

  group('Exception Inheritance Tests', () {
    test('should verify all exceptions implement Exception interface', () {
      // Arrange & Act & Assert
      expect(const ServerException(message: 'test'), isA<Exception>());
      expect(
        const CacheException(message: 'test', s: 'stack trace'),
        isA<Exception>(),
      );
      expect(const NetworkException(message: 'test'), isA<Exception>());
      expect(const ValidationException(message: 'test'), isA<Exception>());
      expect(const FileException(), isA<Exception>());
      expect(
        const ExportException(message: 'test', exportFormat: 'CSV'),
        isA<Exception>(),
      );
      expect(const ExcelExportException(message: 'test'), isA<Exception>());
      expect(const PdfExportException(message: 'test'), isA<Exception>());
      expect(const EmailException(), isA<Exception>());
      expect(
        const PermissionException(message: 'test', permissionType: 'Storage'),
        isA<Exception>(),
      );
      expect(const StoragePermissionException(), isA<Exception>());
      expect(const UnexpectedException(), isA<Exception>());
      expect(const ConnectionException(), isA<Exception>());
      expect(const AssessmentException(message: 'test'), isA<Exception>());
      expect(
        const AssessmentValidationException(message: 'test'),
        isA<Exception>(),
      );
      expect(
        const AssessmentExportValidationException(
          message: 'test',
          exportFormat: 'PDF',
        ),
        isA<Exception>(),
      );
      expect(
        const FileSizeException(
          message: 'test',
          actualSize: 100,
          expectedMinSize: 200,
          fileFormat: 'PDF',
        ),
        isA<Exception>(),
      );
    });

    test('should verify inheritance chain is correct', () {
      // Arrange & Act & Assert
      expect(
        const ExcelExportException(message: 'test'),
        isA<ExportException>(),
      );
      expect(const PdfExportException(message: 'test'), isA<ExportException>());
      expect(const StoragePermissionException(), isA<PermissionException>());
      expect(
        const AssessmentValidationException(message: 'test'),
        isA<AssessmentException>(),
      );
      expect(
        const AssessmentExportValidationException(
          message: 'test',
          exportFormat: 'PDF',
        ),
        isA<AssessmentException>(),
      );
      expect(
        const FileSizeException(
          message: 'test',
          actualSize: 100,
          expectedMinSize: 200,
          fileFormat: 'PDF',
        ),
        isA<FileException>(),
      );
    });
  });

  group('Edge Case and Comprehensive Tests', () {
    test('should handle exception creation in try-catch blocks', () {
      try {
        final excel = ExcelExportException(message: 'Try-catch Excel');
        final pdf = PdfExportException(message: 'Try-catch PDF');
        final storage = StoragePermissionException(
          message: 'Try-catch Storage',
        );

        expect(excel.exportFormat, 'Excel');
        expect(pdf.exportFormat, 'PDF');
        expect(storage.permissionType, 'Storage');
      } catch (e) {
        fail('Should not throw exception during creation');
      }
    });

    test('should handle all constructor parameter variations', () {
      // Excel variations
      ExcelExportException(message: 'Variation 1');
      ExcelExportException(message: 'Variation 2', code: 'CODE');
      ExcelExportException(message: 'Variation 3', code: null);

      // PDF variations
      PdfExportException(message: 'Variation 1');
      PdfExportException(message: 'Variation 2', code: 'CODE');
      PdfExportException(message: 'Variation 3', code: null);

      // Storage variations
      StoragePermissionException();
      StoragePermissionException(message: 'Custom message');
      StoragePermissionException(code: 'Custom code');
      StoragePermissionException(
        message: 'Custom message',
        code: 'Custom code',
      );
      StoragePermissionException(message: 'Custom message', code: null);

      // If we reach here, all constructor calls succeeded
      expect(true, isTrue);
    });
  });
  group('ImportException Tests', () {
    test('should create ImportException without format', () {
      // Arrange
      const message = 'Import failed';

      // Act
      const exception = ImportException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.importFormat, isNull);
      expect(exception.code, isNull);
      expect(exception.toString(), equals('Import Error: $message'));
      expect(exception, isA<AppException>());
    });

    test('should create ImportException with format and code', () {
      // Arrange
      const message = 'Import failed';
      const format = 'CSV';
      const code = 'IMP_001';

      // Act
      const exception = ImportException(
        message: message,
        importFormat: format,
        code: code,
      );

      // Assert
      expect(exception.message, equals(message));
      expect(exception.importFormat, equals(format));
      expect(exception.code, equals(code));
      expect(exception.toString(), equals('Import Error (CSV): $message'));
      expect(exception, isA<AppException>());
    });
  });
  group('ExcelImportException Constructor Coverage', () {
    test('should execute constructor initializer – basic case', () {
      // Arrange
      const message = 'Excel import failed';

      // Act
      const exception = ExcelImportException(message: message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.importFormat, equals('Excel'));
      expect(exception.code, isNull);
      expect(
        exception.toString(),
        equals('Import Error (Excel): Excel import failed'),
      );
      expect(exception, isA<ImportException>());
      expect(exception, isA<AppException>());
    });

    test('should execute constructor initializer – with code', () {
      // Arrange
      const message = 'Worksheet limit exceeded';
      const code = 'EXCEL_IMP_001';

      // Act
      const exception = ExcelImportException(message: message, code: code);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.importFormat, equals('Excel'));
      expect(exception.code, equals(code));
    });

    test('should execute constructor initializer – multiple instances', () {
      // Arrange & Act – Multiple calls to cover the line
      final exceptions = [
        ExcelImportException(message: 'Test 1'),
        ExcelImportException(message: 'Test 2', code: 'CODE_2'),
        ExcelImportException(message: 'Test 3'),
        ExcelImportException(message: 'Test 4', code: null),
      ];

      // Assert – All should have Excel format from initializer
      for (final exception in exceptions) {
        expect(exception.importFormat, equals('Excel'));
      }
    });

    test('should execute constructor initializer – direct property access', () {
      // Act & Assert – Direct access to force line execution
      expect(
        ExcelImportException(message: 'test').importFormat,
        equals('Excel'),
      );
      expect(
        ExcelImportException(message: 'test', code: 'code').importFormat,
        equals('Excel'),
      );
    });

    test('should execute constructor initializer – variable assignment', () {
      // Arrange & Act
      ExcelImportException exception;

      exception = ExcelImportException(message: 'assignment test 1');
      expect(exception.importFormat, equals('Excel'));

      exception = ExcelImportException(
        message: 'assignment test 2',
        code: 'ASSIGN_2',
      );
      expect(exception.importFormat, equals('Excel'));
    });
  });

  group('DatabaseException Tests', () {
    test('should create DatabaseException with message', () {
      // Arrange
      const message = 'DB error';

      // Act
      const exception = DatabaseException(message);

      // Assert
      expect(exception.message, equals(message));
      expect(exception.toString(), equals('DatabaseException: $message'));
      expect(exception, isA<Exception>());
    });
  });

  group('UnsupportedTableException Tests', () {
    test('should create UnsupportedTableException with message', () {
      // Arrange
      const message = 'Table not supported';

      // Act
      const exception = UnsupportedTableException(message);

      // Assert
      expect(exception.message, equals(message));
      expect(
        exception.toString(),
        equals('UnsupportedTableException: $message'),
      );
      expect(exception, isA<Exception>());
    });
  });
}

// Test implementation of abstract AppException for testing purposes
class _TestAppException extends AppException {
  const _TestAppException({required super.message, super.code});
}
