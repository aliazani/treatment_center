import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

class GetCountries extends UseCase<List<CountryEntity>, NoParams> {
  final GeographicRepository repository;

  GetCountries(this.repository);

  @override
  Future<Either<Failure, List<CountryEntity>>> call(NoParams params) async {
    return await repository.getCountries();
  }
}
