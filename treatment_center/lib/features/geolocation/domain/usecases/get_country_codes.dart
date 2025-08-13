import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

class GetCountryCodesUsecase
    extends UseCase<List<CountryPhoneCodeEntity>, NoParams> {
  final GeographicRepository repository;

  GetCountryCodesUsecase(this.repository);

  @override
  Future<Either<Failure, List<CountryPhoneCodeEntity>>> call(
    NoParams params,
  ) async {
    return await repository.getCountryCodes();
  }
}
