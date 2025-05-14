import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';

/// Base abstract class for all use cases in the application.
///
/// [Type] is the return type of the use case (what will be returned to the presentation layer)
/// [Params] is the input parameters required by the use case
abstract class UseCase<Type, Params> {
  /// The main method that executes the use case logic.
  /// 
  /// Returns an [Either] with a [Failure] on the left or the expected [Type] on the right.
  Future<Either<Failure, Type>> call(Params params);
}

/// Special class for use cases that don't require any parameters.
///
/// Instead of passing null, we use this class for better type safety.
class NoParams {
  @override
  String toString() => 'No parameters';
}