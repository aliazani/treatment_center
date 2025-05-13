import 'package:equatable/equatable.dart';

/// Base abstract class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

/// Server failures - issues with remote data sources
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Cache failures - issues with local data storage
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Network failures - connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

/// Input validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

/// File operation failures - issues with reading/writing files
class FileOperationFailure extends Failure {
  const FileOperationFailure({required super.message});
}

/// Export failures - issues with exporting to different formats
class ExportFailure extends Failure {
  const ExportFailure({required super.message});
}

/// Export failures - issues with exporting to different formats
class EmailFailure extends Failure {
  const EmailFailure({required super.message});
}