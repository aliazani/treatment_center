import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class FileOperationFailure extends Failure {
  const FileOperationFailure({required super.message});
}

class ExportFailure extends Failure {
  const ExportFailure({required super.message});
}

class EmailFailure extends Failure {
  const EmailFailure({required super.message});
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required super.message});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({required super.message});
}

class ImportFailure extends Failure {
  const ImportFailure({required super.message});
}

class InvalidEmailFailure extends ValidationFailure {
  const InvalidEmailFailure()
    : super(message: 'Please enter a valid email address');
}

class InvalidUuidFailure extends ValidationFailure {
  const InvalidUuidFailure() : super(message: 'Invalid assessment ID format');
}

class InvalidStepNumberFailure extends ValidationFailure {
  const InvalidStepNumberFailure() : super(message: 'Invalid step number');
}

class InvalidFormDataFailure extends ValidationFailure {
  const InvalidFormDataFailure(String message) : super(message: message);
}

class EmptyFieldFailure extends ValidationFailure {
  const EmptyFieldFailure(String fieldName)
    : super(message: '$fieldName is required');
}

class InvalidExportFormatFailure extends ValidationFailure {
  const InvalidExportFormatFailure()
    : super(message: 'Invalid export format specified');
}

class InvalidPhoneNumberFailure extends ValidationFailure {
  const InvalidPhoneNumberFailure()
    : super(message: 'Please enter a valid phone number');
}

class InvalidFileNameFailure extends ValidationFailure {
  const InvalidFileNameFailure(String message) : super(message: message);
}

class GenericValidationFailure extends ValidationFailure {
  const GenericValidationFailure(String message) : super(message: message);
}

class NumericValidationFailure extends ValidationFailure {
  const NumericValidationFailure(String message) : super(message: message);
}

class TextLengthValidationFailure extends ValidationFailure {
  const TextLengthValidationFailure(String message) : super(message: message);
}

class DateValidationFailure extends ValidationFailure {
  const DateValidationFailure(String message) : super(message: message);
}

class UrlValidationFailure extends ValidationFailure {
  const UrlValidationFailure(String message) : super(message: message);
}

class ListValidationFailure extends ValidationFailure {
  const ListValidationFailure(String message) : super(message: message);
}

class PlatformFailure extends Failure {
  const PlatformFailure({required super.message});
}
