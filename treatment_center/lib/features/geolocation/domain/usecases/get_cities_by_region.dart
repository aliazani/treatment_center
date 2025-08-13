import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

class GetCitiesByRegion extends UseCase<List<CityEntity>, CitiesByStateParams> {
  final GeographicRepository repository;

  GetCitiesByRegion(this.repository);

  @override
  Future<Either<Failure, List<CityEntity>>> call(
    CitiesByStateParams params,
  ) async {
    return await repository.getCitiesByState(params.stateCode);
  }
}

class CitiesByStateParams extends Equatable {
  final String stateCode;

  const CitiesByStateParams({required this.stateCode});

  @override
  List<Object?> get props => [stateCode];
}
