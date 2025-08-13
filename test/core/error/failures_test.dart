import 'package:flutter_test/flutter_test.dart';
import 'package:equatable/equatable.dart';
import 'package:treatment_center/core/error/failures.dart';

void main() {
  group('Base Failure Class Tests', () {
    test('should create failure with required message', () {
      // Arrange
      const message = 'Test failure message';

      // Act
      const failure = ServerFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props for Equatable', () {
      // Arrange
      const message = 'Test message';
      const failure = ServerFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
      expect(props, hasLength(1));
    });
  });

  group('ServerFailure Tests', () {
    test('should create ServerFailure with required message', () {
      // Arrange
      const message = 'Server connection failed';

      // Act
      const failure = ServerFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Server error occurred';
      const failure = ServerFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('CacheFailure Tests', () {
    test('should create CacheFailure with required message', () {
      // Arrange
      const message = 'Cache operation failed';

      // Act
      const failure = CacheFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Cache write failed';
      const failure = CacheFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('NetworkFailure Tests', () {
    test('should create NetworkFailure with required message', () {
      // Arrange
      const message = 'Network unavailable';

      // Act
      const failure = NetworkFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Connection timeout';
      const failure = NetworkFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('ValidationFailure Tests', () {
    test('should create ValidationFailure with required message', () {
      // Arrange
      const message = 'Input validation failed';

      // Act
      const failure = ValidationFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Email format invalid';
      const failure = ValidationFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('FileOperationFailure Tests', () {
    test('should create FileOperationFailure with required message', () {
      // Arrange
      const message = 'File read operation failed';

      // Act
      const failure = FileOperationFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'File not found';
      const failure = FileOperationFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('ExportFailure Tests', () {
    test('should create ExportFailure with required message', () {
      // Arrange
      const message = 'Export operation failed';

      // Act
      const failure = ExportFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'PDF export failed';
      const failure = ExportFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('EmailFailure Tests', () {
    test('should create EmailFailure with required message', () {
      // Arrange
      const message = 'Email sending failed';

      // Act
      const failure = EmailFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'SMTP server unavailable';
      const failure = EmailFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('UnexpectedFailure Tests', () {
    test('should create UnexpectedFailure with required message', () {
      // Arrange
      const message = 'An unexpected error occurred';

      // Act
      const failure = UnexpectedFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Unknown system error';
      const failure = UnexpectedFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('ConnectionFailure Tests', () {
    test('should create ConnectionFailure with required message', () {
      // Arrange
      const message = 'Connection establishment failed';

      // Act
      const failure = ConnectionFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Database connection lost';
      const failure = ConnectionFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
    });
  });

  group('Equatable Equality Tests', () {
    test('should be equal when messages are identical - ServerFailure', () {
      // Arrange
      const message = 'Server error';
      const failure1 = ServerFailure(message: message);
      const failure2 = ServerFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });

    test('should not be equal when messages are different - ServerFailure', () {
      // Arrange
      const failure1 = ServerFailure(message: 'Server error 1');
      const failure2 = ServerFailure(message: 'Server error 2');

      // Act & Assert
      expect(failure1, isNot(equals(failure2)));
      expect(failure1 == failure2, isFalse);
    });

    test('should not be equal when failure types are different', () {
      // Arrange
      const message = 'Same message';
      const serverFailure = ServerFailure(message: message);
      const cacheFailure = CacheFailure(message: message);

      // Act & Assert
      expect(serverFailure, isNot(equals(cacheFailure)));
      expect(serverFailure == cacheFailure, isFalse);
    });

    test('should be equal when messages are identical - CacheFailure', () {
      // Arrange
      const message = 'Cache error';
      const failure1 = CacheFailure(message: message);
      const failure2 = CacheFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });

    test('should be equal when messages are identical - NetworkFailure', () {
      // Arrange
      const message = 'Network error';
      const failure1 = NetworkFailure(message: message);
      const failure2 = NetworkFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });

    test('should be equal when messages are identical - ValidationFailure', () {
      // Arrange
      const message = 'Validation error';
      const failure1 = ValidationFailure(message: message);
      const failure2 = ValidationFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });

    test(
      'should be equal when messages are identical - FileOperationFailure',
      () {
        // Arrange
        const message = 'File operation error';
        const failure1 = FileOperationFailure(message: message);
        const failure2 = FileOperationFailure(message: message);

        // Act & Assert
        expect(failure1, equals(failure2));
        expect(failure1 == failure2, isTrue);
      },
    );

    test('should be equal when messages are identical - ExportFailure', () {
      // Arrange
      const message = 'Export error';
      const failure1 = ExportFailure(message: message);
      const failure2 = ExportFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });

    test('should be equal when messages are identical - EmailFailure', () {
      // Arrange
      const message = 'Email error';
      const failure1 = EmailFailure(message: message);
      const failure2 = EmailFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });

    test('should be equal when messages are identical - UnexpectedFailure', () {
      // Arrange
      const message = 'Unexpected error';
      const failure1 = UnexpectedFailure(message: message);
      const failure2 = UnexpectedFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });

    test('should be equal when messages are identical - ConnectionFailure', () {
      // Arrange
      const message = 'Connection error';
      const failure1 = ConnectionFailure(message: message);
      const failure2 = ConnectionFailure(message: message);

      // Act & Assert
      expect(failure1, equals(failure2));
      expect(failure1 == failure2, isTrue);
    });
  });

  group('Equatable HashCode Tests', () {
    test(
      'should have same hashCode when failures are equal - ServerFailure',
      () {
        // Arrange
        const message = 'Server error';
        const failure1 = ServerFailure(message: message);
        const failure2 = ServerFailure(message: message);

        // Act & Assert
        expect(failure1.hashCode, equals(failure2.hashCode));
      },
    );

    test(
      'should have different hashCode when failures are not equal - ServerFailure',
      () {
        // Arrange
        const failure1 = ServerFailure(message: 'Server error 1');
        const failure2 = ServerFailure(message: 'Server error 2');

        // Act & Assert
        expect(failure1.hashCode, isNot(equals(failure2.hashCode)));
      },
    );

    test(
      'should have different hashCode for different failure types with same message',
      () {
        // Arrange
        const message = 'Same message';
        const serverFailure = ServerFailure(message: message);
        const cacheFailure = CacheFailure(message: message);

        // Act & Assert
        expect(serverFailure.hashCode, isNot(equals(cacheFailure.hashCode)));
      },
    );

    test('should have consistent hashCode across all failure types', () {
      // Arrange
      const message = 'Consistent message';
      const failures = [
        CacheFailure(message: message),
        NetworkFailure(message: message),
        ValidationFailure(message: message),
        FileOperationFailure(message: message),
        ExportFailure(message: message),
        EmailFailure(message: message),
        UnexpectedFailure(message: message),
        ConnectionFailure(message: message),
      ];

      // Act & Assert
      for (int i = 0; i < failures.length; i++) {
        for (int j = i + 1; j < failures.length; j++) {
          expect(failures[i].hashCode, isNot(equals(failures[j].hashCode)));
        }
      }
    });
  });

  group('Equatable ToString Tests', () {
    test('should have meaningful toString representation - ServerFailure', () {
      // Arrange
      const message = 'Server connection failed';
      const failure = ServerFailure(message: message);

      // Act
      final stringRepresentation = failure.toString();

      // Assert
      expect(stringRepresentation, contains('ServerFailure'));
      expect(stringRepresentation, contains(message));
    });

    test('should have meaningful toString representation - CacheFailure', () {
      // Arrange
      const message = 'Cache operation failed';
      const failure = CacheFailure(message: message);

      // Act
      final stringRepresentation = failure.toString();

      // Assert
      expect(stringRepresentation, contains('CacheFailure'));
      expect(stringRepresentation, contains(message));
    });

    test('should have different toString for different failure types', () {
      // Arrange
      const message = 'Same message';
      const serverFailure = ServerFailure(message: message);
      const cacheFailure = CacheFailure(message: message);

      // Act
      final serverString = serverFailure.toString();
      final cacheString = cacheFailure.toString();

      // Assert
      expect(serverString, isNot(equals(cacheString)));
      expect(serverString, contains('ServerFailure'));
      expect(cacheString, contains('CacheFailure'));
    });
  });

  group('Edge Case Message Tests', () {
    test('should handle empty string message', () {
      // Arrange
      const message = '';

      // Act
      const failure = ServerFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.props, equals([message]));
    });

    test('should handle very long message', () {
      // Arrange
      const message =
          'This is a very long error message that might be used in real applications to provide detailed information about what went wrong during the operation execution process and should be handled properly by the failure system';

      // Act
      const failure = NetworkFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.props, equals([message]));
    });

    test('should handle message with special characters', () {
      // Arrange
      const message =
          'Error: Failed to process data! @#\$%^&*()_+-=[]{}|;:,.<>?/~`';

      // Act
      const failure = ValidationFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.props, equals([message]));
    });

    test('should handle message with newlines and tabs', () {
      // Arrange
      const message = 'Error occurred:\n\tFile not found\n\tPermission denied';

      // Act
      const failure = FileOperationFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.props, equals([message]));
    });

    test('should handle message with unicode characters', () {
      // Arrange
      const message = 'エラーが発生しました: файл не найден 错误';

      // Act
      const failure = ExportFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure.props, equals([message]));
    });
  });

  group('Inheritance Tests', () {
    test('should verify all failures extend Failure', () {
      // Arrange & Act & Assert
      expect(const ServerFailure(message: 'test'), isA<Failure>());
      expect(const CacheFailure(message: 'test'), isA<Failure>());
      expect(const NetworkFailure(message: 'test'), isA<Failure>());
      expect(const ValidationFailure(message: 'test'), isA<Failure>());
      expect(const FileOperationFailure(message: 'test'), isA<Failure>());
      expect(const ExportFailure(message: 'test'), isA<Failure>());
      expect(const EmailFailure(message: 'test'), isA<Failure>());
      expect(const UnexpectedFailure(message: 'test'), isA<Failure>());
      expect(const ConnectionFailure(message: 'test'), isA<Failure>());
    });

    test('should verify all failures implement Equatable', () {
      // Arrange & Act & Assert
      expect(const ServerFailure(message: 'test'), isA<Equatable>());
      expect(const CacheFailure(message: 'test'), isA<Equatable>());
      expect(const NetworkFailure(message: 'test'), isA<Equatable>());
      expect(const ValidationFailure(message: 'test'), isA<Equatable>());
      expect(const FileOperationFailure(message: 'test'), isA<Equatable>());
      expect(const ExportFailure(message: 'test'), isA<Equatable>());
      expect(const EmailFailure(message: 'test'), isA<Equatable>());
      expect(const UnexpectedFailure(message: 'test'), isA<Equatable>());
      expect(const ConnectionFailure(message: 'test'), isA<Equatable>());
    });
  });

  group('Collection and Comparison Tests', () {
    test('should work correctly in collections - Set', () {
      // Arrange
      const message = 'Duplicate message';
      const failure1 = ServerFailure(message: message);
      const failure2 = ServerFailure(message: message);
      const failure3 = CacheFailure(message: message);

      // Act
      final failureSet =
          <Failure>{}
            ..add(failure1)
            ..add(failure2)
            ..add(failure3);

      // Assert
      expect(
        failureSet,
        hasLength(2),
      ); // failure1 and failure2 are equal, so only 2 unique items
      expect(failureSet, contains(failure1));
      expect(failureSet, contains(failure3));
    });

    test('should work correctly in collections - List contains', () {
      // Arrange
      const message = 'Search message';
      const targetFailure = NetworkFailure(message: message);
      final failures = [
        ServerFailure(message: 'different message'),
        CacheFailure(message: message),
        NetworkFailure(message: message),
        ValidationFailure(message: 'another message'),
      ];

      // Act & Assert
      expect(failures, contains(targetFailure));
      expect(failures.indexOf(targetFailure), equals(2));
    });

    test('should work correctly with Map keys', () {
      // Arrange
      const message = 'Map key message';
      const failure1 = ExportFailure(message: message);
      const failure2 = ExportFailure(message: message);
      const failure3 = EmailFailure(message: message);

      final failureMap = <Failure, String>{
        failure1: 'First value',
        failure3: 'Second value',
      };

      // Act & Assert
      expect(
        failureMap[failure2],
        equals('First value'),
      ); // failure1 == failure2
      expect(failureMap[failure3], equals('Second value'));
      expect(failureMap, hasLength(2));
    });
  });

  group('Props Method Comprehensive Tests', () {
    test('should return correct props for all failure types', () {
      // Arrange
      const message = 'Props test message';
      final failures = [
        ServerFailure(message: message),
        CacheFailure(message: message),
        NetworkFailure(message: message),
        ValidationFailure(message: message),
        FileOperationFailure(message: message),
        ExportFailure(message: message),
        EmailFailure(message: message),
        UnexpectedFailure(message: message),
        ConnectionFailure(message: message),
      ];

      // Act & Assert
      for (final failure in failures) {
        expect(failure.props, equals([message]));
        expect(failure.props, hasLength(1));
        expect(failure.props.first, equals(message));
      }
    });

    test('should return a list from props getter', () {
      // Arrange
      const message = 'Props test';
      const failure = ServerFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, isA<List<Object>>());
      expect(props, isNotEmpty);
    });

    test('should return same props on multiple calls', () {
      // Arrange
      const message = 'Consistency test';
      const failure = ServerFailure(message: message);

      // Act
      final props1 = failure.props;
      final props2 = failure.props;

      // Assert
      expect(props1, equals(props2));
    });
  });

  group('Real-world Scenario Tests', () {
    test('should handle typical server error messages', () {
      // Arrange
      final serverErrors = [
        'HTTP 500: Internal Server Error',
        'Connection timed out after 30 seconds',
        'Authentication failed: Invalid credentials',
        'Resource not found: /api/users/123',
        'Rate limit exceeded: Too many requests',
      ];

      // Act & Assert
      for (final errorMessage in serverErrors) {
        final failure = ServerFailure(message: errorMessage);
        expect(failure.message, equals(errorMessage));
        expect(failure, isA<ServerFailure>());
      }
    });

    test('should handle typical validation error messages', () {
      // Arrange
      final validationErrors = [
        'Email format is invalid',
        'Password must be at least 8 characters',
        'Phone number format is incorrect',
        'Date must be in the future',
        'Field is required',
      ];

      // Act & Assert
      for (final errorMessage in validationErrors) {
        final failure = ValidationFailure(message: errorMessage);
        expect(failure.message, equals(errorMessage));
        expect(failure, isA<ValidationFailure>());
      }
    });

    test('should handle failure comparison in error handling scenarios', () {
      // Arrange
      const networkErrorMessage = 'No internet connection';
      const knownNetworkFailure = NetworkFailure(message: networkErrorMessage);

      // Simulate receiving a failure from a function
      final receivedFailure = NetworkFailure(message: networkErrorMessage);

      // Act & Assert
      expect(receivedFailure, equals(knownNetworkFailure));

      // This would allow for specific error handling based on failure type and message
      if (receivedFailure == knownNetworkFailure) {
        expect(true, isTrue); // Would trigger specific network error handling
      }
    });
  });
  group('ImportFailure Tests', () {
    test('should create ImportFailure with required message', () {
      // Arrange
      const message = 'Import operation failed';

      // Act
      const failure = ImportFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Excel import failed';
      const failure = ImportFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
      expect(props, hasLength(1));
    });

    group('Equatable behaviour', () {
      test('should be equal when messages are identical', () {
        // Arrange
        const message = 'Duplicate import error';
        const failure1 = ImportFailure(message: message);
        const failure2 = ImportFailure(message: message);

        // Act & Assert
        expect(failure1, equals(failure2));
        expect(failure1 == failure2, isTrue);
        expect(failure1.hashCode, equals(failure2.hashCode));
      });

      test('should not be equal when messages differ', () {
        // Arrange
        const failure1 = ImportFailure(message: 'Error #1');
        const failure2 = ImportFailure(message: 'Error #2');

        // Act & Assert
        expect(failure1, isNot(equals(failure2)));
        expect(failure1 == failure2, isFalse);
        expect(failure1.hashCode, isNot(equals(failure2.hashCode)));
      });
    });

    test('should have meaningful toString representation', () {
      // Arrange
      const message = 'Import failed due to invalid data';
      const failure = ImportFailure(message: message);

      // Act
      final stringRepresentation = failure.toString();

      // Assert
      expect(stringRepresentation, contains('ImportFailure'));
      expect(stringRepresentation, contains(message));
    });
  });
  group('Custom ValidationFailure Subclasses', () {
    test('InvalidEmailFailure has correct message & props', () {
      final failure = InvalidEmailFailure();
      expect(failure.message, 'Please enter a valid email address');
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, ['Please enter a valid email address']);
    });

    test('InvalidUuidFailure has correct message & props', () {
      const failure = InvalidUuidFailure();
      expect(failure.message, 'Invalid assessment ID format');
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, ['Invalid assessment ID format']);
    });

    test('InvalidStepNumberFailure has correct message & props', () {
      const failure = InvalidStepNumberFailure();
      expect(failure.message, 'Invalid step number');
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, ['Invalid step number']);
    });

    test('InvalidFormDataFailure preserves custom message', () {
      const msg = 'Form data is corrupt';
      const failure = InvalidFormDataFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });

    test('EmptyFieldFailure interpolates field name correctly', () {
      final failure = EmptyFieldFailure('Username');
      expect(failure.message, 'Username is required');
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, ['Username is required']);
    });

    test('InvalidExportFormatFailure has correct message & props', () {
      final failure = InvalidExportFormatFailure();
      expect(failure.message, 'Invalid export format specified');
      expect(failure.props, equals(['Invalid export format specified']));
    });

    test('InvalidPhoneNumberFailure has correct message & props', () {
      final failure = InvalidPhoneNumberFailure();
      expect(failure.message, 'Please enter a valid phone number');
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, ['Please enter a valid phone number']);
    });

    test('InvalidFileNameFailure preserves custom message', () {
      const msg = 'Filename contains illegal characters';
      final failure = InvalidFileNameFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });

    test('GenericValidationFailure preserves custom message', () {
      const msg = 'Some generic validation issue';
      const failure = GenericValidationFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });

    test('NumericValidationFailure preserves custom message', () {
      const msg = 'Value must be numeric';
      const failure = NumericValidationFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });

    test('TextLengthValidationFailure preserves custom message', () {
      const msg = 'Text must be at least 10 characters';
      const failure = TextLengthValidationFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });

    test('DateValidationFailure preserves custom message', () {
      const msg = 'Date must be before today';
      const failure = DateValidationFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });

    test('UrlValidationFailure preserves custom message', () {
      const msg = 'URL is malformed';
      const failure = UrlValidationFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });

    test('ListValidationFailure preserves custom message', () {
      const msg = 'List cannot be empty';
      const failure = ListValidationFailure(msg);
      expect(failure.message, msg);
      expect(failure, isA<ValidationFailure>());
      expect(failure.props, [msg]);
    });
  });

  group('PlatformFailure Tests', () {
    test('should create PlatformFailure with required message', () {
      // Arrange
      const message = 'Platform-specific operation failed';

      // Act
      const failure = PlatformFailure(message: message);

      // Assert
      expect(failure.message, equals(message));
      expect(failure, isA<Failure>());
      expect(failure, isA<Equatable>());
    });

    test('should have correct props', () {
      // Arrange
      const message = 'Missing platform channel';
      const failure = PlatformFailure(message: message);

      // Act
      final props = failure.props;

      // Assert
      expect(props, equals([message]));
      expect(props, hasLength(1));
    });

    group('Equatable behaviour', () {
      test('should be equal when messages are identical', () {
        const message = 'Same platform error';
        const f1 = PlatformFailure(message: message);
        const f2 = PlatformFailure(message: message);

        expect(f1, equals(f2));
        expect(f1 == f2, isTrue);
        expect(f1.hashCode, equals(f2.hashCode));
      });

      test('should not be equal when messages differ', () {
        const f1 = PlatformFailure(message: 'A');
        const f2 = PlatformFailure(message: 'B');

        expect(f1, isNot(equals(f2)));
        expect(f1 == f2, isFalse);
        expect(f1.hashCode, isNot(equals(f2.hashCode)));
      });
    });

    test('should have meaningful toString representation', () {
      const message = 'Platform not supported';
      const failure = PlatformFailure(message: message);

      final s = failure.toString();

      expect(s, contains('PlatformFailure'));
      expect(s, contains(message));
    });
  });
}
