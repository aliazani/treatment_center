import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

class GetRegionsByCountry
    extends UseCase<List<RegionEntity>, RegionsByCountryParams> {
  final GeographicRepository repository;

  GetRegionsByCountry(this.repository);

  @override
  Future<Either<Failure, List<RegionEntity>>> call(
    RegionsByCountryParams params,
  ) async {
    return await repository.getStatesByCountry(params.countryCode);
  }
}

class RegionsByCountryParams extends Equatable {
  final String countryCode;

  const RegionsByCountryParams({required this.countryCode});

  @override
  List<Object?> get props => [countryCode];
}
